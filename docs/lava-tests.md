# LAVA Hardware Tests

These tests run automatically on real hardware (IMDT 8550 SBC) via [LAVA](https://lava.readthedocs.io/) on every commit to `master` and on every pull request.

Each built image (`qcom-minimal-image` and `qcom-multimedia-image`) is deployed
and tested on **both board variants** as separate CI runs:

| Board tag | Variant | DUT ssh endpoint | Camera |
|-----------|---------|------------------|--------|
| `8550-8gb` | 8 GB IMDT 8550 SBC | pi-tester-2, port 2222 (`DUT_SSH_HOST_8GB` secret) | yes |
| `8550-12gb` | 12 GB IMDT 8550 SBC | original Pi, port 2222 (`DUT_SSH_HOST_12GB` secret) | yes |

The two boards' pipelines run in parallel (one CI job per image × board
combination); runs against the *same* board serialise. The per-board
parameters (device tag, ssh endpoint, memory threshold, camera presence) are
defined in the `setup` job of `build-imdt-base-image.yml` and applied to the
generic job definitions in `lava/` by the "Prepare board-specific LAVA job
definitions" step of `lava-tests.yml`.

Within a run the LAVA jobs execute sequentially: the SWUpdate deploy must
succeed (and flashes the image under test onto the inactive A/B slot) before the
SSH/camera jobs run against the freshly-deployed rootfs.

## Job 1 — SWUpdate Deploy (`swu-deploy`)

Pushes a `.swu` image over ssh/scp and verifies that the A/B rootfs slot switches on
reboot. In the same job it also updates the u-boot UEFI binary: the new
`BOOTAA64.EFI` is pushed over scp and written over the copy on the EFI System
Partition (`/efi/EFI/BOOT/BOOTAA64.EFI`) that the SoC firmware boots from. The
update takes effect on the reboot below, so the board coming back online
confirms the new u-boot booted successfully.

| Test Case | Description |
|-----------|-------------|
| `ssh-detect` | DUT is reachable over ssh |
| `fetch-swu` / `copy-swu` | `.swu` file is fetched from URL or copied from local storage |
| `push-swu` | `.swu` file is pushed to the device via scp |
| `swupdate` | `swupdate` runs without error and prints `SWUPDATE_OK` |
| `fetch-uboot` / `copy-uboot` | new `BOOTAA64.EFI` is fetched from URL or copied from local storage |
| `push-uboot` | `BOOTAA64.EFI` is pushed to the device via scp |
| `install-uboot` | `BOOTAA64.EFI` is written to the ESP and prints `UBOOT_INSTALL_OK` |
| `uboot-verify` | Installed `BOOTAA64.EFI` md5 matches the pushed binary |
| `reboot` | Device reboots cleanly via ssh |
| `wait-reboot` | Device comes back after reboot with a **new** `boot_id` (a genuine reboot under the new u-boot, immune to transient ssh drops) |
| `uboot-booted` | `BOOTAA64.EFI` on the ESP persisted unchanged across the reboot |
| `slot-switched` | Active rootfs partition changes (A→B or B→A) after update |
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
| `pipeline-setup` | `/opt/imdt/camss/qcs8550-csi0-ar1335.sh` exits 0 |
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

### `gbe` — Gigabit Ethernet (LAN7430)

| Test Case | Description |
|-----------|-------------|
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

## Optional — PCIe Key-B Overlay (`pcie-keyb-test`)

Verifies that the `qcs8550-imdt-sbc-pcie-keyb.dtbo` overlay is active and has correctly routed the on-board PCIe switch to the M.2 Key-B slot (J46) instead of the default LAN7430 path.

This job runs automatically in CI. The CI enables the Key-B overlay via `fw_setenv overlays '... qcs8550-imdt-sbc-pcie-keyb.dtbo'` and reboots before running the test, then restores the default overlay list afterwards. See [PCIe Switch — LAN7430 and M.2 Key-B](../README.md#pcie-switch--lan7430-and-m2-key-b) for manual `fw_setenv` instructions.

| Test Case | Description |
|-----------|-------------|
| `dtb-readable` | `/proc/device-tree/model` is accessible (DTB is loaded) |
| `pcie1-root-complex` | PCIe1 root complex (`0001:00:00.0`) appears in `lspci` — confirms PCIe1 probed correctly |
| `no-lan7430` | Microchip LAN7430 (`1055:7430`) is **absent** from `lspci` — confirms Key-B routing is active |
| `no-lan743x-driver` | `lan743x` driver has no bound PCI devices — no LAN7430 enumerated |
| `pcie-keyb-complete` | Informational: reports any M.2 Key-B device found on `0001:01:00.0` (pass regardless) |
