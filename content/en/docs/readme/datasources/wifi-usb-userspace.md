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

The USB Wi-Fi userspace source captures from USB Wi-Fi adapters by running the Linux kernel Wi-Fi drivers in userspace, on top of libusb.  The driver code is taken from the Linux kernel, unmodified or with only small changes, and runs inside the Kismet capture tool, so no kernel driver is needed.

This allows monitor mode capture on systems with no driver for the adapter (such as macOS), and on Linux systems where the kernel driver is missing, out of date, or doesn't support monitor mode properly.

## Choosing a Wi-Fi source

### macOS

On macOS, the USB userspace source is the preferred way to capture from a USB Wi-Fi adapter.  It runs natively on macOS: no virtual machine, USB passthrough, or kernel extension is needed.  The built-in Wi-Fi interface is still captured with the [macOS CoreWLAN](/docs/readme/datasources/wifi-macos/) source.

### Linux

On Linux, the USB userspace source is an alternative to the [Linux Wi-Fi](/docs/readme/datasources/wifi-linux/) source for the adapters it supports.  It can be more stable than some kernel drivers in monitor mode, and it may provide more modern drivers than the running kernel, since the drivers come from a recent Linux kernel instead of the one the system is running.  This is especially useful for the Realtek RTL88xx adapters, whose out-of-kernel drivers often don't support monitor mode properly.

Either source can be used with the same adapter; Kismet detaches the kernel driver while the USB userspace source is open.

Kismet will auto-detect supported adapters as `usbwifi`, or you may manually specify the type:

```
source=mt7921-0:type=usbwifi
```

## Supported hardware

The source supports MediaTek adapters using the `mt76` family of drivers, and Realtek adapters using the `rtw88` family of drivers.

### MediaTek

* MT7921 USB (`mt7921u`), including the MT7921AU.  USB IDs `0e8d:7961`, `0e8d:7902`, `3574:6211`, `0846:9060`, `0846:9065`, and `35bc:0107`.
* MT7925 USB (`mt7925u`).  USB IDs `0e8d:7925`, `0e8d:6639`, `0846:9050`, and `0846:9072`.
* MT7612U / MT7632U (`mt76x2u`), such as the Alfa AWUS036ACM, Asus USB-AC54 and USB-AC55, Netgear A6210, and TP-Link TL-WDN6200.  USB IDs `0e8d:7612`, `0e8d:7632`, `0b05:1833`, `0b05:17eb`, `0b05:180b`, `057c:8503`, `7392:b711`, `056e:400a`, `0471:2126`, `0471:7600`, `2c4e:0103`, `0846:9014`, `0846:9053`, `045e:02e6`, `045e:02fe`, and `2357:0137`.

### Realtek

Added: `2026-10`

All of the USB adapters supported by the Linux `rtw88` driver:

* RTL8812AU and RTL8811AU (`rtw8812au`), such as adapters from ASUS, Belkin, Buffalo, D-Link, Edimax, Linksys, Netgear, TP-Link, TRENDnet, and ZyXEL.
* RTL8821AU (`rtw8821au`), such as adapters from D-Link, Edimax, Netgear, and TP-Link.
* RTL8814AU (`rtw8814au`), such as the Alfa AWUS1900.  USB ID `0bda:8813` and the other RTL8814AU IDs.
* RTL8812BU and RTL8822BU (`rtw8822bu`), such as the TP-Link Archer T3U and T4U, ASUS USB-AC55 B1 and USB-AC58, D-Link DWA-181, DWA-182, and DWA-183, Edimax EW-7822ULC, EW-7822UTC, and EW-7822UAD, Linksys WUSB6400M, and Netgear A6150.
* RTL8812CU and RTL8822CU (`rtw8822cu`), such as the D-Link AC13U.
* RTL8811CU and RTL8821CU (`rtw8821cu`), such as adapters from D-Link, Edimax, and Mercusys.
* RTL8723DU (`rtw8723du`), such as the Edimax EW-7611ULB V2.

