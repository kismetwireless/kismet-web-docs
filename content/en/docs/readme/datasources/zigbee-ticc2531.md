---
title: "Zigbee: TICC 2531"
description: ""
lead: ""
date: 2022-09-03T16:43:45-04:00
lastmod: 2022-09-03T16:43:45-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ticc2531-041fe180d00f799721c96d269a2e7453"
weight: 510
toc: true
---

The Texas Instruments CC2531 is a chip used for 802.15.4 communications.  To use it with Kismet, it must be flashed with the sniffer firmware [provided by TI](http://www.ti.com/tool/PACKET-SNIFFER).  Often the devices are available with the sniffer firmware pre-flashed.

Kismet must be compiled with support for `libusb` to use TICC2531; you will need `libusb-1.0-dev` (or the equivalent for your distribution), and you will need to make sure that the `TI CC 2531` option is enabled in the output from `./configure`.

To use the TI CC2531 capture, you must have a TI CC2531 dongle flashed with the sniffer firmware. You can flash this yourself with a CC-Debugger or purchase one online from many retailers.

*Note*: It seems that while many CC2531 devices are *advertised* as pre-flashed with the sniffer firmware, they appear not to be!


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

## TI CC2531 concerns 

The sniffer firmware in the TI CC2531 sometimes goes into a permanent error state until the device is physically re-initialized - by disconnecting it from USB and reconnecting it.  Unfortunately, there does not seem to be any way to automate this process, as once the device enters an error state, it will remain in that state and cannot be reinitialized over USB.

## TI CC2531 interfaces

TI CC2531 datasources in Kismet can be referred to as simply `ticc2531-...`:

```bash
kismet -c ticc2531-0
```

When using multiple TICC devices, they can be specified either in order discovered by the system (`ticc2531-0`, `ticc2531-1`, etc), or by USB path.  If you need to know which specific device is being configured, use the USB path - however, this path may be subject to change if USB devices are moved, new USB devices added, etc.

To find the location on the USB bus, look at the output of `kismet_cap_ti_cc_2531 --list`:

Kismet will also list available TI CC2531 devices automatically in the datasources list.

## Supported Hardware

Any USB device based on the CC2531 chip, and flashed with the TI sniffer firmware, should work.  Beware!  Many online vendors sell identical-looking devices based on the CC2531 chip, which is *not* the same thing!

This datasource should work on any platform, so long as the appropriate libraries are available.

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
source=ticc2531-0:name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated 
* Contained in quotes

Example:

```
source=ticc2531-00:name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'ticc2531-00:name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
