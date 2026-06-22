<img src="docs/logo.png" alt="IMD Technologies" width="200"/>

# meta-imdt-qcom-oss - Getting Started Guide 

[![Build Status](https://github.com/imd-tec/meta-imdt-qcom-oss-dev/actions/workflows/build-imdt-base-image.yml/badge.svg)](https://github.com/imd-tec/meta-imdt-qcom-oss-dev/actions/workflows/build-imdt-base-image.yml)
[![QCS8550-SBC QA Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/WilliamBright-IMD/1a72a27d66a7fdf5017e0f435d8f283d/raw/hardware-tests.json&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSI0NCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2VjNmEwIiBzdHJva2Utd2lkdGg9IjUiLz48dGV4dCB4PSI1MCIgeT0iNjEiIGZvbnQtZmFtaWx5PSJzYW5zLXNlcmlmIiBmb250LXNpemU9IjI4IiBmb250LXdlaWdodD0iYm9sZCIgZmlsbD0id2hpdGUiIHRleHQtYW5jaG9yPSJtaWRkbGUiPmltZHQ8L3RleHQ+PC9zdmc+)](https://github.com/imd-tec/meta-imdt-qcom-oss-dev/actions/workflows/build-imdt-base-image.yml)

![IMDT 8550 SBC](docs/imdt-8550-sbc.png)

The role of this meta layer is the following:
  - Provide an open source friendly BSP for IMDT Qualcomm boards
  - No qualcomm login needed
  - Track master branch Yocto/OpenEmbedded and meta-qcom
  - Track upstream Linux and U-Boot
  - Easy-to-use kas based build process 

## Table of Contents

- [QCS8550-SBC Feature Support](#qcs8550-sbc-feature-support)
- [Upstreaming Status](#upstreaming-status)
- [References](#references)
- [Prerequisites](#prerequisites)
- [Building release images](#building-release-images)
- [Deploying images](#deploying-images)
- [Working with the board](#working-with-the-board)
- [SWUpdate](#swupdate)
- [Appendix](#appendix)

## QCS8550-SBC Feature Support

| Feature | Hardware | Interface | Kernel Driver | Status |
|---|---|---|---|---|
| A/B Rootfs Updates | — | — | — | ✅ |
| ADSP | Hexagon v73 DSP | — | remoteproc |  ❌ |
| Android Debug Bridge (ADB) | — | USB | — | ✅ |
| Audio (LPASS) | — | — | — | ❌ |
| Bluetooth | NXP IW416 | UART14 | btnxpuart | ✅ |
| Camera (AR1335) | ON Semiconductor AR1335 | CSI0 | ar1335 | ✅ |
| CDSP | Hexagon v73 DSP | — | remoteproc |  ❌ |
| Debug Serial Console (J19)| — | UART7 (115200 baud) | qcom-geni-serial | ✅ |
| Gigabit Ethernet | Microchip LAN7430 | PCIe1 | lan743x | ✅ |
| GPIO | PM8550 GPIO bank | SPMI | qcom-spmi-gpio | ✅ |
| GPU (Adreno 740) | Adreno 740 | — | msm drm | ⚠️ Partial (no zap shader) |
| I2C | QupV3 I2C hub | I2C | geni-i2c | ✅ |
| IPA | Qualcomm IP Accelerator | — | ipa | ❌ |
| ISP (CAMX) | Qualcomm proprietary camera framework | — | — | ❌ |
| microSD Card | — | SDHC2 | sdhci | ✅ |
| MIPI DSI Display | Team Source TST070WSBE-196C 7" | DSI0 | drm/msm | ✅ |
| OTA Rootfs Updates | — | — | — | ✅ |
| PCIe Expansion (M.2 Key-E) | M.2 Key-E slot | PCIe0 | qcom-pcie | ✅ |
| U-Boot as ARM64 UEFI App| — | — | — | ✅ |
| UFS Storage | — | UFS | ufshcd | ✅ |
| USB 3.0 Type-C | NXP PTN3222 eUSB2 redriver | DWC3 (QCOM) | dwc3-qcom | ✅ Peripheral mode |
| Wi-Fi 802.11a/b/g/n/ac | NXP IW416 | SDIO (SDHC4) | mwifiex_sdio | ✅ |
| Yocto / OpenEmbedded Master branch | — | — | — | ✅ |


## Upstreaming Status
An effort is being made into upstreaming our board and patches into Linux.
| Patch | Status | Upstream Thread |
|---|---|---|
| Team Source TST070WSBE-196C display panel | ✅ Accepted | [v2 on lore.kernel.org](https://lore.kernel.org/all/20260428-imdt-dsi-display-v2-0-cf7294b5d7d6@imd-tec.com/T/#t) |
| SDHC4 (Wi-Fi SDIO) support | Pending | [v2 on lore.kernel.org](https://lore.kernel.org/all/20260427-sm8550-sdhc4-support-v2-1-a4241f43ecd5@imd-tec.com/T/#u) |
| QCS8550 SBC device tree | Pending | [v4 on lore.kernel.org](https://lore.kernel.org/linux-arm-msm/20260610-imdt-qcs8550-sbc-rfc-v4-0-358e71d606bc@imd-tec.com/T/#u) |

## Hardware Testing

Every commit is automatically tested on a physical IMDT 8550 SBC via [LAVA](https://lava.readthedocs.io/). Three jobs run in sequence:

1. **SWUpdate deploy** — flashes the new image over ADB and verifies the A/B rootfs slot switches
2. **System tests** — checks kernel health, systemd state, hardware subsystems (GPU, BT, RTC, IOMMU, I2C, hwrng), Wi-Fi, camera streaming, and SD card over SSH
3. **AR1335 frame capture** — captures a raw frame from the CSI0 camera and de-mosaics it to a 1080p PNG

See [docs/lava-tests.md](docs/lava-tests.md) for the full list of test cases.

## References

[1] [IMDT - QCS8550 SBC Datasheet rev 1.2](https://132746293-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FZvb1NVc2NQ09Xi4V8tb6%2Fuploads%2F4MwJ4jR2lujBBEVCaqCn%2FIMDT%20-%20QCS8550%20SBC%20Datasheet%20ver%201.2.pdf?alt=media&token=5371ed60-a7dd-4a76-92ca-22f02fe01d8b)

## Prerequisites

This process has been tested on machines with the following parameters:

- Ubuntu 22.04
- Docker Engine v24.02
- 8 Core / 16 Threads Processor
- 64GiB RAM
- At least 500GB of disk space on an ext4 formatted drive
- Python3 installed

It's recommended that anything older than Ubuntu 22.04 isn't used due to quirks with Docker security.

## Building release images

This section describes the process for building the release images from source.

### Prerequisites

This needs to be performed once on your machine:

```bash
git clone https://github.com/imd-tec/meta-imdt-qcom-oss.git
python3 -m venv venv
. venv/bin/activate
pip3 install kas
```

Once this has been completed, you can then restore the python environment using:

```bash
. venv/bin/activate
```

### Building

To build a bleeding edge image which tracks the master branch of all meta layers:

```bash
kas-container build --update meta-imdt-qcom-oss/kas/default.yml
```

Bleeding edge builds can fail from time-to-time. If you wish to build a known working Kas configuration you can use the below command:

```bash
wget https://github.com/imd-tec/meta-imdt-qcom-oss/releases/latest/download/imdt-image-base-kas-dump.yml
kas-container build imdt-image-base-kas-dump.yml
```

### Disabling Modem Manager

This may not be necessary if the host machine does not have the ModemManager service running. This is to stop the ModemManager configuring the Qualcomm device as a modem, if it sees the Qualcomm device as a modem.

```bash
sudo systemctl stop ModemManager.service
```

### Boot SBC into Emergency Download (EDL) mode

To boot the SBC into EDL mode, do the following:

1. Power on the board via the DC Jack or the USB PD port
2. Press and hold the USB BOOT button
3. Press the Reset button for 1-2 seconds whilst the USB BOOT button is held
4. For some boards you may also need to press the PON key
5. Release the USB BOOT button

Refer to [Connectors - Top Side](#11-connectors---top-side) to see the location of the USB BOOT and Reset buttons.

## Deploying images

It's recommended to use a Linux host for deploying images as QDL is complicated to build for Windows and instructions aren't going to be provided by IMDT.

### QDL

QDL can be used as a replacement for PCAT for customers without access to Qualcomm tools.

#### Building QDL

Run these commands on your host machine outside of Docker:

```bash
sudo apt install libxml2-dev libusb-1.0-0-dev help2man
git clone https://github.com/danielkutik/qdl.git 
cd qdl
make
sudo make install
```

#### QDL alias

Append the below alias to your `.bashrc` file:

```bash
alias flash_qcs8550_sbc='qdl -i imdt-image-base-imdt-8550-sbc.rootfs.qcomflash/ xbl_s_devprg_ns.melf imdt-image-base-imdt-8550-sbc.rootfs.qcomflash/rawprogram*.xml imdt-image-base-imdt-8550-sbc.rootfs.qcomflash/patch*.xml'
```

#### Flashing an image

Please make sure that the board is powered and in EDL as per [these instructions](#boot-sbc-into-emergency-download-edl-mode).

After unzipping a prebuilt image or an image you have built yourself:

```bash
flash_qcs8550_sbc
```

## Working with the board

### Powering the Board

See the [datasheet](#references) for power connection.

For access to the serial console, the USB to Serial adapter must be connected to the host machine. Once the board has finished booting, which takes about 10-15 seconds, the login prompt should appear in the serial console:

```
imdt-qcs8550-sbc login:
```

The username is `root`, there's no password.

### Connecting to the Debug Serial Consoles

When connected to a Linux host system, the serial ports will appear as USB devices (typically `/dev/ttyUSB0` and `/dev/ttyUSB1`). On Ubuntu systems, the serial consoles can be accessed using GTKTerm. Adding the current user to the `dialout` group will allow serial port access without requiring super-user privileges:

```bash
sudo apt install gtkterm
sudo usermod -a -G dialout <username>
# Log out and back in for the change to take effect
```

The screenshot below shows the serial port settings:

![Serial port settings](docs/serial-port-settings.png)

### Android Debug Bridge (ADB)

ADB is a command line tool used to communicate with devices running the ADB daemon. It can be used to launch a shell on the host which can be used to execute commands on the device.

#### Setting up ADB

Install ADB on the host machine:

```bash
sudo apt-get install adb
```

Check connected devices with ADB:

```bash
adb devices
```

#### Development Workflow using ADB

Once the device is connected to the ADB server on the host machine, shell commands can then be issued from the host machine to the device. The device filesystem can then be accessed using `adb push` or `pull`. And a terminal can be launched on the device using `adb shell`.

Copying files onto the device:

```bash
adb push /path/to/application /data/
```

Launch ADB shell:

```bash
adb shell
```

### Using the Display

The following section describes how to connect IMDT's display to the QCS8550 SBC. At the moment, only the IMDT DSI display is supported. However, work is in progress to add support for HDMI displays as well via a DSI to HDMI adapter. For more information about display connection see the [datasheet](#references).

To use the IMDT display (PN:IM-MSC-0006), IMDT's IM-PCA-0029 DSI adapter must be connected to the display using the display flex cables. Once connected, the adapter can then be connected to the SBC display connector as shown in the following image:

![Display connection](docs/display-connection.jpg)

Once the board is powered, the display will then boot up with the Yocto Project splash screen. The touchscreen will also be working.

### Streaming from MIPI Cameras

#### Streaming from AR1335

To stream from the AR1335 (PN:IM-CCM-0009) it must first be connected to the SBC board whilst the board is powered off. For example, here is an AR1335 connected to CSI4:

![AR1335 connected to CSI4](docs/ar1335-csi4.jpg)

For additional information see the [datasheet](#references) for connection details.

Once the AR1335 has been connected the board can then be powered on.

Currently only CSI0 has been tested on the open source release.

#### Streaming with V4L2 for CSI0

Run the following commands on the target board:

```bash
cd /opt/imdt/camss
./qcs8550-csi0-ar1335.sh
```

You will then see the name of the video device printed out:

```
Pipeline created for CSI0
Video device: /dev/video0
```

You can then run the below command to stream frames into memory at 1080P 30 FPS:

```bash
v4l2-ctl -d /dev/video0 --stream-mmap
```

You may need to change the name of the video device as sometimes it can be `/dev/video1`.

### Onboard WiFi

The onboard WiFi (NXP [IW416](https://www.nxp.com/products/IW416), `mlan0`) is managed by systemd services, so it is configured once and connects automatically on every boot. No manual `ip link` / `udhcpc` steps are required.

All commands below run on the target board.

#### 1. Configure the network credentials

Create the wpa_supplicant configuration directory and header:

```bash
mkdir -p /etc/wpa_supplicant
nano /etc/wpa_supplicant/wpa_supplicant-nl80211-mlan0.conf
```

Paste in the following (change the country code if not located in the UK):

```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
country=GB
```

Save and exit, then append the network credentials. Replace `NETWORK_NAME` and `NETWORK_PASSWORD` with your network's details — this stores a derived hash rather than the plaintext password:

```bash
wpa_passphrase 'NETWORK_NAME' 'NETWORK_PASSWORD' >> /etc/wpa_supplicant/wpa_supplicant-nl80211-mlan0.conf
```

#### 2. Enable DHCP on the WiFi interface

Create a systemd-networkd configuration that manages any WiFi station interface:

```bash
nano /etc/systemd/network/80-wifi-station.network
```

With the following content:

```ini
[Match]
Type=wlan
WLANInterfaceType=station

[Network]
DHCP=yes
```

#### 3. Enable the WiFi service

```bash
systemctl enable --now wpa_supplicant-nl80211@mlan0
systemctl restart systemd-networkd
```

From now on this happens automatically at every boot.

#### 4. Verify the connection

```bash
networkctl status mlan0
```

Should show:

```
3: mlan0
Link File: /usr/lib/systemd/network/99-default.link
Network File: /etc/systemd/network/80-wifi-station.network
State: routable (configured)
Online state: online
```

## SWUpdate

[SWUpdate](https://sbabic.github.io/swupdate/swupdate.html) is supported with A/B partitions for the rootfs (which also includes the Linux kernel image, kernel modules and the DTB/DTBO files) with automatic rollback supported. An automatic rollback will occur via U-Boot if there are three failed boots after performing a SWUpdate.

### Performing a SWUpdate

From your host, you will need to push the `.swu` file to the target using ADB:

```bash
adb push imdt-image-base.swu-imdt-8550-sbc.rootfs.swu /root/
```

And then you can perform a SWUpdate using the following commands on your host:

```bash
adb shell "cd /root/ && swupdate -i imdt-image-base.swu-imdt-8550-sbc.rootfs.swu"
adb reboot
```

## Appendix

### 1.1. Connectors - Top Side

![Connectors - top side](docs/connectors-top.png)

| #  | Functionality             | Silk name |
|----|---------------------------|-----------|
| 1  | DEBUG                     | J19       |
| 2  | Display                   | J41       |
| 3  | Auxiliary                 | J52       |
| 4  | PSM (Power supply Module) | J1        |
| 5  | Power In - USB-PD         | J30       |
| 6  | Power In - DC Jack        | P1        |
| 7  | Fan                       | J44       |
| 8  | Micro SD card             | J43       |
| 9  | USB BOOT Button           | SW2       |
| 10 | USB 3.0 C-Type            | J12       |
| 11 | 3.5mm Audio Jack          | J11       |
| 12 | RS-232                    | J9        |
| 13 | Ethernet                  | J55       |
| 14 | u.FL BLE antenna          | J42       |
| 15 | Reset Button              | SW3       |

### 1.2. Connectors - Bottom Side

![Connectors - bottom side](docs/connectors-bottom.png)

| #  | Functionality   | Silk name |
|----|-----------------|-----------|
| 16 | M.2 Key-E       | J45       |
| 17 | M.2 Key-B       | J46       |
| 18 | CSI 3 connector | J58       |
| 19 | CSI 2 connector | J35       |
| 20 | CSI 7 connector | J62       |
| 21 | CSI 5 connector | J60       |
| 22 | CSI 0 connector | J40       |
| 23 | CSI 1 connector | J57       |
| 24 | CSI 4 connector | J59       |
| 25 | CSI 6 connector | J61       |
| 26 | Nano SIM card   | J47       |

---

Copyright © 2026 IMD Technologies
