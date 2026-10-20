---
title: "AIS - SDR RTLAIS"
description: ""
lead: ""
date: 2026-10-19T22:46:38-04:00
lastmod: 2026-10-19T22:46:38-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ais-sdrrtlais-59b7b2e51593cdd427d6da664fa49c24"
weight: 801
toc: true
---

Added: `2026-10`

Kismet can use the cheap [rtl-sdr](https://www.rtl-sdr.com) software defined radio to receive AIS from ships, base stations, aids to navigation, and search and rescue aircraft.

The SDR RTLAIS source can autodetect rtl-sdr devices automatically, and can be manually specified with `type=rtlais`:
```
source=rtlais-0:type=rtlais
```

## AIS

AIS, the Automatic Identification System, is the international standard maritime identification and tracking system.  AIS transmitters broadcast their identity (the MMSI), location, speed, course and heading, and, for vessels, the ship name, callsign, type, dimensions, destination and ETA.

AIS uses two channels, 161.975MHz (channel A) and 162.025MHz (channel B).  The SDR RTLAIS source tunes between them, to 162MHz, and receives both channels at once, so it doesn't hop.

Kismet tracks each AIS station as a device, by its MMSI:

* Class A and class B vessels, with position, speed, course, heading, rate of turn, navigation status, and the static and voyage data the vessel sends (name, callsign, IMO number, ship type, dimensions, draught, destination, ETA)
* Base stations, with the UTC time they report
* Aids to navigation (AtoN), including virtual aids and aids off position
* Search and rescue aircraft, with altitude
* AIS-SART, man-overboard, and EPIRB emergency beacons

The country of each station is derived from the maritime identification digits of its MMSI.  Positions reported by AIS stations are used as the device location.

## AIS tools

Received AIS messages are available as NMEA `AIVDM` sentences over a websocket, for use with OpenCPN and other AIS tools.  See the [AIS API](/docs/api/ais/) for details.

## Supported hardware

The RTL-SDR is a repurposed digital TV tuner which functions as an extremely cheap SDR, or software defined radio.  A SDR is required for tuning to the AIS frequencies and capturing raw radio sample data.

The Kismet implementation of AIS decoding is tightly coupled to the RTL-SDR hardware, and will not currently work with other SDR hardware.

AIS is a VHF signal; an antenna tuned for 162MHz, mounted as high as possible, makes a large difference to how far away stations can be received.

## SDR RTLAIS interfaces

Kismet identifies RTL-SDR hardware by either the serial number (if any) or by the radio position; for example:

The first RTL-SDR radio in the system, to be used for rtlais:

```
source=rtlais-0
```

A specific RTL-SDR radio (if serial numbers are available):

```
source=rtlais-324452324332
```

Not all RTL-SDR hardware populates the serial number field, and some hardware ships with a default serial number of `0`.  Serial numbers can be found using the standard rtlsdr tools, like `rtl_test`.

### Multiple RTL-SDR devices

Every datasource in Kismet must have a unique identifier, the source UUID.  Kismet calculates this using the serial number of the RTL-SDR device.

When using multiple RTL-SDR radios which don't report unique serial numbers, either assign each one a serial number with the `rtl_eeprom` tool, or set the `uuid=...` parameter on each Kismet source definition.

## SDR RTLAIS source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Radio control options

{{<configopt gain "value">}}
Specify a fixed gain level for the radio; by default, the hardware automatic gain control is used.
{{</configopt>}}

{{<configopt ppm "error_value">}}
Specify a PPM error offset for your radio.  The AIS channels are only 25kHz either side of the tuned frequency, so correcting a known frequency error matters more for AIS than for most other signals.
{{</configopt>}}

{{<configopt biast true false>}}
Enable bias-tee power on supported radios, to power an external amplifier or other equipment in the antenna chain.  This requires a version of librtlsdr with bias-tee support.
{{</configopt>}}

{{<configopt biastgpio "gpio">}}
Enable bias-tee power using a specific GPIO on the radio.  This requires a version of librtlsdr with bias-tee GPIO support.
{{</configopt>}}

{{<configopt uuid "uuid">}}
Set the source UUID, when multiple radios don't report unique serial numbers.
{{</configopt>}}
