---
title: "Wi-Fi: Linux"
description: ""
lead: ""
date: 2022-08-26T16:26:17-04:00
lastmod: 2022-08-26T16:26:17-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "linux-wifi-57c27a0d882a5a057b200c92ecacfef9"
weight: 100
toc: true
---

Linux Wi-Fi was the first capture type Kismet was created for, and is most likely the main data source.

The Linux Wi-Fi source captures from network interfaces in monitor mode

The Linux Wi-Fi data source handles capturing from Wi-Fi interfaces using the two most recent Linux standards:  The new netlink/mac80211 standard present since approximately 2007, and the legacy ioctl-based IW extensions system present since approximately 2002.

Packet capture on Wi-Fi is accomplished via "monitor mode", a special mode where the card is told to report all packets seen, and to report them at the 802.11 link layer instead of emulating an Ethernet device.

The Linux Wi-Fi source will auto-detect supported interfaces by querying the network interface list and checking for wireless configuration APIs.  It can be manually specified with `type=linuxwifi`:
```
source=wlan1:type=linuxwifi
```

The Linux Wi-Fi capture uses the 'kismet_cap_linux_wifi' tool, and should
typically be installed suid-root:  Linux requires root to manipulate the
network interfaces and create new ones.

Example source definitions:
```
source=wlan0
source=wlan1:name=some_meaningful_name
```

## Linux Wi-Fi channels

Wi-Fi channels in Kismet define both the basic channel number, and extra channel attributes such as 802.11N 40MHz channels, 802.11AC 80MHz and 160MHz channels, 6GHz channels (which share the same numbers as 2.4GHz and 5GHz channels), and non-standard half and quarter rate channels at 10MHz and 5MHz.

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
| xxW6e      | 6GHz Wifi 6e channels (which also start at 1), such as `1-6E` |
| xxW10      | 10MHz half-channel, a non-standard channel type supported on some Atheros devices.  This cannot be automatically detected, you must manually add it to the channel list for a source. |
| xxW5       | 5MHz quarter-channel, a non-standard channel type supported on some Atheros devices.  This cannot be automatically detected, you must manually add it to the channel list for a source. |


## Lockfiles

Linux doesn't gracefully handle probing and creating multiple monitor mode VIFs at once.  To prevent this from happening, Kismet uses a lockfile in `/tmp/.kismet_cap_linux_wifi_interface_lock`;  The Linux capture tool uses this to ensure that only one Kismet process is creating a monitor mode interface at once.

In some rare circumstances this file may be created with privileges that are not accessible from Kismet while running as suid-root; in these instances you will see an error opening an interface that it could not acquire the lock file.  Fixing these incidents should be as simple as a one-time removal of the file:

```bash
sudo rm /tmp/.kismet_cap_linux_wifi_interface_lock
```

## Supported hardware

Not all hardware and drivers support monitor mode, but the majority do.  Typically any driver shipped with the Linux kernel supports monitor mode, and does so in a standard way Kismet understands.  If a specific piece of hardware does not have a Linux driver yet, or does not have a standard driver with monitor mode support, Kismet will not be able to use it.


### Known good chipsets

* Atheros-based ath5k, ath9k, USB-based atheros cards like the AR9271)

    Atheros 802.11abgn cards are typically the most reliable, however they appear to return false packets with valid checksums on very small packets such as phy/control and powersave control packets.  This may lead Kismet to detect spurious devices not actually present if phy packet filtering is not enabled. 

    The Atheros ath10k and ath11k chipsets use a clsoed-source RTOS firmware on the card itself, which has had problems in monitor mode in the past.  Performance may be highly suspect.

* Intel-based cards (all supported by the iwlwifi driver including the 3945, 4965, 7265, 8265, ax200, ax210 and similar)

    Intel cards, with older kernel drivers and firmware, have significant crashing issues when tuning to HT40 and HT80 channels.  

    Modern kernels appear to have resolved this issue; any kernel from 2020 or newer should have few if any problems.  If you cannot upgrade your kernel, you can disable HT and VHT channels by passing the source options `ht_channels=false` and `vht_channels=false`; such as `source=wlp4s0:name=someintel,ht_channels=false,vht_channels=false`

    Wi-Fi 6e Intel interfaces like the AX210 require a manual scan for networks prior to running Kismet, or the firmware will flag the 6GHz channels as disabled.

* Realtek USB devices (rtl8180 and rtl8187, such as the Alfa AWUS036H)

* RALink rt2x00 based devices

* ZyDAS cards

* Broadcom cards such as those found in the Raspberry Pi 3 and Raspberry Pi 0W, *if you are using the nexmon drivers*.  

    Even fully patched with nexmon, the Broadcom drivers often exhibit some form of instability, often ceasing to return packets after a minute or two, with no obvious errors.

    It is not posisble to use Kismet with the *default drivers* from Raspbian or similar distributions.

    The Kali distribution for the Raspberry Pi *includes the nexmon patches already* and will work.

    To patch your own distribution with nexmon, consult the nexmon site at: https://github.com/seemoo-lab/nexmon

