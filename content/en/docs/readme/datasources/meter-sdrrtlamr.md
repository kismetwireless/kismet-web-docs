---
title: "Meter - SDR RTLAMR"
description: ""
lead: ""
date: 2022-09-14T16:57:19-04:00
lastmod: 2022-09-14T16:57:19-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "meter-sdrrtlamr-a03a9f68f40102693e3cd7c0894e91c2"
weight: 700
toc: true
---

Kismet can leverage the cheap [rtl-sdr](https://www.rtl-sdr.com) software defined radio to capture the output from several power, water, and electrical meter brands which broadcast usage rates at 915MHz.

The SDR RTLAMR source can autodetect rtl-sdr devices automatically, and can be manually specified with `type=rtlamr`:
```
source=rtlamr-0:type=rtlamr
```

## Supported hardware

The RTL-SDR is a repurposed digital TV tuner which functions as an extremely cheap SDR, or software defined radio. 

The Kismet implementation of AMR decoding is tightly coupled to the cheap RTL-SDR, and currently will not work with other SDR hardware.

It is not possible to use Bluetooth or Wi-Fi devices to capture RF meter data; a SDR is required for tuning to the proper frequencies and capturing raw radio sample data.

## SDR RTLAMR interfaces

Kismet identifies RTL-SDR hardware by either the serial number (if any) or by the radio position; for example:

The first RTL-SDR radio in the system, to be used for rtlamr:

```
source=rtlamr-0
```

A specific RTL-SDR radio (if serial numbers are available):

```
source=rtlamr-324452324332
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

## SDR RTLAMR source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel control options 

{{<configopt channel "frequency-in-Hz">}}
By default, SDR RTLAMR will tune to 915MHz.  To manually set the frequency, in Hz;

```
source=rtlamr-0:channel=512000000
```
{{</configopt>}}

### Radio control options

{{<configopt biastee true false>}}
Enable bias-tee power on supported radios. 

Bias-tee is used to supply power to external amplifiers or other equipment in the antenna chain, and requires that your radio hardware has power injection support.
{{</configopt>}}


{{<configopt gain value>}}
Specifiy a fixed gain level for the radio; by default, the hardware automatic gain control is used.
{{</configopt>}}


{{<configopt ppm error_value>}}
Specify a PPM error offset for fine-tuning your radio, if your hardware has a known offset.
{{</configopt>}}

