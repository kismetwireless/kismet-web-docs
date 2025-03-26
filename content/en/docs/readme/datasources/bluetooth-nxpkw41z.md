---
title: "Zigbee - NXP KW41Z"
description: ""
lead: ""
date: 2022-09-03T19:33:32-04:00
lastmod: 2022-09-03T19:33:32-04:00
images: []
weight: 240
toc: true
---

The NXP KW41Z is a chip used for Bluetooth LE and 802.15.4 communications. To use it the development boards with Kismet, it must be flashed with sniffer firmware provided by NXP. It comes with this firmware by default.

The NXP KW41Z utilizes serial communications so no special libraries are needed for use with Kismet, however not all platforms have working serial port drivers (see below).

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## NXP KW41Z interfaces

NXP KW41Z datasources in Kismet can be referred to as simply `nxp_kw41z`. These devices appear as serial ports, so cannot be auto-detected.  Each `nxp_kw41z` source must have a device option:

```
source=nxp_kw41z:device=/dev/ttyUSB0
```

The NXP KW41Z can monitor both Bluetooth LE and Zigbee. By default it will try to monitor all,

To specify only Zigbee:

```
source=nxp_kw41z:device=/dev/ttyUSB0,phy=zigbee
```

To specify only BTLE:
```
source=nxp_kw41z:device=/dev/ttyUSB0,phy=btle
```

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device selection

{{<configopt device "/path/to/serial/device">}}
The NXP KW41Z devices appear as USB serial devices, and serial devices can not be auto-discovered.

You *must* provide the path to the serial device associated with the nRF 51822 sniffer.
{{</configopt>}}

### Phy type

{{<configopt phy btle zigbee>}}
The NXP KW41Z can capture from BTLE and Zigbee.  To only enable one phy, use the `phy` option.
{{</configopt>}}

### Channel control options

Channel control for NXP KW41Z is only available in Zigbee mode.

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
source=nxp_kw41z:device=/dev/ttyUSB0,name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated
* Contained in quotes

Example:

```
source=nxp_kw41z:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'nxp_kw41z:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
