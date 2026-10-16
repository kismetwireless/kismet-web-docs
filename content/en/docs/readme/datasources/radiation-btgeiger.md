---
title: "Radiation: Bluetooth Geiger"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "radiation-btgeiger-693452c817224f8aa301caaf741d61bf"
weight: 998
toc: true
---

Added: `2021-07`

The Bluetooth Geiger source reads radiation data from a custom Bluetooth LE Geiger counter, connected over BLE GATT.

## !! WARNING !!!

Kismet interfaces with environmental sensors, including Geiger Counter / Radiation detection devices because they are interesting.  **NEVER** rely on the radiation exposure data presented by Kismet for personal safety!

## Status

The Bluetooth Geiger source is incomplete:

* The capture tool is not currently built or installed by the Kismet build.
* Readings from the source are logged, but are not yet shown in the Kismet radiation display.

For supported Geiger counters, see the [Radiacode](/docs/readme/datasources/radiacode/) and [Radview](/docs/readme/datasources/radview/) sources.

## Supported hardware

The source works with a Bluetooth LE Geiger counter providing a GATT service (`db058fb8-776a-45a9-a5b4-cdefbbdfacc3`) with counts-per-second, counts-per-minute, and microsieverts-per-hour characteristics.

## Compiling Bluetooth Geiger support

The Bluetooth Geiger capture tool is written in Python, and requires the `bluepy`, `protobuf`, and `websockets` Python modules.  It is enabled with `--enable-btgeiger`, which also requires `--enable-python-tools`.

## Bluetooth Geiger sources

Bluetooth Geiger sources are named `btgeiger`, and must include the `device` option with the Bluetooth MAC address of the Geiger counter:

```bash
kismet -c btgeiger:device=AA:BB:CC:DD:EE:FF,uuid=...
```

Set a fixed UUID with the `uuid` option; the UUID generated from the MAC address is not valid.

## Bluetooth Geiger source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device options

{{<configopt device "AA:BB:CC:DD:EE:FF">}}
The Bluetooth MAC address of the Geiger counter.  This option is required.
{{</configopt>}}

{{<configopt debug true false>}}
Print each reading from the Geiger counter.
{{</configopt>}}

## Logging

Readings are logged in the [kismetdb](/docs/readme/logging/kismetdb/) log `data` table, as `radiation` records with the counts per second, counts per minute, and microsieverts per hour.
