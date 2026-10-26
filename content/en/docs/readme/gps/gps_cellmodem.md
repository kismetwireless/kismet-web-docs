---
title: "GPS - Cell modem"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_cellmodem-92d90417d641a64103201225f400fc3a"
weight: 80
toc: true
---

Added: `2026-10`

Many Quectel cell modems include a GNSS receiver.  Kismet can use it as a GPS through the [cell AT](/docs/readme/datasources/cell-at/) source which holds the modem.

The `cellmodem` GPS doesn't open a device itself: the cell AT source opens the modem's NMEA port and forwards the sentences to it.  The GPS is idle until that source opens, and goes idle again when the source closes.

## Configuration

Name the GPS in the cell AT source definition:

```
source=cellat-<imei>:gps=modem
```

`gps=true` names the GPS after the source.  If no GPS with that name exists, the source creates a `cellmodem` GPS of that name.

The GPS can also be declared in `kismet.conf` or `kismet_site.conf`, so that it exists, with its priority, before the source opens:

```
gps=cellmodem:name=modem,priority=-500
```

Give each modem its own GPS name; a cellmodem GPS takes its location from one source, and ignores a second source which names the same GPS.

## Opening the GNSS

When the source opens, it checks the modem's GNSS (`AT+QGPS?`).  If the GNSS is off, the source turns it on (`AT+QGPS=1`), and turns on the USB NMEA output if it is off (`AT+QGPSCFG="outport","usbnmea"`).  When the source closes, the GNSS and the NMEA output are put back the way they were found.

The source then opens the modem's NMEA port:

* For a modem on Linux serial ports, the NMEA interface of the same USB device (interface 1 on the EG25-G, RM500Q, and RM520N-GL).
* For a `/dev/wwan<N>at0` AT port, the `/dev/wwan<N>nmea0` port beside it.
* For a modem reached [over libusb](/docs/readme/datasources/cell-usb/), its NMEA interface.

If the NMEA port isn't found, name it with the `gpsport=` source option:

```
source=cellat-<imei>:gps=modem,gpsport=/dev/ttyUSB1
```

The NMEA port is read separately from the AT commands, so the GNSS and the cell polling don't wait on each other.  A GNSS failure (a modem with no GNSS, a refused `AT+QGPS=1`, no NMEA port) is reported as a warning, and the cell capture keeps running.

Only Quectel modems are supported; on other modems `gps=` reports a warning and the GNSS isn't used.

## Priority

Kismet uses the GPS with the best (lowest) priority which has a location.  A cellmodem GPS defaults to priority `-500`: behind a dedicated GPS (`serial`, `gpsd`, and `tcp` default to `-1000`), and ahead of the `web`, `meta`, and `virtual` GPS (`0`).  A modem GNSS is often less accurate than a dedicated receiver, so a dedicated GPS is used when one is present.

The cell observations from the source which feeds the GPS are tagged with that modem's GNSS location once the modem has reported one, even when another GPS has a better priority.

## GPS options

### Common options

{{<configopt name name>}}
The GPS name, which the cell AT source refers to with `gps=<name>`.  Names may use letters, digits, `-`, `_`, and `.`, up to 64 characters.
{{</configopt>}}

{{<configopt priority priority>}}
The GPS priority; lower is preferred.  The default is `-500`.
{{</configopt>}}
