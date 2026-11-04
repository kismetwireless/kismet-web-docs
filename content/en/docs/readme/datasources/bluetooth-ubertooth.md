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

After 2026-10-R1, the name is `ubertooth` (the first device), `ubertoothN`, or `ubertooth-N`, and opening it checks the number against the devices attached; with more than one Ubertooth, a bare `ubertooth` is turned down and the source must be numbered.  Before then, `ubertooth-N` above 0 failed with more than one device attached.  The fix changes the UUID of `ubertooth-N` sources numbered 1 and up, so a source pinned by UUID needs its new UUID.

Kismet will list available Ubertooth devices automatically in the datasources list.

## BTLE and classic modes

Since Kismet 2026-10-R1, an Ubertooth source runs in one of two modes, set with `mode=`:

* `btle` (the default) captures Bluetooth LE packets, as before.
* `classic` surveys classic (BR/EDR) Bluetooth piconets.

```bash
kismet -c ubertooth:mode=classic
```

A source captures in one mode; to watch both, use two Ubertooth devices, such as `ubertooth-0:mode=btle` and `ubertooth-1:mode=classic`.

### Classic piconets

Classic Bluetooth hops across 79 channels, 1600 times a second, and its packets don't carry the full address of the devices sending them.  In classic mode the Ubertooth listens on one channel and finds the access code at the start of each packet, which holds the lower address part (LAP) of the piconet's master: the last three octets of its address.  Over time, the upper address part (UAP), one more octet, is worked out from the packet headers.  The first two octets of the address (the NAP) are never sent, so they can't be found this way.  This is the same survey `ubertooth-rx -z` does.

Each piconet becomes a Bluetooth device:

* It is keyed by its LAP, as `00:00:00:LL:LL:LL`, so working out the UAP doesn't make a new device.
* It is named `Piconet LLLLLL`, with the type `BR/EDR` and an unknown manufacturer, since the NAP holds the manufacturer's OUI.
* `bluetooth.device.partial_address` holds the part of the address known, with the unknown octets as `??`: `??:??:??:LL:LL:LL`, then `??:??:UU:LL:LL:LL` once the UAP is found.  The new web UI shows it as *Partial address*.
* The signal, frequency, packet count, and location are recorded as for other devices.

Packets using the general and dedicated inquiry access codes are hosts searching for devices, not piconets, and are ignored.  The packets are logged with link type 255 (`LINKTYPE_BLUETOOTH_BREDR_BB`), which Wireshark decodes.

Piconets hop across every channel, so one channel is enough to find them.  A classic source listens on 2441 MHz (channel 39) unless `channel=` sets another, as a classic channel number from 0 to 78 or a frequency from 2402 to 2480 MHz, and is not channel hopped.

Classic mode finds piconets which are active: devices connected to each other and exchanging packets.  A device which isn't connected to another is rarely seen this way; the [Linux HCI source](/docs/readme/datasources/bluetooth-hci-bluetooth/) finds those by scanning.

## Ubertooth source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Mode and channel options

{{<configopt mode btle classic>}}
`btle` (the default) captures Bluetooth LE; `classic` surveys classic Bluetooth piconets; see [BTLE and classic modes](#btle-and-classic-modes).
{{</configopt>}}

{{<configopt channel channel>}}
The channel to listen on.  In BTLE mode, a BTLE channel from 0 to 39, or a frequency in MHz; 37 by default.  In classic mode, a classic channel from 0 to 78, or a frequency from 2402 to 2480 MHz; 2441 MHz by default.
{{</configopt>}}

## Limitations

The Ubertooth One truncates all packets to a maximum of 50 bytes; packets larger than 50 bytes will be discarded and ignored because it is not possible to validate the checksum.

The Ubertooth One firmware (as of 2019-12) appears to have issues setting channels in BTLE mode, leading to frequent firmware crashes which require the USB device to be removed and re-inserted.  Kismet currently disables channel hopping on the Ubertooth One, and defaults to advertising channel 37.

Alternate channels can be set with the `channel=` source option;

```bash
kismet -c ubertooth:channel=39
```

To try to mitigate firmware hangs, Kismet will reset the U1 device periodically, which will reboot the U1.  This does not prevent all firmware hangs, however, and you may find it necessary to remove and re-insert the Ubertooth One periodically.

