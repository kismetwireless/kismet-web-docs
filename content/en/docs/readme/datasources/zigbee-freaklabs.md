---
title: "Zigbee - Freaklabs"
description: ""
lead: ""
date: 2022-09-04T15:12:07-04:00
lastmod: 2022-09-04T15:12:07-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "zigbee-freaklabs-c3e7cc1d1b4935a5fef4bddd59bd9799"
weight: 500
toc: true
---

The [Freaklabs 2.4](https://freaklabsstore.com/index.php?main_page=product_info&products_id=215) and [Freaklabs 900](https://freaklabsstore.com/index.php?main_page=product_info&products_id=215) devices support 2.4GHz and 900MHz (depending on model) and are based on the Arduino platform.

To sniff, you will need to update the device with the [SenSniff](https://github.com/freaklabs/sensniff-freaklabs) firmware (via the Arduino IDE).


## 802.15.4 (Zigbee) 

The 802.15.4 standard is a low-bandwidth low-power networking standard.  A commercial implementation is Zigbee, however other devices also implement the 802.15.4 physical layer.

Detecting and classifying 802.15.4 networks can be challenging, as they may transmit infrequently.  Often 802.15.4 networks report fragmentary network IDs, which may lead to multiple networks being identified as a single device; this is unavoidable due to how 802.15.4 addressing works.

Kismet also decodes what it can of the network above 802.15.4: Zigbee and Thread beacons, the Zigbee network (NWK) header, 6LoWPAN and Thread MLE.  Devices are labelled as Zigbee coordinators, routers and devices, Zigbee Green Power devices, Thread devices or 6LoWPAN devices.  The device details show the network, role, PAN and short address, the device's IEEE (EUI-64) address when a Zigbee NWK header carries it, the extended PAN ID, the Thread network name and the Zigbee stack profile.  Green Power devices, which have no MAC address of their own, are tracked by their source ID.  Frames encrypted at the 802.15.4 MAC layer can't be read past their header.

After 2026-10-R1, Kismet learns more about Thread networks:

* Thread Discovery Requests and Responses are decoded.  A response gives the network's name, extended PAN ID, Thread version, whether it is accepting new devices, whether a native commissioner may join, and the joiner port; a request marks its sender as scanning for networks or looking for one to join.  An open network raises the [THREADJOINABLE](/docs/readme/alerts/alerts/#threadjoinable) alert.
* Thread 1.1 beacons also give the version and whether the network is accepting new devices, and their extended PAN ID is shown in the right byte order; before, it was reversed like a Zigbee one.
* Most Thread frames are encrypted, so a device on a PAN which Kismet has seen to be a Thread network, on the same channel, is labelled Thread with the network's name and extended PAN ID, unless its own frames say it is Zigbee.
* Thread routers and end devices are told apart by their short address (RLOC16), which gives the router and child ID, and an end device is linked to its parent router.  Routers show the children, and the routers of their network, heard in the last hour; sleepy end devices show how often they poll their parent, and CSL end devices their CSL period.  The MAC key index and MLE key sequence show how many times the network key has rotated.

| Field | Contents |
| ----- | -------- |
| `802154.device.thread_version` | Thread version: 2 Thread 1.1, 3 1.2, 4 1.3, 5 1.4 |
| `802154.device.thread_joining` | Whether its network takes new devices: 1 no, 2 the devices its commissioner lists, 3 any |
| `802154.device.thread_native` | Its network allows a native commissioner |
| `802154.device.thread_joiner_port` | The UDP port joining devices use to reach it |
| `802154.device.thread_discovery` | Its discovery requests: 1 looking for networks, 2 looking for a network to join |
| `802154.device.thread_router_id`, `thread_child_id` | Router and child ID from its short address; child ID 0 for a router |
| `802154.device.thread_parent` | The device key of its parent router |
| `802154.device.thread_children`, `thread_routers` | A router's children, and the routers of its network, heard in the last hour |
| `802154.device.thread_polls`, `thread_poll_interval` | Data polls sent to its parent, and the usual time between them in milliseconds |
| `802154.device.thread_csl_period` | Its CSL period, in units of 10 symbols (160 µs at 2.4 GHz) |
| `802154.device.thread_key_index`, `thread_key_seq` | The key index of its MAC security, and the key sequence of its MLE security |

## 802.15.4 channels

802.15.4 / Zigbee operates in up to 3 bands.  You will need a device for each band.  Most devices support the more common 2.4GHz band, with support for 800 and 900MHz being much rarer (currently only supported via the Freaklabs hardware).

| Band | Channels | Description                   |
| ---- | -------- | ----------                    |
| 800  | 0        | European band, single channel |
| 900  | 1-10     | US / International ISM band   |
| 2400 | 11-26    | US / International ISM band   |

Channels are a fixed width and are identified only by channel number (ie 1, 12, 13, 14).  There are no options for wide or fast channels in 802.15.4.

Despite sharing the frequency range with Wi-Fi on the 2.4GHz band, 802.15.4 uses a different physical encoding standard; a Wi-Fi card is not able to see 802.15.4 packets or networks, and an 802.15.4 device is not able to see Wi-Fi packets.

## Configuring the Freaklabs device

To configure a Freaklabs device for sniffing:

* Install the latest official Arduino environment for your system (either via the Arduino website, your distribution packages, or by downloading it for your operating system if on MacOS or Windows)
* Install the Freaklabs board definitions in the Arduino IDE
* Install the Freaklabs chibi-arduino library in the Arduino IDE
* Compile the chibi_ex10_sensniff example code
* Upload the compiled firmware to your device using the Arduino IDE

Further information about adding the required libraries to the Arduino IDE can be found in the [SenSniff](https://github.com/freaklabs/sensniff-freaklabs) git repository.

## Freaklabs interfaces

The Freaklabs interface in kismet can be referred to as simply `freaklabs`.  These devices appear as serial ports, so cannot be auto-detected. 

Each `freaklabs` source must have a `device` option and a `band` option.  The `device` option tells Kismet where to find the serial device, and the `band` option chooses what radio frequency to set.  Be sure to match the frequency to the type of device you have!

An example source definition:

```bash
source=freaklabs:device=/dev/ttyUSB0,band=900
```

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device selection 

{{<configopt device "/path/to/serial/device">}}
The Freaklabs devices appear as USB serial devices, and serial devices can not be auto-discovered. 

You *must* provide the path to the serial device associated with the Freaklabs Freakduino sniffer. 
{{</configopt>}}

### Band options

{{<configopt band 800 900 2400>}}
Frequency band to tune to.  This must match the supported radio in your device.
{{</configopt>}}

### Channel control options 

{{<configopt channel_hop true false>}}
Enable or disable channel hopping on this data source.  Even if Kismet is [configured for](/docs/readme/datasources/channelhop/#configuration) channel hopping.
{{</configopt>}}


{{<configopt channel_hoprate "rate/sec" "rate/min">}}
Change the hop rate for this source.
{{</configopt>}}


{{<configopt channel channel>}}
Set the source to a specific channel; combine with channel_hop=false to set the capture to a single channel forever.

Example:

```
source=freaklabs:device=/dev/ttyUSB0,band=2400,name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated 
* Contained in quotes

Example:

```
source=freaklabs:device=/dev/ttyUSB0,band=2400,name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'freaklabs:device=/dev/ttyUSB0,band=2400,name=Foo,channels="12,13,14,15"'
```

{{</configopt>}}
