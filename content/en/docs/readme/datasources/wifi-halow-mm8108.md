---
title: "Wi-Fi: HaLow MM8108"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "wifi-halow-mm8108-a90d63960aba451cb3d4f74da237858e"
weight: 145
toc: true
---

Added: `2026-10`

The MM8108 source captures 802.11ah (Wi-Fi HaLow) from USB adapters based on the Morse Micro MM8108 chip, using a userspace driver on top of libusb.  The driver is a port of the Morse Micro Linux driver, reduced to what is needed for monitor mode capture, and runs inside the Kismet capture tool; no kernel driver is needed.

Wi-Fi HaLow operates in the sub-1GHz bands (902-928MHz in the US), with channel widths of 1, 2, 4, and 8MHz.

Kismet will auto-detect MM8108 adapters as `mm8108`, or you may manually specify the type:

```
source=mm8108-0:type=mm8108
```

## Supported hardware

The MM8108 source supports USB adapters based on the Morse Micro MM8108 (USB ID `325b:8100`).

## Firmware

The MM8108 firmware and the board configuration files (BCFs) for Morse Micro and AzureWave modules are included with Kismet, from the Morse Micro [morse-firmware](https://github.com/MorseMicro/morse-firmware) repository, and are installed into the Kismet `share/kismet/firmware/morse` directory.  The firmware is redistributed, complete and unmodified, under the Morse Micro Binary Distribution License Agreement included with it, solely for use with hardware containing Morse Micro Wi-Fi HaLow chips.

The firmware is selected by the chip revision, and the board configuration by the board type stored in the adapter.  Either can be overridden with the `firmware=` and `boardfile=` options.  Board configurations for modules from other vendors which are not included with Kismet can be placed in a directory given with the `firmwaredir=` option.

Some adapters have no board type programmed, or have a board type Kismet doesn't have a board configuration for.  For these, the MM8108 reference module's board configuration included with Kismet, `bcf_mf15457.bin`, is used, with a warning.  Only if it is missing from the Kismet directories does Kismet use the system's choice on Linux: `bcf_default.bin` in the system firmware directories, as with the Morse Micro Linux driver, then the reference module's configuration there.  If the adapter needs a different board configuration, choose it with `boardfile=`.  Board configurations for other Morse Micro chips are refused.

On Linux, files which aren't found in the Kismet directories are loaded from the system firmware directories, in the order the kernel searches them (a directory set with the kernel `firmware_class.path` option, `/lib/firmware/updates/<kernel release>`, `/lib/firmware/updates`, `/lib/firmware/<kernel release>`, then `/lib/firmware`), in the Morse Micro driver's `morse` directory, or in the [linux-firmware](https://gitlab.com/kernel-firmware/linux-firmware) layout for the firmware interface this driver uses, `morsemicro/mm81x/v57`.  The linux-firmware names `mm8108.bin` and `bcf_mm8108_mf15457.bin` are also used.  linux-firmware currently provides firmware interface v56, which this driver can not use; Kismet reports this when it is the only firmware found.

Firmware and board configurations compressed with zstd (`.zst`) or xz (`.xz`) are loaded when Kismet is built with libzstd or liblzma.

## Compiling MM8108 support

MM8108 support requires libusb, and is built by default on Linux and macOS when libusb is available.  It can be disabled by passing `--disable-mm8108` to `./configure`, or forced on for other platforms with `--enable-mm8108`.

Compressed firmware support uses libzstd and liblzma, when they are available; `./configure` warns if either is missing.  It can be disabled with `--disable-firmware-compression`.

### Linux

On Linux, if the Morse Micro kernel driver (`morse_usb`) is loaded and has claimed the adapter, Kismet will detach the kernel driver when the source is opened.

Kismet needs permission to access the USB device; either run the capture tool as root (it is installed suid-root with `make suidinstall`), or grant access to the device with a udev rule.

## Interfaces

MM8108 adapters are named `mm8108-0`, `mm8108-1`, and so on, in USB port order.  The names stay the same if the adapter is unplugged and plugged back into the same port.

Adapters can be listed with:

```bash
$ kismet_cap_mm8108_halow --list
```

The source UUID is generated from the MAC address of the adapter.

## Channels

Channels are 802.11ah channel numbers in the channel plan of the regulatory domain, named the same way Kismet names HaLow channels elsewhere, such as `27ah`.  Each channel number identifies one channel and width; in the US, for example, odd channels are 1MHz, and channels such as `8ah` are 4MHz.

The channel list contains every channel and width in the regulatory domain which the board configuration allows; some boards disable the channels at the edges of the band.

HaLow access points beacon much less often than Wi-Fi access points, and can go nearly 2 seconds between beacons.  The MM8108 source hops channels no faster than once every 2 seconds (`channel_hoprate` is limited to 0.5/sec), so it can see a beacon on each channel; with the 44 channels of the US band, a full pass takes about 90 seconds.  If the channel of a network is known, setting the source to it finds the network immediately:

```
source=mm8108-0:channel=28ah,channel_hop=false
```

## Regulatory domain

The regulatory domain is read from the adapter, if it has one programmed; adapters locked to a domain can not be changed.  Otherwise the domain is set with the `country=` option, and defaults to `US`.

The supported domains are `US`, `CA`, `MX`, `BR`, `NZ`, `AU`, `AR`, `CL`, `CO`, `EU`, `GB`, `IN`, `JP`, `KR`, and `SG`.

## MM8108 source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Regulatory options

{{<configopt country "XX">}}
The regulatory domain to use, if the adapter is not locked to one.  The default is `US`.
{{</configopt>}}

### Channel options

{{<configopt widths "1,2,4,8">}}
Only include channels of the listed widths, in MHz, in the channel list.  For example, `widths=1,2` excludes the 4MHz and 8MHz channels.
{{</configopt>}}

### Firmware options

{{<configopt firmwaredir "/path/to/firmware/dir">}}
A directory searched first for the firmware and board configuration files, before the Kismet share directory and, on Linux, the system firmware directories.  A checkout of the morse-firmware repository can be used directly.
{{</configopt>}}

{{<configopt firmware "firmware file name">}}
Load this firmware file instead of the one chosen by the chip revision, such as `firmware=mm8108b2-rl.bin`.  This is a file name, not a path; the file is found in the firmware directories.
{{</configopt>}}

{{<configopt boardfile "board config file name">}}
Load this board configuration file instead of the one chosen by the board type in the adapter, such as `boardfile=bcf_mf15457.bin`.  This is a file name, not a path; the file is found in the firmware directories.

The firmware and board configuration in use are reported in the Kismet messages when the source opens, and the module the board configuration is for is shown in the source's hardware information.
{{</configopt>}}

### Debugging options

{{<configopt verbose true false>}}
Enable logging from the userspace driver.
{{</configopt>}}

## Limitations

NDP (null data packet) frames, which carry only PHY signal fields rather than an 802.11 frame, are not passed to Kismet.

Packets include radiotap with the S1G radiotap field and the exact channel center frequency, which can be at half-MHz offsets that the standard radiotap channel field can not represent.
