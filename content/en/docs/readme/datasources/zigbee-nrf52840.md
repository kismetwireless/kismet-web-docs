---
title: "Zigbee - nRF 52840"
description: ""
lead: ""
date: 2022-09-03T19:12:59-04:00
lastmod: 2022-09-03T19:12:59-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "nrf52840-6a8b6d3597352fe61f4346cd6cb30314"
weight: 500
toc: true
---

The nRF 52840 is a chip used for 2.4Ghz communications, including 802.15.4.   To use it with Kismet, it must be flashed with sniffer firmware [provided by NordicRF](https://github.com/NordicSemiconductor/nRF-Sniffer-for-802.15.4).

The nRF 52840 utilizes serial communications so no special libraries are needed for use with Kismet, *however* not all platforms have working serial port drivers (see below).


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

Despite sharing the frequency range with Wi-Fi on the 2.4GHz band, 802.15.4 uses a different physical encoding standard; a Wi-Fi card is not able to see 802.15.4 packets or networks, and an 802.15.4 device is not able to see Wi-Fi packets.


## nRF 52840 interfaces

nRF 52840 datasources in Kismet can be referred to as simply `nrf52840`.  These devices appear as serial ports, so cannot be auto-detected.  Each nrf52840 source must have a `device` option:

```
source=nrf52840:device=/dev/ttyUSB0
```

## Limitations

You must specify a `device=` configuration pointing to the serial port this device has been assigned by the kernel; it can not be automatically detected, and will not appear in the datasource list.

Devices do not come with the sniffer firmware pre-flashed so some effort is required by the user.

### macOS limitations

The nRF 52840 uses a CP2104 serial chip; testing with the [latest drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers) under MacOS Catalina has been unsuccessful; however a driver update may fix that in the future.

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
source=nrf528400:device=/dev/ttyUSB0,name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated 
* Contained in quotes

Example:

```
source=nrf528400:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'nrf528400:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
