---
title: "Sensor - SDR rtl_433"
description: ""
lead: ""
date: 2022-09-14T14:50:01-04:00
lastmod: 2022-09-14T14:50:01-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "sensor-sdrrtl433-3c9909a3ec38c13e79184085b5e4ced2"
weight: 600
toc: true
---

Kismet can leverage the cheap [rtl-sdr](https://www.rtl-sdr.com) software defined radio and the amazing [rtl_433](https://github.com/merbanan/rtl_433) tool to collect information about RF sensors, weather stations, tire pressure monitors, switches, humidity, power meters, gas meters, water meters, lightning detectors, and more.

The SDR RTL_433 source can autodetect rtl-sdr devices automatically, and can be manually specified with `type=rtl433`:
```
source=rtl433-0:type=rtl433
```

## Required software 

The Kismet SDR RTL_433 source is a basic Python glue between the `rtl_433` tool and Kismet:  All the decoding, heavy work, and handling of protocols is done by `rtl_433`; Kismet collects the JSON output of the tool and turns it into device records. 

Kismet thus requires that `rtl_433` be available.  On some distributions this is available as the `rtl-433` package (Ubuntu Jammy )

## Supported hardware

While the `rtl_433` tool has some support for other SDR hardware via the `soapysdr` API, currently the Kismet implementation requires a RTL-SDR USB device.  

The RTL-SDR is a repurposed digital TV tuner which functions as an extremely cheap SDR, or software defined radio. 

It is not possible to use Bluetooth or Wi-Fi devices to capture data with `rtl_433`; a SDR is required for tuning to the proper frequencies and capturing raw radio sample data.

## SDR RTL_433 interfaces

Kismet identifies rtl433 hardware by either the serial number (if any) or by the radio position; for example:

The first rtl433 radio in the system:

```
source=rtl433-0
```

A specific rtl433 radio (if serial numbers are available):

```
source=rtl433-324452324332
```

Not all rtl433 hardware populates the serial number field, and some hardware ships with a default serial number of `0`.

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

### Capturing different frequencies 

While `rtl_433` was created to capture on 433MHz initially, it can decode devices on other frequencies as well.  A common alternate frequency for sensors, meters, etc is 915MHz. 

A SDR RTL_433 source in Kismet can be configured to other frequencies with the `channel` parameter.  To listen to 915MHz, for instance:

```
source=rtl433-4:name=foo,channel=915MHz
```

## SDR RTL_433 source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel control options 

* channel={xyz}

{{<configopt channel "frequency">}}
Manually set the frequency; by default rtl433 tunes to 433.920MHz.

Frequency can be in MHz:

```
source=rtl433-0:channel=400MHz
```

or KHz:

```
source=rtl433-0:channel=500000KHz
```

or raw hz:

```
source=rtl433-0:channel=512000000
```
{{</configopt>}}

### Radio control options

{{<configopt ppm_error error_value>}}
Set the error correction level for your radio, passed as the -p option to rtl433
{{</configopt>}}


{{<configopt gain gain_value>}}
Set the gain, if supported, passed as the g option to rtl433
{{</configopt>}}

