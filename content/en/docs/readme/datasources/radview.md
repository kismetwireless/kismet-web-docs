---
title: "Radiation: Radview"
description: ""
lead: ""
date: 2024-04-21T23:45:03-04:00
lastmod: 2024-04-21T23:45:03-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "radview-17b0517b64f49ad2baf8d3a0575547fb"
weight: 999
toc: true
---

Added: `2024-04`

Kismet can collect environmental radiation data for display and logging from the [Radview](https://www.radviewdetection.com/) Geiger counter, when coupled with an Arduino or similar microcontroller running the appropriate firmware.

The Radview is capable of reporting counts-per-second (CPS) and an energy spectrogram, however there are some significant limitations.

As of 2024-04, the Radview team has not released calibration data for the sensor used.  The Radview reports counts-per-second, but without calibration data for the sensors used, this can not be converted to dosage rates (sieverts or other).

While the Radview reports energy levels as a spectrogram, the sensor is not calibrated, and no universal calibration data exists.  As such, the spectrum data is likely not scaled correctly and can not be relied on.

## !! WARNING !!!

Kismet interfaces with environmental sensors, including Geiger Counter / Radiation detection devices because they are interesting.  **NEVER** rely on the radiation exposure data presented by Kismet for personal safety!

**Always** consult the documentation for your Geiger counter.  Different Geiger counter hardware is sensitive to different energy levels of radiation.

The location of your detector, the type of detection hardware, and the speed at which you are travelling can all impact

## Compiling Radview support

Radview support is build automatically in Kismet releases after `2024-04` git code.  Kismet interfaces with the Radview via a serial connection on an Arduino or similar device.

## Radview sources

The Radview device is identified as `radview-#`; Additionally, Radview devices *must* include the `device` option with the serial port interface of the Arduino.

```bash
kismet -c radview-0:name=radview,device=/dev/ttyUSB0
```

## Supported hardware

The Radview source requires the Radview Geiger counter hardware, connected via a microcontroller running the appropriate firmware.

Example firmware for an Arduino style microcontroller is in [in the Kismet git repository](https://github.com/kismetwireless/kismet/blob/master/capture_serial_radview/radview-json.ino).  When selecting a microcontroller, *be sure that it supports 5v I/O*. A 3 volt microcontroller will not work with the Radview!

## Radview source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device selection

{{<configopt device "/path/to/serial/device">}}
The Arduino appears as a serial device on the system.

You *must* provide the path to the serial device associated with the Radview.
{{</configopt>}}

{{<configopt baud "baudrate">}}
Baudrate of the serial interface; by default this should be `1000000`.  This should only be changed if the firmware running on the Arduino is changed.
{{</configopt>}}


