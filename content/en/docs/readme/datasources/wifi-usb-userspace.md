---
title: "Wi-Fi: USB userspace"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "wifi-usb-userspace-a018dcd0c5e843d29d9dd6b02e8d1ce8"
weight: 150
toc: true
---

Added: `2026-10`

The USB Wi-Fi userspace source captures from USB Wi-Fi adapters by running the Linux kernel Wi-Fi drivers in userspace, on top of libusb.  The driver code is taken unmodified from the Linux kernel and runs inside the Kismet capture tool, so no kernel driver is needed.

This allows monitor mode capture on systems with no driver for the adapter (such as macOS), and on Linux systems where the kernel driver is missing, out of date, or doesn't support monitor mode properly.

Kismet will auto-detect supported adapters as `usbwifi`, or you may manually specify the type:

```
source=mt7921-0:type=usbwifi
```

## Supported hardware

The source currently supports MediaTek adapters using the `mt76` family of drivers:

* MT7921 USB (`mt7921u`), including the MT7921AU.  USB IDs `0e8d:7961`, `0e8d:7902`, `3574:6211`, `0846:9060`, `0846:9065`, and `35bc:0107`.
* MT7925 USB (`mt7925u`).  USB IDs `0e8d:7925`, `0e8d:6639`, `0846:9050`, and `0846:9072`.
* MT7612U / MT7632U (`mt76x2u`), such as the Alfa AWUS036ACM, Asus USB-AC54 and USB-AC55, Netgear A6210, and TP-Link TL-WDN6200.  USB IDs `0e8d:7612`, `0e8d:7632`, `0b05:1833`, `0b05:17eb`, `0b05:180b`, `057c:8503`, `7392:b711`, `056e:400a`, `0471:2126`, `0471:7600`, `2c4e:0103`, `0846:9014`, `0846:9053`, `045e:02e6`, `045e:02fe`, and `2357:0137`.

The available bands, channels, and channel widths are discovered from the driver when the adapter is opened; the MT7921AU, for example, supports 2.4GHz, 5GHz, and 6GHz with channel widths up to 80MHz.

More drivers may be added in the future.

## Firmware

The MediaTek firmware required by these adapters is included with Kismet, from the [linux-firmware](https://gitlab.com/kernel-firmware/linux-firmware) project, and is installed into the Kismet `share/kismet/firmware` directory.  The firmware is redistributed under the MediaTek and Ralink licenses included with it.

## Compiling USB userspace Wi-Fi support

USB userspace Wi-Fi requires libusb, and is built by default on Linux and macOS when libusb is available.  It can be disabled by passing `--disable-usbwifi` to `./configure`, or forced on for other platforms with `--enable-usbwifi`.

### Linux

On Linux, if the kernel driver (`mt7921u`, `mt7925u`, or `mt76x2u`) is loaded and has claimed the adapter, Kismet will detach the kernel driver when the source is opened.  When the source closes, the kernel driver is re-attached.

Kismet needs permission to access the USB device; either run the capture tool as root (it is installed suid-root with `make suidinstall`), or grant access to the device with a udev rule.

## Interfaces

USB Wi-Fi adapters are named by the driver and their position on the USB bus: the first MT7921 adapter is `mt7921-0`, the second is `mt7921-1`, the first MT7925 adapter is `mt7925-0`, and the first MT7612U adapter is `mt76x2-0`.  Adapters are numbered in USB port order, so the names stay the same if the adapter is unplugged and plugged back into the same port.

Adapters can be listed with:

```bash
$ kismet_cap_usbwifi --list
```

or in the Kismet web UI datasources panel.

The source UUID is generated from the MAC address of the adapter, so it stays the same when the adapter is moved to a different USB port.

When used as a remote capture (`--connect`), the adapter is opened and its firmware loaded before connecting to the Kismet server, so the server can match the source by its UUID when it reconnects.  This takes a few seconds longer to connect than other remote sources.

## Channels

Channels use the same names as the [Linux Wi-Fi](/docs/readme/datasources/wifi-linux/) datasource:

* `6`, `36`: 20MHz channels on 2.4GHz and 5GHz
* `6HT40+`, `6HT40-`: 40MHz channels, with the secondary channel above or below
* `36VHT80`, `36VHT160`: 80MHz and 160MHz channels
* `37W6e`: 6GHz channels, at 20MHz

The list of channels is generated from the bands and widths the adapter reports.  Channels the firmware refuses to tune to are dropped from the hopping list.

## USB userspace Wi-Fi source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel options

{{<configopt ht_channels true false>}}
Include 40MHz HT channels in the channel list.  By default HT channels are included.
{{</configopt>}}

{{<configopt vht_channels true false>}}
Include 80MHz and 160MHz VHT channels in the channel list.  By default VHT channels are included.
{{</configopt>}}

### Regulatory options

{{<configopt country "XX">}}
Two-letter country code reported to the driver as the regulatory domain.
{{</configopt>}}

### Firmware options

{{<configopt firmware "/path/to/firmware/dir">}}
A directory searched first for the adapter firmware, before the Kismet share directory and the system firmware directory.  This is normally only needed when testing new firmware.
{{</configopt>}}

### Debugging options

{{<configopt verbose true false>}}
Forward informational messages from the driver to the Kismet messages.  By default only driver errors are shown.
{{</configopt>}}
