---
title: "GPS - Serial"
description: ""
lead: ""
date: 2022-09-14T22:57:44-04:00
lastmod: 2022-09-14T22:57:44-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_serial-b76b4c3c264f0a1352b1b7eda0ab140a"
weight: 50
toc: true
---

Kismet can directly use NMEA serial GPS devices, either on a physical serial port or more commonly on a USB-based serial connector.

Kismet can *only* use serial devices which communicate in standard NMEA.  For binary devices, use the `gpsd` GPS driver.

Modern GPSd (a GPS management daemon) typically works well with all GPS units, making the serial driver less important; generally, the `gpsd` GPS type will be more effective.

## Configuration

```
gps=serial:device=/path/to/device
```

To determine the proper path to your GPS unit, look below in the `device` options.

## GPS options

### Common options

{{<configopt name name>}}
Set an arbitrary human-readable name for the GPS.  This will be used in the Kismet GPS logs.
{{</configopt>}}


{{<configopt reconnect true false>}}
Automatically attempt to re-open the GPS if an error occurs or the connection is interrupted.

This is enabled by default.
{{</configopt>}}

### Serial options

{{<configopt device "/path/to/serial/device">}}
Set the path to the serial device the GPS is on.  This is *required*.

The path will vary based on the operating system and type of GPS.  Common paths on Linux may be `/dev/ttyUSB0` or `/dev/ttyACM0`.  Common paths on macOS may be `/dev/cu.usbserial`.

If you are unsure of the USB device for your GPS, consult the output of `dmesg` or `lshw` after plugging it in (Linux), or `ls /dev/cu.*` on macOS.
{{</configopt>}}


{{<configopt baud speed>}}
Set the serial port data rate for the GPS.

By default, this is set to 4800 which is common for most NMEA GPS units.

Many USB serial adapters do not obey the speed rate and silently ignore it.
{{</configopt>}}
