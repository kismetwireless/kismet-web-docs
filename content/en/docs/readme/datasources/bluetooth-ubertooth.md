---
title: "Bluetooth: Ubertooth"
description: ""
lead: ""
date: 2022-08-29T16:57:24-04:00
lastmod: 2026-11-02T00:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ubertooth-35c8f95aede066448b4dd0420f7612c4"
weight: 210
toc: true
--- 

The Ubertooth One is an open-source hardware Bluetooth and BTLE sniffer by Great Scott Gadgets.

Kismet uses it in one of two modes: BTLE advertising capture (the default), or a survey of classic Bluetooth (BR/EDR) piconets with `mode=classic`.

Kismet must be compiled with support for `libusb`, `libubertooth`, and `libbtbb`; you will need `libusb-1.0-dev`, `libubertooth-dev`, and `libbtbb-dev` (or the equivalents for your distribution), and you will need to make sure that the `Ubertooth` option is enabled in the output from `./configure`.

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## Supported hardware

This datasource works with the [Ubertooth One by Great Scott Gadgets](https://greatscottgadgets.com/ubertoothone/).

The Ubertooth datasource works on Linux and macOS via libUSB and libUbertooth.


## Ubertooth interfaces

The first Ubertooth One is `ubertooth-0`:

```bash
kismet -c ubertooth-0
```

When using multiple Ubertooth (Uberteeth?) devices, each device is numbered, starting from 0.  The Ubertooth library indexes the devices automatically, and so is dependent on the order the devices were detected.

```bash
kismet -c ubertooth-1
```

Kismet will list available Ubertooth devices automatically in the datasources list.

## Ubertooth source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### mode

`mode=btle` (the default) captures BTLE advertisements.  `mode=classic` (Kismet 2026-10-R1 and newer) surveys classic Bluetooth (BR/EDR) piconets instead:

```bash
kismet -c ubertooth-0:mode=classic
```

Any other value is an error and the source won't open.

### channel

In BTLE mode, `channel=` takes a BTLE channel (0-39) or a frequency in MHz (an even value from 2402 to 2480).  The default is advertising channel 37.

In classic mode, `channel=` takes a classic channel (0-78) or a frequency in MHz (2402 to 2480).  The default is 2441MHz.  Piconets hop across all 79 channels, so a single channel is enough to see them, but only about one in 79 of a piconet's packets is heard.

```bash
kismet -c ubertooth-0:mode=classic,channel=2441
```

## Classic Bluetooth piconets

In classic mode the Ubertooth listens for the access code at the start of each baseband packet.  The access code carries the LAP, the lower 24 bits of the address of the piconet's master; the UAP (the next 8 bits) can be worked out from the packet headers over time, and the NAP (the top 16 bits) is never sent over the air.

Kismet creates one `BR/EDR` device per piconet:

* It is keyed on the LAP, as `00:00:00:<LAP>`, so working out the UAP later doesn't create a new device.
* The device is named `Piconet <LAP>`.
* The partial address is shown as `??:??:??:<LAP>`, and as `??:??:<UAP>:<LAP>` once the UAP is known.
* Packets, signal, frequency, location and seen-by are tracked as for other devices.

Inquiry access codes (a host searching for devices, LAPs `9E8B00` to `9E8B3F`) are ignored.

This is a survey of piconet activity.  Kismet doesn't follow a connection's hopping pattern, doesn't identify the slave devices in a piconet, and doesn't decrypt anything.

Classic packets are logged with the `LINKTYPE_BLUETOOTH_BREDR_BB` (255) link type, which Wireshark shows as "Bluetooth BR/EDR Baseband RF".  Each logged packet holds only the pseudo-header (channel, signal, noise, LAP and the UAP once known); the baseband header and payload are not included.  BTLE packets are converted to the BTLE radio link type on the host.

## Limitations

In BTLE mode, the Ubertooth One truncates all packets to a maximum of 50 bytes; packets larger than 50 bytes will be discarded and ignored because it is not possible to validate the checksum.

The Ubertooth One firmware (as of 2019-12) appears to have issues setting channels in BTLE mode, leading to frequent firmware crashes which require the USB device to be removed and re-inserted.  Kismet disables channel hopping on the Ubertooth One, and in BTLE mode defaults to advertising channel 37.

Alternate channels can be set with the `channel=` source option;

```bash
kismet -c ubertooth-0:channel=39
```

To try to mitigate firmware hangs in BTLE mode, Kismet resets the U1 every 30 seconds, which reboots the U1.  This does not prevent all firmware hangs, however, and you may find it necessary to remove and re-insert the Ubertooth One periodically.

