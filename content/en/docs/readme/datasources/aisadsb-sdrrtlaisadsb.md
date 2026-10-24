---
title: "AIS and ADSB - SDR RTLAISADSB"
description: ""
lead: ""
date: 2026-10-24T10:50:00-07:00
lastmod: 2026-10-24T10:50:00-07:00
images: []
menu:
  docs:
    parent: ""
    identifier: "aisadsb-sdrrtlaisadsb-4f1d2b7c9e0a4a66b1c3d5e7f9a1b3c5"
weight: 802
toc: true
---

Added: `2026-10`

Kismet can use a single [rtl-sdr](https://www.rtl-sdr.com) software defined radio to receive both [AIS](/docs/readme/datasources/ais-sdrrtlais/) from ships and [ADSB](/docs/readme/datasources/adsb-sdrrtladsb/) from aircraft, by tuning back and forth between the two.

The same rtl-sdr radio can be used by the rtlais, rtladsb, and rtlaisadsb sources; the interface name picks which one, and the source can also be specified with `type=rtlaisadsb`:
```
source=rtlaisadsb-0:type=rtlaisadsb
```

## Sharing one radio

AIS is broadcast around 162MHz and ADSB at 1090MHz, too far apart for one rtl-sdr to receive at once.  The SDR RTLAISADSB source alternates between them, spending a *dwell* on each band before retuning.

Anything sent on a band while the radio is on the other band is missed, so each band hears roughly its share of the time.  If you have two rtl-sdr radios, using one [rtlais](/docs/readme/datasources/ais-sdrrtlais/) and one [rtladsb](/docs/readme/datasources/adsb-sdrrtladsb/) source will always receive more than one combined source.

This is a compromise: For total coverage, it's always better to have two radios, dedicated to each frequency.  Since ADSB and AIS are both relatively low bandwidth and long-term events (it's unlikely a plane or boat would enter and exit your coverage in under 20 seconds), this gives a chance to see both when only a single radio is available.

Though hopping is adaptive between the bands, if you are not near an ocean or other environment with AIS data, you're much better off using the dedicated ADSB scanner.

### Channels

The source has two channels, `AIS` and `ADSB`.  Setting the channel of the source, in the web UI or with the datasource API, locks the radio on that band.  Turning channel hopping back on returns to alternating between them.

### Adaptive hopping

By default the source sizes its dwells from what it is hearing (`hop_mode=adaptive`):

* An aircraft position is only usable once Kismet has heard both an even and an odd position message from it within 10 seconds.  The ADSB dwell is sized so the typical aircraft sends about three positions in one dwell: with strong reception this can be as short as a second, and with distant or weak aircraft it grows to as long as 20 seconds.
* The two bands split the time evenly.  Giving more time to the busier band was tested against recorded traffic, and only moved coverage from one band to the other.  A band with no stations at all drops to a quarter of the time, so new stations on it are still found.
* Every dwell is varied at random by up to 20%.  AIS stations transmit in fixed time slots each minute, and a perfectly regular hop schedule can line up with them and miss the same ships every time.

When the adaptive plan changes noticeably the source reports the new dwells in the Kismet messages, at most once a minute.

### Fixed hopping

With `hop_mode=fixed`, the source uses the `ais_dwell` and `adsb_dwell` times instead, still varied by up to 20% for the same reason.

## Supported hardware

The SDR RTLAISADSB source uses the same RTL-SDR hardware as the [rtlais](/docs/readme/datasources/ais-sdrrtlais/) and [rtladsb](/docs/readme/datasources/adsb-sdrrtladsb/) sources, and will not currently work with other SDR hardware.

AIS and ADSB use very different frequencies; an antenna for one will usually work poorly for the other.  A wideband antenna, or a dual-band antenna for 162MHz and 1090MHz, gives the best results.

Typically you'll find more success including something like a FM blocker to exclude the FM radio station bands; FM radio tends to be very loud and swamp everything else.

## Signal levels

Both bands report the signal level of each message, in dB relative to the full scale of the radio (dBFS).  This is a relative level, useful for comparing stations and antennas, not a calibrated power; it changes with the gain setting.

## SDR RTLAISADSB interfaces

Kismet identifies RTL-SDR hardware by either the serial number (if any) or by the radio position; for example:

The first RTL-SDR radio in the system:

```
source=rtlaisadsb-0
```

A specific RTL-SDR radio (if serial numbers are available):

```
source=rtlaisadsb-324452324332
```

Not all RTL-SDR hardware populates the serial number field, and some hardware ships with a default serial number of `0`.  Serial numbers can be found using the standard rtlsdr tools, like `rtl_test`.

### Multiple RTL-SDR devices

Every datasource in Kismet must have a unique identifier, the source UUID.  Kismet calculates this using the serial number of the RTL-SDR device.

When using multiple RTL-SDR radios which don't report unique serial numbers, either assign each one a serial number with the `rtl_eeprom` tool, or set the `uuid=...` parameter on each Kismet source definition.

## SDR RTLAISADSB source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Hopping options

{{<configopt hop_mode adaptive fixed>}}
Size the dwells from the traffic on each band (`adaptive`, the default), or use the `ais_dwell` and `adsb_dwell` times (`fixed`).
{{</configopt>}}

{{<configopt ais_dwell "seconds">}}
Time spent on AIS each cycle with `hop_mode=fixed`, from 0.25 to 600 seconds; the default is 2 seconds.
{{</configopt>}}

{{<configopt adsb_dwell "seconds">}}
Time spent on ADSB each cycle with `hop_mode=fixed`, from 0.25 to 600 seconds; the default is 2 seconds.
{{</configopt>}}

### Radio control options

{{<configopt gain "value">}}
Specify a fixed gain level for the radio on both bands, in tenths of a dB as librtlsdr uses them (`gain=400` for 40dB); by default, the hardware automatic gain control is used.
{{</configopt>}}

{{<configopt ais_gain "value">}}
Specify the gain used only while tuned to AIS, overriding `gain`.
{{</configopt>}}

{{<configopt adsb_gain "value">}}
Specify the gain used only while tuned to ADSB, overriding `gain`.
{{</configopt>}}

{{<configopt ppm "error_value">}}
Specify a PPM error offset for your radio.  The AIS channels are only 25kHz either side of the tuned frequency, so correcting a known frequency error matters for AIS.
{{</configopt>}}

{{<configopt biast true false>}}
Enable bias-tee power on supported radios, to power an external amplifier or other equipment in the antenna chain.  This requires a version of librtlsdr with bias-tee support.  Bias-tee power stays on for both bands.
{{</configopt>}}

{{<configopt biastgpio "gpio">}}
Enable bias-tee power using a specific GPIO on the radio.  This requires a version of librtlsdr with bias-tee GPIO support.
{{</configopt>}}

{{<configopt uuid "uuid">}}
Set the source UUID, when multiple radios don't report unique serial numbers.
{{</configopt>}}
