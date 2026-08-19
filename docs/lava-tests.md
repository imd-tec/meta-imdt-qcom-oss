# LAVA Hardware Tests

These tests run automatically on real hardware (IMDT 8550 SBC) via [LAVA](https://lava.readthedocs.io/) on every commit to `master` and on every pull request.

Each built image (`qcom-minimal-image` and `qcom-multimedia-image`) is deployed
and tested on **both board variants** as separate CI runs:

| Board tag | Variant | DUT ssh endpoint | Camera |
|-----------|---------|------------------|--------|
| `8550-8gb` | 8 GB IMDT 8550 SBC | pi-tester-3, port 2222 (`DUT_SSH_HOST_8GB` secret) | yes |
| `8550-12gb` | 12 GB IMDT 8550 SBC | original Pi, port 2222 (`DUT_SSH_HOST_12GB` secret) | yes |

The two boards' pipelines run in parallel (one CI job per image × board
combination); runs against the *same* board serialise. The per-board
parameters (device tag, ssh endpoint, memory threshold, camera presence) are
defined in the `setup` job of `build-imdt-base-image.yml` and applied to the
generic job definitions in `lava/` by the "Prepare board-specific LAVA job
definitions" step of `lava-tests.yml`.

Within a run the LAVA jobs execute sequentially: the OSTree deploy must
succeed (and boots the board into the deployment under test) before the
SSH/camera jobs run against the freshly-deployed rootfs.

## Job 1 — OSTree Deploy (`ostree-deploy`)

Pushes the build's OSTree commit archive (`*.ostreecommit.tar.xz`) to the DUT
over ssh/scp in resumable 64 MB chunks, unpacks it, exposes it as a throwaway
`file://` OSTree remote and then runs the on-target `ostree-imdt-update` helper
to pull and stage it — the same script a fielded board runs, so CI covers the
real update path rather than open-coded `ostree` calls. The board's production
`imdt` remote is left untouched, and the CI-only remote is removed at the end.
Each staging copy is freed as soon as it is consumed, so the ~6 GB rootfs only
ever grows by the delta of the new commit. After the reboot the job checks the
running deployment changed and that `imdt-ostree-bless` cleared the systemd-boot
BLS boot counter — without that the next reboot would roll back, since the board
has no EFI variables.

| Test Case | Description |
|-----------|-------------|
| `ssh-detect` | DUT is reachable over ssh |
| `commit-present` | commit archive is staged in `/images` on the LAVA worker |
| `push-commit` | archive is pushed to the device and its md5 matches |
| `unpack-commit` | archive unpacks into a local ostree repo on the DUT |
| `update-remote` | unpacked repo is registered as the throwaway `lava-local` remote |
| `ostree-deploy` | `ostree-imdt-update` pulls the commit and stages it as a new deployment |
| `root-unlocked` | ostree's immutable bit is cleared from the deployment roots, so `ssh-tests` can scp its overlay into `/lava-<id>` |
| `reboot` | Device reboots and comes back with a **new** `boot_id` (a genuine reboot, immune to transient ssh drops) |
| `deployment-switched` | Running deployment checksum differs from the pre-update one |
| `boot-blessed` | No `+tries` BLS entry remains, i.e. the boot counter was blessed and the deployment will not roll back |
| `post-boot-shell` | Post-update shell is accessible; `/etc/hwrevision` readable |

## Job 2 — System Tests (`ssh-tests`)

Runs over SSH on the updated rootfs. Groups of tests are submitted as independent LAVA test definitions.

### `system-info` — Basic system information

| Test Case | Description |
|-----------|-------------|
| `kernel-version` | `uname -a` succeeds and prints kernel version |
| `hwrevision` | `/etc/hwrevision` is present and readable |
| `rootfs-slot` | Active rootfs slot is present in kernel command line |

### `resources` — Disk and memory

| Test Case | Description |
|-----------|-------------|
| `disk-free` | `df -h /` succeeds (rootfs is mounted and readable) |
| `mem-free` | `free -m` succeeds (memory stats available) |
| `mem-avail-min` | Available memory (`free -m` available column) meets the per-board minimum: ≥8500 MB on the 12 GB board, ≥4500 MB on the 8 GB board (`MEM_MIN_MB` parameter) |

### `wifi` — Wireless interface

Reports a `skip` on boards where Wi-Fi is not expected to work
(`has-wifi: false` in `build-imdt-base-image.yml` → `WIFI_PRESENT`
parameter). Currently skipped on the 8 GB board: the IW416 enumerates on
SDIO but no driver binds with the current image.