The Realtek drivers are taken from the Linux kernel `rtw88` driver, with fixes from the out-of-kernel [lwfinger/rtw88](https://github.com/lwfinger/rtw88) driver which replaces the older aircrack-ng Realtek drivers.

The RTL8814AU has been tested on Linux; the other Realtek chipsets, and the Realtek adapters on macOS, use the same driver code but have not been tested yet.  Reports are welcome.

Realtek adapters which can run in USB 3 mode (RTL8812AU, RTL8814AU, RTL8812BU/RTL8822BU, and RTL8812CU/RTL8822CU) stay in USB 2 mode; this is fast enough for capture.

The RTL8814AU and other high-power adapters may need more power than a laptop's USB port supplies; if the adapter starts but captures nothing, or disconnects from the USB bus, try a powered USB hub.

### Bands and channel widths

The available bands, channels, and channel widths are discovered from the driver when the adapter is opened; the MT7921AU, for example, supports 2.4GHz, 5GHz, and 6GHz with channel widths up to 80MHz, and the RTL8814AU supports 2.4GHz and 5GHz up to 80MHz.

## Firmware

The MediaTek and Realtek firmware required by these adapters is included with Kismet, from the [linux-firmware](https://gitlab.com/kernel-firmware/linux-firmware) project, and is installed into the Kismet `share/kismet/firmware` directory (`mediatek/` and `rtw88/`).  The firmware is redistributed under the MediaTek, Ralink, and Realtek licenses included with it.

On Linux, firmware which isn't found in the Kismet directories is loaded from the system firmware directories, in the order the kernel searches them: a directory set with the kernel `firmware_class.path` option, `/lib/firmware/updates/<kernel release>`, `/lib/firmware/updates`, `/lib/firmware/<kernel release>`, then `/lib/firmware`.  Files are found by the names in the [linux-firmware](https://gitlab.com/kernel-firmware/linux-firmware) layout, such as `mediatek/WIFI_RAM_CODE_MT7961_1.bin`, so the distribution's linux-firmware package can be used.

Many distributions install linux-firmware compressed.  Firmware compressed with zstd (`.zst`) or xz (`.xz`) is loaded when Kismet is built with libzstd or liblzma; in each directory, the uncompressed file is used first, then the `.zst` and `.xz` files.

## Compiling USB userspace Wi-Fi support

USB userspace Wi-Fi requires libusb, and is built by default on Linux and macOS when libusb is available.  It can be disabled by passing `--disable-usbwifi` to `./configure`, or forced on for other platforms with `--enable-usbwifi`.

Compressed firmware support uses libzstd and liblzma, when they are available; `./configure` warns if either is missing, and the summary reports which compressions are supported.  Compressed firmware support can be disabled with `--disable-firmware-compression`.

### Linux

On Linux, if the kernel driver (such as `mt7921u`, `mt7925u`, `mt76x2u`, `rtw88_8814au`, or an out-of-kernel Realtek driver) is loaded and has claimed the adapter, Kismet will detach the kernel driver when the source is opened.  When the source closes, the kernel driver is re-attached.

Adapters which combine Wi-Fi and Bluetooth, such as many MT7921AU adapters, are supported: Kismet only takes the Wi-Fi interface from the kernel, and the Bluetooth interfaces stay with the kernel Bluetooth driver, so Bluetooth keeps working while Kismet captures Wi-Fi.

Kismet needs permission to access the USB device; either run the capture tool as root (it is installed suid-root with `make suidinstall`), or grant access to the device with a udev rule.

## Interfaces

USB Wi-Fi adapters are named by the driver and their position on the USB bus: the first MT7921 adapter is `mt7921-0`, the second is `mt7921-1`, the first MT7925 adapter is `mt7925-0`, the first MT7612U adapter is `mt76x2-0`, and the first RTL8814AU adapter is `rtw8814a-0`.  The other Realtek adapters are named the same way: `rtw8812a-0`, `rtw8821a-0`, `rtw8822b-0`, `rtw8822c-0`, `rtw8821c-0`, and `rtw8723d-0`.  Adapters are numbered in USB port order, so the names stay the same if the adapter is unplugged and plugged back into the same port.

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
A directory searched first for the adapter firmware, before the Kismet share directory and, on Linux, the system firmware directories.  This is normally only needed when testing new firmware.
{{</configopt>}}

### Debugging options

{{<configopt verbose true false>}}
Forward informational messages from the driver to the Kismet messages.  By default only driver errors are shown.
{{</configopt>}}
