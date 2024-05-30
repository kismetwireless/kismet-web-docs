---
title: "Radiation: Radiacode"
description: ""
lead: ""
date: 2024-04-21T20:05:49-04:00
lastmod: 2024-04-21T20:05:49-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "radiacode-f7aafe045d2e0320c3d31bd930c25078"
weight: 999
toc: true
---

Added: `2024-04`

Kismet can collect environmental radiation data for display and logging from the [Radiacode](https://radiacode.com) Geiger counter.

The Radiacode is capable of reporting counts-per-second (CPS), dosage (sieverts), and an energy spectrogram which may be useful in identifying the elements involved.

## !! WARNING !!!

Kismet interfaces with environmental sensors, including Geiger Counter / Radiation detection devices because they are interesting.  **NEVER** rely on the radiation exposure data presented by Kismet for personal safety!

**Always** consult the documentation for your Geiger counter.  Different Geiger counter hardware is sensitive to different energy levels of radiation.

The location of your detector, the type of detection hardware, and the speed at which you are travelling can all impact

## Compiling Radiacode support

Radiacode support in Kismet requires libUSB.  The Radiacode sources will be compiled when libUSB is available at configure time.

## Radiacode sources

The Radiacode device is identified `radiacode-usb-#`; for a single Radiacode it can be identified simply as `radiacode-usb-0`:

```bash
kismet -c radiacode-usb-0:name=radiacode
```

If using multiple Radiacode devices, they can be specified either in the order they were enumerated by the system, (`radiacode-usb-0`, `radiacode-usb-1`, etc) or by the USB path based on bus and port number (`radiacode-usb-1-8` for example).  Please note that the USB path identification may be subject to change if USB devices are moved, new devices added, etc.

For finding the USB location, consult the output of `kismet_cap_radiacode_usb --list`.

Kismet will automatically list Radiacode devices in the datasources list.

## Supported hardware

The Radiacode source requires the Radiacode Geiger counter hardware, connected via USB.

The Radiacode is a modern Geiger counter which can report counts per second and dosage rates.

## Viewing

Realtime radiation data can be viewed in the Web UI in the `Radiation` panel, or enabled in the top status bar via the `Settings` panel.

## Logging

Radiation data is logged in the [kismetdb](/docs/readme/logging/kismetdb/) log as JSON records in the `snapshots` and `data` tables.  Once development is complete, it will be logged in [pcapng](/docs/readme/logging/pcap/) as a custom packet block.

## Stability

The Radiacode hardware appears to have a slightly fragile USB implementation.  While *typically* this is not a problem, on some occaisons, initializing the device over USB can cause the USB implementation on the Radiacode to crash.

If this happens, the Radiacode will no longer respond on USB; to fix this, disconnect the Radiacode from USB, power the device off using the buttons and LCD interface, then power it back on and connect to USB again.

## Radiacode source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