| Test Case | Description |
|-----------|-------------|
| `wifi-present` | `mlan0` (NXP IW416) interface is present in `ip link` |

### `ar1335-stream` — Camera streaming (CSI0)

On boards without the camera module, all cases in this suite report `skip`
(set `has-camera: false` for the board in `build-imdt-base-image.yml`, which
flows into the `CAMERA_PRESENT` parameter). Both current boards have the
camera attached.

| Test Case | Description |
|-----------|-------------|
| `pipeline-setup` | `/usr/sbin/qcs8550-csi0-ar1335.sh` exits 0 |
| `sensor-enumerated` | `ar1335` appears in `media-ctl -d /dev/media0 -p` output |
| `video-node` | A `/dev/videoN` node is reported by the setup script |
| `stream-30-frames` | `v4l2-ctl --stream-mmap --stream-count=30` completes within 60 s |

### `sdcard` — SD card

Reports a `skip` on fixtures without an SD card inserted (`has-sdcard: false`
for the board in `build-imdt-base-image.yml` → `SDCARD_PRESENT` parameter).
Currently skipped on the 8 GB fixture (no card fitted).

| Test Case | Description |
|-----------|-------------|
| `sdcard-present` | `/dev/mmcblk0` is present |

### `pcie-gbe` — PCIe routing and Gigabit Ethernet (LAN7430)

| Test Case | Description |
|-----------|-------------|
| `pcie0-root-complex` | PCIe0 root complex (`0000:00:00.0`) appears in `lspci` — feeds the M.2 Key-E slot |
| `pcie1-root-complex` | PCIe1 root complex (`0001:00:00.0`) appears in `lspci` — feeds the on-board switch |
| `lan7430-present` | Microchip LAN7430 (`1055:7430`) appears in `lspci` — confirms PCIe switch is in default GbE routing |
| `lan743x-driver-bound` | `lan743x` driver has at least one bound PCI device |

### `hardware` — Hardware subsystems

| Test Case | Description |
|-----------|-------------|
| `gpu-drm-render` | `/dev/dri/renderD128` exists (GPU render node) |
| `gpu-drm-card` | `/dev/dri/card0` exists (GPU card node) |
| `bluetooth-present` | `/sys/class/bluetooth/hci0` exists |
| `rtc-present` | `/dev/rtc0` exists |
| `cpu-freq-scaling` | `scaling_governor` sysfs entry present for CPU0 |
| `i2c-buses` | At least one `/dev/i2c-*` device node present |
| `iommu-groups` | At least one IOMMU group present under `/sys/kernel/iommu_groups/` |
| `hwrng-readable` | `/dev/hwrng` yields at least 16 bytes |

## Job 3 — AR1335 Frame Capture (`ar1335-capture`)

Captures a raw frame from the AR1335 camera over ssh and de-mosaics it to a PNG, which is uploaded as a CI artifact. This job only runs on boards with the camera module attached (currently both). The output PNG is board-specific (`/images/ar1335_<board-tag>.png`) so parallel board runs don't overwrite each other's frame.

| Test Case | Description |
|-----------|-------------|
| `pipeline-setup` | CSI0 pipeline script exits 0 (run via ssh) |
| `capture-raw-frame` | `v4l2-ctl --stream-to` captures one raw frame to `/tmp/ar1335_frame.raw` |
| `demosaic` | `demosaic.py` converts the raw frame to `/images/ar1335_<board-tag>.png` |

## PCIe M.2 Key-B — not covered by CI

There is no Key-B job any more. Routing PCIe1 to the M.2 Key-B slot (J46)
instead of the LAN7430 needs the `qcs8550-imdt-sbc-pcie-keyb` overlay, and
overlays are applied by the **UEFI firmware** from the FIT image at boot (see
[Device Tree Overlays](../README.md#device-tree-overlays)) — the old U-Boot
`fw_setenv overlays` runtime switch does not exist on a systemd-boot board, so a
LAVA job cannot flip the routing between test runs.

The images CI builds therefore always take the GbE path, which `ssh-tests`
asserts in [`pcie-gbe`](#pcie-gbe--pcie-routing-and-gigabit-ethernet-lan7430).
Key-B is verified by hand against an image built with the overlay added to
`FIT_DTB_COMPATIBLE`; the checks that job used to make were `no-lan7430` and
`no-lan743x-driver` (the LAN7430 disappears from `lspci` once PCIe1 is routed
away from it) plus any device appearing on `0001:01:00.0`.