* Mediatek mt7612u 802.11AC devices; these are some of the best supported devices.

* Almost all other drivers shipped with the Linux kernel

### Cards known to have significant issues

* ath10k 

    Atheros 802.11AC cards have many problems, including floods of spurious packets in monitor mode.  These packets carry 'valid' checksum flags, making it impossible to programmatically filter them.  Expect large numbers of false devices.  It appears this will require a fix to the closed-source Atheros firmware to resolve.

* rtl8812 and 8814 

    USB 802.11AC cards are known to have many strange problems.  While extremely common hardware, these cards use out-of-kernel drivers which do not support standard monitor mode vif configuration.  There are many flavors of these drivers, many of which cannot enter monitor mode, or silently fail to enable monitor mode.  Despite being a common and cheap chipset, these cards are best avoided because they will take a lot of work to get running.

* rtl88x2bu based cards 

    These devices have an out-of-kernel driver which doesn't support mac80211 VIFs or modern channel control.  Kismet will fall back to the old WEXT ioctl control method, but these drivers will not support setting HT channels.

Kismet generally *will not work* with most other out-of-kernel (drivers not shipped with Linux itself), specifically drivers such as the SerialMonkey RTL drivers used for many of the cheap, tiny cards shipped with devices like the Raspberry Pi and included in distributions like Raspbian.  Some times it's possible to find other, supported drivers for the same hardware, however some cards have no working solution.

Many more devices should be supported - if yours isn't listed and works, let us know via Twitter (@kismetwireless).

## Linux Wi-Fi source parameters

The Linux Wi-Fi source is extensively configurable.

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


{{<configopt default_ht20 true false>}}
Added `2019-04-git`

If the interface is HT capable, automatically use HT20 channels for all 20mhz wide channels.  This explicitly tells the interface to set the HT20 attributes instead of a basic channel.  If `default_ht20=true`, then `expand_ht20` is ignored. 
{{</configopt>}}


{{<configopt expand_ht20 true false>}}
Added `2019-04-git`

If the interface is HT capable, automatically expand 20MHz channels to define the basic *and* the HT20 channel; for example instead of channel `1`, you would now have both `1` and `1HT20`.

This has the possibility to drastically increase the number of channels in the hop list, which increases the hop time.

This option is most useful on interfaces which may not report non-HT data packets when tuned to HT20.
{{</configopt>}}


{{<configopt ht_channels true false>}}
Kismet will detect and tune to HT40 channels when available; to disable this, set `ht_channels=false` on your source definition.

Kismet will automatically disable HT channels on some devices which are known to have problems tuning to HT channels; if your device has trouble tuning to HT channels, or you simply don't want to tune to HT channels when the capability is seen, specify `ht_channels=false`.

See the `vht_channels` option for similar control over 80MHz and 160MHz VHT channels.
{{</configopt>}}


{{<configopt vht_channels true false>}}
Kismet will detect and tune to VHT (80MHz and 160MHz) channels when available; to disable this, set `vht_channels=false` on your source definition.

Kismet will automatically disable HT channels on some devices which are known to have problems tuning to VHT channels; if your device has trouble tuning to VHT channels, or you simply don't want to tune to VHT channels when the capability is seen, specify `vht_channels=false`.

See the `ht_channels` option for similar control over 40MHz HT channels.
{{</configopt>}}


{{<configopt band24ghz true false>}}
Added `2022-08-git`

Enable only channels in the 2.4GHz band.  

This can be combined with `band5ghz=true` and `band6ghz=true`.

By default, Kismet enables all channels it discovers on all bands.  By specifying a specific band, Kismet will *only* enable channels on the selected bands.

Example:

```
# Source0 enables 2.4ghz channels only.
source=wlan0:name=Source0:band24ghz=true 
# Source1 enables 5ghz and 6ghz channels only.
source=wlan1:Name=Source1:band5ghz=true,band6ghz=true
```
{{</configopt>}}


{{<configopt band5ghz true false>}}
Added `2022-08-git`

Enable only channels in the 5GHz band.  

This can be combined with `band24ghz=true` and `band6ghz=true`.

By default, Kismet enables all channels it discovers on all bands.  By specifying a specific band, Kismet will *only* enable channels on the selected bands.

Example:

```
# Source0 enables 2.4ghz channels only.
source=wlan0:name=Source0:band24ghz=true 
# Source1 enables 5ghz and 6ghz channels only.
source=wlan1:Name=Source1:band5ghz=true,band6ghz=true
```
{{</configopt>}}


{{<configopt band6ghz true false>}}
Added `2022-08-git`

Enable only channels in the 6GHz band.  

This can be combined with `band24ghz=true` and `band5ghz=true`.

By default, Kismet enables all channels it discovers on all bands.  By specifying a specific band, Kismet will *only* enable channels on the selected bands.

Example:

```
# Source0 enables 2.4ghz channels only.
source=wlan0:name=Source0:band24ghz=true 
# Source1 enables 5ghz and 6ghz channels only.
source=wlan1:Name=Source1:band5ghz=true,band6ghz=true
```
{{</configopt>}}

