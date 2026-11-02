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

BLE service data from advertisements is passed to Kismet, which allows detecting Open Drone ID / Remote ID broadcasts from drones (see [Open Drone ID](/docs/readme/datasources/drone-opendroneid/)).  Linux de-duplicates repeated advertisements while scanning, so position updates from a drone may be reported less often than they are transmitted.

Location trackers, advertised battery levels, and the transmit power used to estimate distance are also decoded from the advertisements the HCI source reports; see [Bluetooth trackers, battery, and distance](/docs/readme/datasources/bluetooth-trackers/).

## BTLE and classic devices

After 2026-10-R1, the LE devices the HCI source reports are BTLE devices: the same device record a BTLE sniffer (such as the WCH BLE Analyzer, nRF, or Sniffle) makes for the same address, decoded the same way, with every source which saw it listed in the device's seen-by sources.  LE advertising reports in HCI packet captures are handled the same way.  Classic (BR/EDR) devices from inquiry scans remain Bluetooth devices.

Before then, a device heard by both an HCI source and a BTLE sniffer appeared twice, once as a Bluetooth device and once as a BTLE device.

When a host connects to an LE device and reads its controller information, either in an HCI capture or by the HCI source's opt-in active probing, it is added to the BTLE device:

| Field | Contents |
| ----- | -------- |
| `btle.device.lmp_version` | Bluetooth version of the device's controller |
| `btle.device.chip_manufacturer` | Maker of the controller, and its company ID |
| `btle.device.lmp_subversion` | Controller firmware subversion, specific to its maker |
| `btle.device.le_features` | LE feature mask read from the device, in hex |
| `btle.device.last_probed` | Last time active probing connected to the device |

These are only recorded for a device which has been seen advertising.

## Linux HCI Bluetooth source parameters

Linux Bluetooth sources support all the common configuration options such as name, information elements, and UUID.

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Scanning

After 2026-10-R1, the HCI source can scan with only some of the controller's radios.  Scanning is passive in every mode.

{{<configopt scan both le bredr>}}
`both` (the default) scans for LE and classic (BR/EDR) devices, `le` for LE advertisements only, and `bredr` for classic devices only.  A controller without one of the radios asked for scans with what it has.

```
source=hci0:name=linuxbt,scan=le
```
{{</configopt>}}

The source reports the mode asked for as `kismet.datasource.linuxbt.scan` (`both`, `le`, or `bredr`), and what the controller is scanning with as `kismet.datasource.linuxbt.scan_active` (`both`, `le`, `bredr`, or `none` when the controller supports neither).

### Active probing

After 2026-10-R1, the HCI source can ask the devices it hears for more information.  Probing makes the source transmit, and devices may log or show the connection, so it is off unless turned on.

{{<configopt probe off name info>}}
`off` (the default) only listens.  `name` asks classic (BR/EDR) devices for their names.  `info` also connects to devices to read their Bluetooth version, chip maker, and features, which are added to the [device](#btle-and-classic-devices).

```
source=hci0:name=linuxbt,probe=info
```
{{</configopt>}}

{{<configopt probe_interval seconds>}}
How long before the same device is probed again, from 60 to 86400 seconds; 600 by default.
{{</configopt>}}

### Changing them while the source runs

`scan`, `probe`, and `probe_interval` can also be changed while the source runs, from the source in the web UI's *Data sources* window:

* *Scanning*, *Scan for* picks the scan mode, and warns when the controller can't scan with everything asked.
* *Active probing* picks the probe mode, says what the source will transmit, and asks before probing is turned on.  It also sets the interval, and shows how many devices have been probed, how many are waiting, and the last probe.

Changes made while the source runs last until it re-opens; options on the source line keep them.

