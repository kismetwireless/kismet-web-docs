---
title: "ADSB - SDR RTLADSB"
description: ""
lead: ""
date: 2022-09-14T17:43:04-04:00
lastmod: 2026-11-11T20:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "adsb-sdradsb-c3dd5f5e055d50d0ef2cde2301e7e597"
weight: 800
toc: true
---

Kismet can leverage the cheap [rtl-sdr](https://www.rtl-sdr.com) software defined radio to capture ADSB data from aircraft and helicopters.

The SDR RTLADSB source can autodetect rtl-sdr devices automatically, and can be manually specified with `type=rtladsb`:
```
source=rtladsb-0:type=rtladsb
```

## ADSB

ADSB is an international standard for aircraft identification.  ADSB packets contain information about the flight, such as current location coordinates, altitude, bearing, flight number, registered ICAO aircraft identifier ID, GPS signal fidelity, and more.

Thanks to the altitude of aircraft, it's often possible to receive information from hundreds of miles (or kilometers) away.

## Signal levels

Since `2026-10`, the SDR RTLADSB source reports the signal level of each message, in dB relative to the full scale of the radio (dBFS).  This is a relative level, useful for comparing aircraft and antennas, not a calibrated power; it changes with the gain setting.

## Sharing a radio with AIS

The [SDR RTLAISADSB](/docs/readme/datasources/aisadsb-sdrrtlaisadsb/) source receives both ADSB and AIS with a single rtl-sdr, by tuning between them.

## Supported hardware

The RTL-SDR is a repurposed digital TV tuner which functions as an extremely cheap SDR, or software defined radio.

It is not possible to use Bluetooth or Wi-Fi devices to capture ADSB data; a SDR is required for tuning to the proper frequencies and capturing raw radio sample data.

The Kismet implementation of ADSB decoding is tightly coupled to the cheap RTL-SDR hardware, and will not currently work with other SDR hardware.

## SDR RTLADSB interfaces

Kismet identifies RTL-SDR hardware by either the serial number (if any) or by the radio position; for example:

The first RTL-SDR radio in the system, to be used for rtladsb:

```
source=rtladsb-0
```

A specific RTL-SDR radio (if serial numbers are available):

```
source=rtladsb-324452324332
```

Not all RTL-SDR hardware populates the serial number field, and some hardware ships with a default serial number of `0`.

Serial numbers can be found using the standard rtlsdr tools, like rtl_test:

```
$ rtl_test
Found 4 device(s):
  0:  NooElec, NESDR Nano 3, SN: 2686186936
  1:  NooElec, NESDR Nano 3, SN: 1177459274
  2:  NooElec, NESDR Nano 3, SN: 2664167682
  3:  NooElec, NESDR Nano 3, SN: 0572734167
```

### Multiple RTL-SDR devices

Every datasource in Kismet must have a unique identifier, the source UUID. Kismet calculates this using the serial number of the RTL-SDR device.

Not all RTL-SDR hardware supplies a valid serial number; often devices will report a serial number of “00000000”. This will not cause any problems for Kismet if it is the only RTL-SDR device, however when using multiple RTL-SDR radios either locally or via remote capture, each one must have a unique ID.

A unique ID can be set using the `rtl_eeprom` tool to assign a proper serial number, or by using the `uuid=...` parameter on the Kismet source definition. A unique UUID can be generated with the genuuid tool on most systems.

## SDR RTLADSB source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Frequency

SDR RTLADSB always tunes to 1090MHz, the international standard frequency for ADSB; it has no channel option.

### Radio control options

Option names must be spelled exactly as shown; Kismet ignores an option it doesn't recognize, without a warning.

* biast={true} / {false}

    Enable bias-tee power on supported radios.  The option is `biast`; older versions of this page called it `biastee`, which is ignored, so bias-tee stays off.

    Bias-tee is used to supply power to external amplifiers, powered antennas, or other equipment in the antenna chain, and requires that your radio hardware has power injection support and that librtlsdr was built with bias-tee support.  If an LNA or powered antenna is in the antenna chain and bias-tee is off, it gets no power and the radio hears few or no aircraft.

    ```
    source=rtladsb-0:biast=true
    ```

* biastgpio={gpio}

    Enable bias-tee power using a specific GPIO on the radio, for hardware that doesn't use the default.  This requires a version of librtlsdr with bias-tee GPIO support.

* gain={value}

    Specify a fixed gain level for the radio, in tenths of a dB (for example `gain=496` for 49.6dB); Kismet uses the nearest gain the tuner supports.  By default, the hardware automatic gain control is used.

* ppm={error_value}

    Specify a PPM error offset for fine-tuning your radio, if your hardware has a known offset.

* uuid={uuid}

    Set the source UUID, when multiple radios don't report unique serial numbers; see [Multiple RTL-SDR devices](#multiple-rtl-sdr-devices).

