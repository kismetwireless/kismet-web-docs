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

## 802.15.4 channels

802.15.4 / Zigbee operates in up to 3 bands.  You will need a device for each band.  Most devices support the more common 2.4GHz band, with support for 800 and 900MHz being much rarer (currently only supported via the Freaklabs hardware).

| Band | Channels | Description                   |
| ---- | -------- | ----------                    |
| 800  | 0        | European band, single channel |
| 900  | 1-11     | US / International ISM band   |
| 2400 | 12-26    | US / International ISM band   |

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
Enable or disable channel hopping on this data source.  Even if Kismet is (configured for)[/docs/readme/datasources/channelhop/#configuration] channel hopping.
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
