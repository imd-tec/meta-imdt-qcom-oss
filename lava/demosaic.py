#!/usr/bin/env python3
"""De-mosaic a SGRBG10-packed raw frame from the AR1335 into a PNG thumbnail.

Sensor: AR1335 on QCS8550-IMDT-SBC
Format: V4L2_PIX_FMT_SGRBG10P  (pgAA)
  - Bayer pattern: GR / BG (GRBG)
  - Packing: MIPI RAW10 — 4 pixels per 5 bytes
      byte[0] = P0[9:2]   byte[1] = P1[9:2]
      byte[2] = P2[9:2]   byte[3] = P3[9:2]
      byte[4] = P3[1:0] P2[1:0] P1[1:0] P0[1:0]
"""

import argparse
import sys
import numpy as np
from PIL import Image

# Sensor defaults — overridable via CLI
_W   = 4208
_H   = 3120
_BPL = 5264   # bytes per line (includes 4 bytes padding per row)


def unpack_sgrbg10p(data: bytes, width: int, height: int, bpl: int) -> np.ndarray:
    """Unpack MIPI RAW10 bytes → uint16 array shape (height, width)."""
    raw = np.frombuffer(data, dtype=np.uint8)
    groups = width // 4
    active = groups * 5          # active bytes per row (no padding)

    # Build index array to strip padding and gather active bytes
    row_starts   = np.arange(height, dtype=np.int64) * bpl
    col_offsets  = np.arange(active, dtype=np.int64)
    indices      = row_starts[:, None] + col_offsets[None, :]   # (H, active)
    rows         = raw[indices].reshape(height, groups, 5)       # (H, groups, 5)

    msb  = rows[:, :, :4].astype(np.uint16)   # (H, groups, 4)
    lsb  = rows[:, :, 4].astype(np.uint16)    # (H, groups)

    p    = msb << 2
    p[:, :, 0] |=  lsb        & 0x03
    p[:, :, 1] |= (lsb >> 2)  & 0x03
    p[:, :, 2] |= (lsb >> 4)  & 0x03
    p[:, :, 3] |= (lsb >> 6)  & 0x03

    return p.reshape(height, width)


def demosaic_grbg(bayer: np.ndarray, scale: int) -> np.ndarray:
    """Bilinear-ish demosaic + integer downscale for GRBG Bayer.

    GRBG layout (top-left 2×2 super-pixel):
        G R
        B G

    Each output pixel at scale S averages S×S super-pixels.
    Returns uint8 RGB array shape (H//2S, W//2S, 3).
    """
    h, w = bayer.shape

    # Separate the four Bayer channels (each already half-size)
    G1 = bayer[0::2, 0::2].astype(np.float32)   # Green  (even row, even col)
    R  = bayer[0::2, 1::2].astype(np.float32)   # Red    (even row, odd  col)
    B  = bayer[1::2, 0::2].astype(np.float32)   # Blue   (odd  row, even col)
    G2 = bayer[1::2, 1::2].astype(np.float32)   # Green  (odd  row, odd  col)
    G  = (G1 + G2) * 0.5

    def block_mean(arr: np.ndarray, s: int) -> np.ndarray:
        rh = (arr.shape[0] // s) * s
        rw = (arr.shape[1] // s) * s
        return arr[:rh, :rw].reshape(rh // s, s, rw // s, s).mean(axis=(1, 3))

    r_out = block_mean(R,  scale)
    g_out = block_mean(G,  scale)
    b_out = block_mean(B,  scale)

    # Gray-world white balance: scale R and B so their means match G.
    g_mean = g_out.mean()
    r_mean = r_out.mean()
    b_mean = b_out.mean()
    if r_mean > 0:
        r_out = r_out * (g_mean / r_mean)
    if b_mean > 0:
        b_out = b_out * (g_mean / b_mean)

    # Percentile stretch: map p1–p99 to 0–255 so the image is correctly
    # exposed regardless of scene brightness or sensor gain.
    all_ch = np.concatenate([r_out.ravel(), g_out.ravel(), b_out.ravel()])
    lo, hi = np.percentile(all_ch, (1, 99))
    if hi <= lo:
        hi = lo + 1.0
    def stretch(ch):
        return np.clip((ch - lo) / (hi - lo) * 255, 0, 255).astype(np.uint8)
    r8 = stretch(r_out)
    g8 = stretch(g_out)
    b8 = stretch(b_out)

    return np.stack([r8, g8, b8], axis=2)


def main():
    ap = argparse.ArgumentParser(description='De-mosaic AR1335 SGRBG10P raw → PNG')
    ap.add_argument('input',          help='Raw input file')
    ap.add_argument('output',         help='PNG output file')
    ap.add_argument('--width',    type=int, default=_W,          help='Sensor width  (default %(default)s)')
    ap.add_argument('--height',   type=int, default=_H,          help='Sensor height (default %(default)s)')
    ap.add_argument('--bpl',      type=int, default=_BPL,        help='Bytes per line (default %(default)s)')
    ap.add_argument('--scale',    type=int, default=1,
                    help='Integer downscale factor applied to each Bayer super-pixel axis '
                         '(output size = W/(2·scale) × H/(2·scale), default %(default)s → 2104×1560)')
    ap.add_argument('--out-size', type=str, default='1920x1080',
                    help='Final output dimensions WxH; the demosaiced image is resized with '
                         'Lanczos to this size (default %(default)s). Pass 0x0 to skip resize.')
    args = ap.parse_args()

    out_w, out_h = (int(v) for v in args.out_size.lower().split('x'))

    print(f'Reading {args.input} ({args.width}×{args.height}, bpl={args.bpl})', flush=True)
    with open(args.input, 'rb') as f:
        data = f.read()

    frame_size = args.bpl * args.height
    n_frames = len(data) // frame_size
    if n_frames > 1:
        print(f'Multi-frame file ({n_frames} frames) — using last frame', flush=True)
        data = data[-frame_size:]
    elif len(data) < frame_size:
        print(f'Warning: file is {len(data)} bytes, expected {frame_size}', file=sys.stderr)

    bayer = unpack_sgrbg10p(data, args.width, args.height, args.bpl)
    rgb   = demosaic_grbg(bayer, args.scale)

    img = Image.fromarray(rgb, 'RGB')
    if out_w and out_h:
        img = img.resize((out_w, out_h), Image.LANCZOS)
    img.save(args.output)
    print(f'Wrote {args.output} ({img.width}×{img.height})', flush=True)


if __name__ == '__main__':
    main()
