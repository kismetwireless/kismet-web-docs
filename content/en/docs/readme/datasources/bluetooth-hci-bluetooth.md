---
title: "Bluetooth: Linux HCI"
description: ""
lead: ""
date: 2022-08-29T16:48:14-04:00
lastmod: 2022-08-29T16:48:14-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "linux-hci-bluetooth-5227740391f1e9f8ae2c01b4ced99737"
weight: 200
toc: true
---

Kismet can use the generic Linux HCI interface for Bluetooth discovery; this uses a normal Bluetooth adapter to perform *active scans* for discoverable Bluetooth classic and BTLE devices.

This is an **active scan**, not passive monitoring, and reports attributes and advertised information, not packets.

The Linux Bluetooth source will auto-detect supported interfaces by querying the bluetooth interface list.  It can be manually specified with `type=linuxbluetooth`.

The Linux Bluetooth capture uses the 'kismet_cap_linux_bluetooth' tool, and should typically be installed suid-root:  Linux requires root to manipulate the `rfkill` state and the management socket of the Bluetooth interface.

### Example source

```
source=hci0:name=linuxbt
```

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## Supported hardware

For simply identifying Bluetooth (and BTLE) devices, the Linux Bluetooth datasource can use any standard Bluetooth interface supported by Linux.

This includes almost any built-in Bluetooth interface, as well as external USB interfaces such as the Sena UD100.

This datasource is available *only* on Linux.

## Service Scanning

By default, the Kismet Linux Bluetooth data source turns on the Bluetooth interface and enables scanning mode.  This allows it to see broadcasting Bluetooth (and BTLE) devices and some basic information such as the device name, but does not allow it to index services on the device.

Complex service scanning and enumeration will be coming in a future revision.

## Linux HCI Bluetooth source parameters

Linux Bluetooth sources support all the common configuration options such as name, information elements, and UUID.

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.