### Interface control options 

{{<configopt timestamp true false>}}
Typically, Kismet will override the timestamp of the packet with the local timestamp of the server; this is the default behavior for remote data sources, but it can be turned off either on a per-source basis or in `kismet.conf` globally.

Generally the defaults have the proper behavior, especially for remote data sources which may not be NTP time synced with the Kismet server.
{{</configopt>}}


{{<configopt ignoreprimary true false>}}
Linux mac80211 drivers use `virtual interfaces` or `VIFs` to set different interface modes and behaviors:  A single Wi-Fi card might have `wlan0` as the "normal" (or "managed") Wi-Fi interface; Kismet would then create `wlan0mon` as the monitor-mode capture interface.

Typically, all non-monitor interfaces must be disabled (set to `down` state) for capture to work reliably and for channel setting (and channel hopping) to function.

In the rare case where you are attempting to run Kismet on the same interface as an access point or client, you will want to leave the base interface configured and running (while losing the ability to channel hop); by setting `ignoreprimary=true` on your Kismet source line, Kismet will no longer bring down any related interface on the same Wi-Fi card.

This **almost always** must be combined with setting `channel_hop=false` for this source, because channel control is not possible in this configuration, and depending on the Wi-Fi card type, may prevent proper data capture.

{{</configopt>}}


{{<configopt vif "interface-name">}}
Many drivers use `virtual interfaces` or `VIFs` to control behavior.  Kismet will make a monitor mode virtual interface (vif) automatically, named after some simple rules:

* If the interface given to Kismet on the source definition is already in monitor mode, Kismet will use that interface and not create a VIF
* If the interface name is too long, such as when some distributions use the entire MAC address as the interface name, Kismet will make a new interface named `kismonX`
* Otherwise, Kismet will add `mon` to the interface; ie given an interface `wlan0`, Kismet will create `wlan0mon`

Use the `vif=` option to set a specific name for the VIF.  It will be created if it does not exist.
{{</configopt>}}

### Filtering options 

{{<configopt filter_locals true false>}}
Automatically detect all local interfaces and build a BPF filter to exclude them from the capture.  This is most useful for remote capture instances which are connected over wireless.  The filter can only exclude the first 8 devices found, because of limits in the kernel memory buffer for BPF filtering.

This *can not* be combined with other filter options like filter_mgmt
{{</configopt>}}


{{<configopt filter_mgmt true false>}}
Use a kernel-level BPF filter to filter out all packets *except* 802.11 management and EAPOL (WPA handshake) packets.

Enabling this filter will *drastically* reduce the amount of processing power required for Kismet, however it will exclude *all other data packets*.  Wireless APs and clients will be visible, however wired/bridged clients will not, and data-based statistics like bandwidth will not be available, however beacon-based statistics like QBSS reports will be retained.

This feature is used by the wardrive-mode overlay.
{{</configopt>}}


{{<configopt dot11_process_phy true false>}}
802.11 Wi-Fi networks have three basic packet classes - Management, Phy, and Data.  The Phy packet type is the shortest, and contains the least amount of information - it is used to acknowledge packet reception and controls the packet collision detection CTS/RTS system.  These packets can be useful, however they are also the most likely to become corrupted and still pass checksum.

Kismet turns off processing of Phy packets by default because they can lead to spurious device detection, especially in high-data captures.  For complete tracking and possible detection of hidden-node devices, it can be set to 'true' but this generally results in a large number of bogus device detections.
{{</configopt>}}

### Other options 

{{<configopt fcsfail true false>}}
Wi-Fi packets contain a `frame checksum` or `FCS`.  Some drivers report this as the FCS bytes, while others report it as a flag in the capture headers which indicates if the packet was received correctly.

Generally packets which fail the FCS checksum are garbage - they are packets which are corrupted, usually due to in-air collisions with other packets.  These can be extremely common in busy wireless environments.

Usually there is no reason to set this option unless you are doing specific research on non-standard packets and hope to glean some information from corrupted packets.

Setting this option may remove the ability to identify corrupt packets.
{{</configopt>}}


{{<configopt plcpfail true false>}}
Some drivers have the ability to report data that *looked* like a packet, but which have invalid radio-level packet headers (the Wi-Fi `PLCP` which is not typically exposed to the capture layer).  Generally these events have no meaning, and few drivers are able to report them.

Usually there is no good reason to turn this on, unless you are doing research attempting to capture Wi-Fi-like data.

Setting this option may remove the ability to identify corrupt packets.
{{</configopt>}}


{{<configopt verbose true false>}}
Added `2019-07-git`

Turn on verbose error reporting and warnings; this will raise alerts when channel operations take an extended period of time or if a channel fails to set correctly.
{{</configopt>}}

## Custom / non-standard channels

Some sources - the Atheros 9k and possibly 10k series - support half-width (10MHz) and quarter-width (5MHz) channels.  These channels must be specified manually with `channels=...` or `add_channels=...`.

Often these devices seem to have difficulty switching between normal and custom channel modes; you may need to set a card to use *only* 5MHz or 10MHz channels instead of mixing with normal mode.


