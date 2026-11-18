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

After 2026-10-R1, a Radiacode is named by its serial number, `radiacode-usb-<serial>`, which stays the same however it is plugged in.  With only one Radiacode connected, plain `radiacode` finds it:

```bash
kismet -c radiacode:name=radiacode
```

With more than one, name each by its serial; `kismet_cap_radiacode_usb --list` and the datasources list in the web UI show the names to use:

```bash
kismet -c radiacode-usb-RC-102-000123
```

The older names still work: the order the system found the devices in (`radiacode-usb-0`, `radiacode-usb-1`, etc) and the USB bus and device (`radiacode-usb-1-8` for example).  Both can change when a device is plugged in again or others are added, so Kismet suggests the serial name when they are used.

The source's UUID comes from the serial number, so a Radiacode keeps its UUID, and its history in the logs, between runs.

Kismet will automatically list Radiacode devices in the datasources list.

## Supported hardware

The Radiacode source requires the Radiacode Geiger counter hardware, connected via USB.

The Radiacode is a modern Geiger counter which can report counts per second and dosage rates.

## What Kismet reads

Kismet only reads from the Radiacode; it never changes its settings.

* The count rate (counts per second) and dose rate, about once a second, with their statistical error.
* The accumulated dose the device has counted, its temperature, and its battery level, when the device reports them.
* After 2026-10-R1, the gamma energy spectrum the device has accumulated, with its energy calibration, every 10 seconds by default (see `spectrum_interval` below).  Kismet keeps the spectrum since it started, the past hour, and each of the last 60 minutes.

After 2026-10-R1, the newer data format of Radiacode firmware 4.15 is supported, as well as older firmware.

## Viewing

In the new web UI, after 2026-10-R1, the [Radiation window](/docs/readme/webui/webui_intro/#radiation-window) shows the readings, their history, and the spectrum; the top bar has count and dose rate stats, and the *Overview* tab has *Radiation* and *Radiation spectrum* cards.

In the older web UI, realtime radiation data can be viewed in the `Radiation` panel, or enabled in the top status bar via the `Settings` panel.

The data is also available from the [radiation API](/docs/api/radiation/).

## Logging

Radiation data is logged in the [kismetdb](/docs/readme/logging/kismetdb/) log as JSON records: each reading from the Radiacode in the `data` table, and in the `snapshots` table, with the GPS location when there is a fix, `RADIATION` snapshots of the sensors and, after 2026-10-R1, a `RADIATION_SPECTRUM` snapshot of each finished minute's spectrum.  Once development is complete, it will be logged in [pcapng](/docs/readme/logging/pcap/) as a custom packet block.

## Stability

The Radiacode hardware appears to have a slightly fragile USB implementation.  While *typically* this is not a problem, on some occasions, initializing the device over USB can cause the USB implementation on the Radiacode to crash.

If this happens, the Radiacode will no longer respond on USB; to fix this, disconnect the Radiacode from USB, power the device off using the buttons and LCD interface, then power it back on and connect to USB again.

The Radiacode hands each reading to only one reader.  While the Radiacode phone app is connected over Bluetooth, it takes some of the readings, and Kismet's history shows gaps.

## Radiacode source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### spectrum_interval

After 2026-10-R1, how often, in seconds, Kismet reads the spectrum from the Radiacode.  Defaults to `10`; can be up to `3600`, and `0` turns off reading the spectrum.

```bash
kismet -c radiacode:spectrum_interval=30
```

