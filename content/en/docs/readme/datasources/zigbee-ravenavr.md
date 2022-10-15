---
title: "Zigbee - Raven RZUSBSTICK"
description: ""
lead: ""
date: 2022-09-03T19:33:32-04:00
lastmod: 2022-09-03T19:33:32-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "zigbee-ravenavr-dbdc0e9ad78b4459be5e44de52494226"
weight: 500
toc: true
---

The AVR RZUSBSTICK is a USB prototype device for 802.15.4 communications.  To use it with Kismet, the stock firmware will work.  The device can also be flashed with the Killerbee firmware [provided by River Loop Security](https://github.com/riverloopsec/killerbee).

Kismet must be compiled with support for `libusb` to use AVR RZUSBSTICK; you will need `libusb-1.0-dev` (or the equivalent for your distribution), and you will need to make sure that the `RZ KILLERBEE` option is enabled in the output from `./configure`.

## 802.15.4 (Zigbee) 

The 802.15.4 standard is a low-bandwidth low-power networking standard.  A commercial implementation is Zigbee, however other devices also implement the 802.15.4 physical layer.

Detecting and classifying 802.15.4 networks can be challenging, as they may transmit infrequently.  Often 802.15.4 networks report fragmentary network IDs, which may lead to multiple networks being identified as a single device; this is unavoidable due to how 802.15.4 addressing works.

### 802.15.4 channels

802.15.4 / Zigbee operates in up to 3 bands.  You will need a device for each band.  Most devices support the more common 2.4GHz band, with support for 800 and 900MHz being much rarer (currently only supported via the Freaklabs hardware).

| Band | Channels | Description                   |
| ---- | -------- | ----------                    |
| 800  | 0        | European band, single channel |
| 900  | 1-11     | US / International ISM band   |
| 2400 | 12-26    | US / International ISM band   |

Channels are a fixed width and are identified only by channel number (ie 1, 12, 13, 14).  There are no options for wide or fast channels in 802.15.4.

Despite sharing the frequency range with Wi-Fi on the 2.4GHz band, 802.15.4 uses a different physical encoding standard; a Wi-Fi card is not able to see 802.15.4 packets or networks, and an 802.15.4 device is not able to see Wi-Fi packets.

## AVR RZUSBSTICK interfaces

AVR RZUSBSTICK datasources in Kismet can be referred to as simply `rzkillerbee`:

```bash
$ kismet -c rzkillerbee
```

When using multiple AVR RZUSBSTICK dongles, they can be specified by their location in the USB bus; this can be detected automatically by Kismet as a supported interface in the web UI, or specified manually.  To find the location on the USB bus, look at the output of `kismet_cap_rz_killerbee --list`:

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
source=rzkillerbee:name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated 
* Contained in quotes

Example:

```
source=rzkillerbee:name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'nzkillerbee:name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
