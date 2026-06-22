# LAVA Hardware Tests

These tests run automatically on real hardware (IMDT 8550 SBC) via [LAVA](https://lava.readthedocs.io/) on every commit to `master` and on every pull request.

The three LAVA jobs run sequentially: the SWUpdate deploy must succeed before SSH tests begin, and camera capture runs last.

## Job 1 — SWUpdate Deploy (`swu-deploy`)

Pushes a `.swu` image over ADB and verifies that the A/B rootfs slot switches on reboot.

| Test Case | Description |
|-----------|-------------|
| `adb-detect` | ADB device is reachable and returns a serial number |
| `fetch-swu` / `copy-swu` | `.swu` file is fetched from URL or copied from local storage |
| `push-swu` | `.swu` file is pushed to the device via ADB |
| `swupdate` | `swupdate` runs without error and prints `SWUPDATE_OK` |
| `reboot` | Device reboots cleanly via ADB |
| `wait-reboot` | Device comes back online after reboot |
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

### `systemd-health` — Service and kernel health

| Test Case | Description |
|-----------|-------------|
| `systemd-state` | systemd reports `running` or `degraded` (not `failed`) |
| `dmesg-critical` | No kernel messages at emergency/alert/critical level (levels 0–2) |

### `resources` — Disk and memory

| Test Case | Description |
|-----------|-------------|
| `disk-free` | `df -h /` succeeds (rootfs is mounted and readable) |
| `mem-free` | `free -m` succeeds (memory stats available) |

### `wifi` — Wireless interface

| Test Case | Description |
|-----------|-------------|
| `wifi-present` | `mlan0` (NXP IW416) interface is present in `ip link` |

### `ar1335-stream` — Camera streaming (CSI0)

| Test Case | Description |
|-----------|-------------|
| `pipeline-setup` | `/opt/imdt/camss/qcs8550-csi0-ar1335.sh` exits 0 |
| `sensor-enumerated` | `ar1335` appears in `media-ctl -d /dev/media0 -p` output |
| `video-node` | A `/dev/videoN` node is reported by the setup script |
| `stream-30-frames` | `v4l2-ctl --stream-mmap --stream-count=30` completes within 60 s |

### `sdcard` — SD card

| Test Case | Description |
|-----------|-------------|
| `sdcard-present` | `/dev/mmcblk0` is present |

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

Captures a raw frame from the AR1335 camera over ADB and de-mosaics it to a 1080p PNG, which is uploaded as a CI artifact.

| Test Case | Description |
|-----------|-------------|
| `pipeline-setup` | CSI0 pipeline script exits 0 (run via ADB) |
| `capture-raw-frame` | `v4l2-ctl --stream-to` captures one raw frame to `/tmp/ar1335_frame.raw` |
| `demosaic` | `demosaic.py` converts the raw frame to `/images/ar1335_1080p.png` |

## Optional — PCIe Key-B Overlay (`pcie-keyb-test`)

Verifies that the `qcs8550-imdt-sbc-pcie-keyb.dtb` overlay is active and has correctly routed the on-board PCIe switch to the M.2 Key-B slot (J46) instead of the default LAN7430 path.

This job runs automatically in CI. The CI enables the Key-B overlay via `fw_setenv overlays '... qcs8550-imdt-sbc-pcie-keyb.dtbo'` and reboots before running the test, then restores the default overlay list afterwards. See [PCIe Switch — LAN7430 and M.2 Key-B](#pcie-switch--lan7430-and-m2-key-b) in the README for manual `fw_setenv` instructions.

| Test Case | Description |
|-----------|-------------|
| `dtb-readable` | `/proc/device-tree/model` is accessible (DTB is loaded) |
| `pcie1-root-complex` | PCIe1 root complex (`0001:00:00.0`) appears in `lspci` — confirms PCIe1 probed correctly |
| `no-lan7430` | Microchip LAN7430 (`1055:7430`) is **absent** from `lspci` — confirms Key-B routing is active |
| `no-lan743x-driver` | `lan743x` driver has no bound PCI devices — no LAN7430 enumerated |
| `pcie-keyb-complete` | Informational: reports any M.2 Key-B device found on `0001:01:00.0` (pass regardless) |
