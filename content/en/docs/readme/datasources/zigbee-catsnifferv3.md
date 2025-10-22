---
title: "Zigbee: Catsniffer v3"
description: ""
lead: ""
date: 2025-10-21T18:34:17-0400
lastmod: 2025-10-21T18:34:29-0400
images: []
menu:
  docs:
    parent: ""
    identifier: "catsnifferv3zigbee"
weight: 510
toc: true
---

The [CatSniffer](https://electroniccats.com/store/catsniffer-v3/) is a multi-radio embedded swiss army knife tool.  With the
appropriate firmware, it can capture Zigbee traffic with Kismet.

While the CatSniffer v1 and v2 devices contain the same radios, it appears the
Zigbee control firmware has not been ported to the previous microcontroller
used, so they currently can not capture Zigbee with Kismet.

## Added 2025-10

The CatSniffer Zigbee datasource is available on Kismet git and release builds
`2025-10` and later.

## 802.15.4 (Zigbee)

The 802.15.4 standard is a low-bandwidth low-power networking standard.  A commercial implementation is Zigbee, however other devices also implement the 802.15.4 physical layer.

Detecting and classifying 802.15.4 networks can be challenging, as they may transmit infrequently.  Often 802.15.4 networks report fragmentary network IDs, which may lead to multiple networks being identified as a single device; this is unavoidable due to how 802.15.4 addressing works.

## 802.15.4 channels

802.15.4 / Zigbee operates in up to 3 bands.  You will need a device for each band.  Most devices support the more common 2.4GHz band, with support for 800 and 900MHz being much rarer (currently only supported via the Freaklabs hardware).

| Band | Channels | Description                   |
| ---- | -------- | ----------                    |
| 800  | 0        | European band, single channel |
| 900  | 1-11     | US / International ISM band   |
| 2400 | 12-26    | US / International ISM band   |


Channels are a fixed width and are identified only by channel number (ie 1, 12, 13, 14).  There are no options for wide or fast channels in 802.15.4.

The CatSniffer hardware supports only the 2.4GHz Zigbee channels (12-26).

Despite sharing the frequency range with Wi-Fi on the 2.4GHz band, 802.15.4 uses a different physical encoding standard; a Wi-Fi card is not able to see 802.15.4 packets or networks, and an 802.15.4 device is not able to see Wi-Fi packets.

## CatSniffer v3 Zigbee Capture firmware

Before using the CatSniffer v3 with Kismet, you will need the Zigbee capture
firmware flashed to the device.

Compiled firmware is available on the [CatSniffer Github](https://github.com/ElectronicCats/CatSniffer-Firmware/releases).
Specifically you will need the [sniffer_fw_Catsniffer_v3.x](https://github.com/ElectronicCats/CatSniffer-Firmware/blob/v3.x/CC1352P7/sniffer_fw_cc1252P_7/sniffer_fw_Catsniffer_v3.x.hex)
firmware loaded on the CatSniffer, which may require using either the `catnip` utility or the `cc2538-bsl` utility from the CatSniffer repository.

## CatSniffer v3 interfaces

CatSniffer v3 datasources in Kismet can be referred to as simply `catsniffer`.
The CatSniffer appears on the system as a serial port device, so can not be
auto-detected.  Each CatSniffer source must have a `device` source option:

```bash
kismet -c catsniffer:device=/dev/ttyUSB0
```

## Supported Hardware

While the CatSniffer v1 and v2 devices may be capable of running the sniffer
firmware, it is not immediately obvious if there is a version of the sniffer
firmware which works on the v1 and v2 versions of the hardware.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel control options

{{<configopt channel_hop true false>}}
Enable or disable channel hopping on this data source.  Even if Kismet is (configured for)[/docs/readme/datasources/channelhop/#configuration] channel hopping.
{{</configopt>}}


{{<configopt channel_hoprate "rate/sec" "rate/min">}}
Change the hop rate for this source.
{{</configopt>}}


{{<configopt channel channel>}}
Set the source to a specific channel; combine with channel_hop=false to set the capture to a single channel forever.

Example:

```
source=catsniffer:device=/dev/ttyUSB0,name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated
* Contained in quotes

Example:

```
source=catsniffer:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'catsniffer:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
