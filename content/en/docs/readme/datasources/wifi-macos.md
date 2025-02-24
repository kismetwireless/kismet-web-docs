---
title: "Wi-Fi: macOS CoreWLAN"
description: ""
lead: ""
date: 2022-08-29T15:52:42-04:00
lastmod: 2022-08-29T15:52:42-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "macos-wifi-7dd2c2fa7058c36d198a40fd6e8f8aea"
weight: 105
toc: true
---

The macOS CoreWLAN datasource works with the built-in Airport Wi-Fi interfaces on macOS.  It does not work with USB or Thunderbolt based devices.

Packet capture on Wi-Fi is accomplished via "monitor mode", a special mode where the card is told to report all packets seen, and to report them at the 802.11 link layer instead of emulating an Ethernet device.

The macOS CoreWLAN Wi-Fi source will auto-detect supported interfaces by querying the network interface list and checking for wireless configuration APIs.  It can be manually specified with `type=osxcorewlan`:

```
source=en0:type=osxcorewlan
```

The macOS CoreWLAN Wi-Fi capture uses the 'kismet_cap_osx_corewlan_wifi' tool, and should
typically be installed suid-root.  macOS requires root permissions to change the state of the network interface.

Example source definitions:

```
source=en0
```

or

```
source=en0:name=some_meaningful_name
```

## macOS Wi-Fi channels

Wi-Fi channels in Kismet define both the basic channel number, and extra channel attributes such as 802.11N 40MHz channels, and 802.11AC 80MHz and 160MHz channels.

Kismet will auto-detect the supported channels on most Wi-Fi cards.  Monitoring on HT40, VHT80, and VHT160 requires support from the hardware, firmware, and drivers.

Channels can be defined by number or by frequency.

| Definition | Interpretation                                               |
| ---------- | ------------------------------------------------------------ |
| xx         | Basic 20MHz channel, such as `6` or `153`                    |
| xxxx       | Basic 20MHz frequency, such as `2412`                        |
| XXHT20     | 20MHz HT20 channel, such as `6HT20`                          |
| XXXXHT20   | 20MHz frequency, such as `2412HT20`                          |
| xxHT40+    | 40MHz 802.11n with upper secondary channel, such as `6HT40+` |
| xxHT40-    | 40MHz 802.11n with lower secondary channel, such as `6HT40-` |
| xxVHT80    | 80MHz 802.11ac channel, such as `116VHT80`                   |
| xxVHT160   | 160MHz 802.11ac channel, such as `36VHT160`                  |

## Supported hardware

The Kismet macOS CoreWLAN support works with the Airport internal Wi-Fi hardware only.

## macOS CoreWLAN Wi-Fi source parameters

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
source=wlan0:name=Foo,channel_hop=false,channel=6
source=wlan1:name=Wifi6eCard,channel_hop=false,channel=1W6e
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated
* Contained in quotes

Example:

```
source=wlan0:name=Foo,channels="1,2,3,4,5,6,36HT40+"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'wlan0:name=Foo,channels="1,2,3,4,5,6,36HT40+"'
```
{{</configopt>}}


{{<configopt add_channels "channel1,channel2,...,channelN">}}
*Append* a list of channels to the detected list of channels.

Kismet will autodetect channels on almost all Wi-Fi sources, but some non-standard channels like half and quarter channel allocations must be manually added.

The list of channels to add must be:

* Comma separated
* Contained in quotes

Example:

```
source=wlan0:name=Foo,add_channels="1W5,2W5,6W10"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  YOu can avoid this by surrounding the definition in single quotes:

```bash
kismet -c 'wlan0:name=Foo,add_channels="1W5,2W5,6W10"'
```
{{</configopt>}}

### Interface control options

{{<configopt timestamp true false>}}
Typically, Kismet will override the timestamp of the packet with the local timestamp of the server; this is the default behavior for remote data sources, but it can be turned off either on a per-source basis or in `kismet.conf` globally.

Generally the defaults have the proper behavior, especially for remote data sources which may not be NTP time synced with the Kismet server.
{{</configopt>}}

### Filtering options

{{<configopt dot11_process_phy true false>}}
802.11 Wi-Fi networks have three basic packet classes - Management, Phy, and Data.  The Phy packet type is the shortest, and contains the least amount of information - it is used to acknowledge packet reception and controls the packet collision detection CTS/RTS system.  These packets can be useful, however they are also the most likely to become corrupted and still pass checksum.

Kismet turns off processing of Phy packets by default because they can lead to spurious device detection, especially in high-data captures.  For complete tracking and possible detection of hidden-node devices, it can be set to 'true' but this generally results in a large number of bogus device detections.
{{</configopt>}}

