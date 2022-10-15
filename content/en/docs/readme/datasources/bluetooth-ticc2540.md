---
title: "Bluetooth: TI-CC-2540"
description: ""
lead: ""
date: 2022-09-03T10:48:10-04:00
lastmod: 2022-09-03T10:48:10-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ticc2540-557c20d2cd7d44af315bee89e28dee85"
weight: 220
toc: true
---

The Texas Instruments CC2540 is a chip used for Bluetooth communications.  To use it with Kismet, it must be flashed with the sniffer firmware [provided by TI](http://www.ti.com/tool/PACKET-SNIFFER).  Often the devices are available with the sniffer firmware pre-flashed.

Kismet must be compiled with support for `libusb` to use TICC2540; you will need `libusb-1.0-dev` (or the equivalent for your distribution), and you will need to make sure that the `TI CC 2540` option is enabled in the output from `./configure`.

To use the TI CC2540 capture, you must have a TI CC2540 dongle flashed with the sniffer firmware. You can flash this yourself with a CC-Debugger or purchase one online from many retailers.

*Note*: It seems that while many CC2540 devices are *advertised* as pre-flashed with the sniffer firmware, they appear not to be!

## Bluetooth
Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## Supported hardware

Any USB device based on the CC2540 chip, and flashed with the TI sniffer firmware, should work.  Beware!  Many online vendors sell identical-looking devices based on the CC2531 chip, which is *not* the same thing!

The TI-CC-2540 source works on Linux and macOS via the libUSB library.

## TI CC2540 interfaces

TI CC2540 datasources in Kismet can be referred to as simply `ticc2540-...`:

```bash
kismet -c ticc2540-0
```

When using multiple TICC devices, they can be specified either in order discovered by the system (`ticc2540-0`, `ticc2540-1`, etc), or by USB path.  If you need to know which specific device is being configured, use the USB path - however, this path may be subject to change if USB devices are moved, new USB devices added, etc.

To find available TICC devices, use:

```bash
kismet_cap_ti_cc_2540 --list
```

Kismet will also list available TI CC2540 devices automatically in the datasources list.

The position of USB devices may change if more devices are added or if devices are removed.

## TI CC2540 concerns

The sniffer firmware in the TI CC2540 sometimes goes into a permanent error state until the device is physically re-initialized - by disconnecting it from USB and reconnecting it.  

Unfortunately, there does not seem to be any way to automate this process, as once the device enters an error state, it will remain in that state and cannot be reinitialized over USB.

Connecting the CC2540 device to a USB port with programmable power control may provide a way to power it off without physically disconnecting it.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

