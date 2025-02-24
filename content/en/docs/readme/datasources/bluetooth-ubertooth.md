---
title: "Bluetooth: Ubertooth"
description: ""
lead: ""
date: 2022-08-29T16:57:24-04:00
lastmod: 2022-08-29T16:57:24-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ubertooth-35c8f95aede066448b4dd0420f7612c4"
weight: 210
toc: true
---

The Ubertooth One is an open-source hardware Bluetooth and BTLE sniffer by Great Scott Gadgets.

Kismet must be compiled with support for `libusb`, `libubertooth`, and `libbtbb`; you will need `libusb-1.0-dev`, `libubertooth-dev`, and `libbtbb-dev` (or the equivalents for your distribution), and you will need to make sure that the `Ubertooth` option is enabled in the output from `./configure`.

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## Supported hardware

This datasource works with the [Ubertooth One by Great Scott Gadgets](https://greatscottgadgets.com/ubertoothone/).

The Ubertooth datasource works on Linux and macOS via libUSB and libUbertooth.

## Ubertooth interfaces

The Ubertooth One in Kismet can be referred to as simply `ubertooth`:

```bash
kismet -c ubertooth
```

When using multiple Ubertooth (Uberteeth?) devices, each device is numbered, starting from 0.  The Ubertooth library indexes the devices automatically, and so is dependent on the order the devices were detected.

```bash
kismet -c ubertooth-1
```

Kismet will list available Ubertooth devices automatically in the datasources list.

## Ubertooth source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

## Limitations

The Ubertooth One truncates all packets to a maximum of 50 bytes; packets larger than 50 bytes will be discarded and ignored because it is not possible to validate the checksum.

The Ubertooth One firmware (as of 2019-12) appears to have issues setting channels in BTLE mode, leading to frequent firmware crashes which require the USB device to be removed and re-inserted.  Kismet currently disables channel hopping on the Ubertooth One, and defaults to advertising channel 37.

Alternate channels can be set with the `channel=` source option;

```bash
kismet -c ubertooth:channel=39
```

To try to mitigate firmware hangs, Kismet will reset the U1 device periodically, which will reboot the U1.  This does not prevent all firmware hangs, however, and you may find it necessary to remove and re-insert the Ubertooth One periodically.
