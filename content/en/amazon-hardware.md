---
title: "Amazon Hardware"
description: ""
date: 2022-08-21T23:22:48-04:00
lastmod: 2022-08-21T23:22:48-04:00
images: []
url: /amazon-hardware/
---

## Hardware

We're often asked what hardware works well with Kismet; here's a list of some useful starting points with links to Amazon.  These links help the Kismet project a little if you use them to order, but by all means order from where ever works best for you!

## Books

### The Scientist & Engineers Guide to Digital Signal Processing

Interested in learning *how* the SDR capture code works?  [The Scientist and Engineers Guide to Digital Signal Processing](https://amzn.to/33Vane1) is a very approachable introduction and reference.

## Wi-Fi cards

### MediaTek MT792x USB

The newest MediaTek chipset supports tri-band operation, with 6GHz channels.  You *absolutely need* a modern Linux (Kernel 5.18 or newer), and need to set the proper regulatory domain (`iw reg set US` for those in the US) to enable 6GHz channels.

There are several manufacturers of this card, the easiest to get directly is by Alfa:
* [The Alfa AWUS036AXML](https://amzn.to/3u7AAbZ)

Other manufacturers also make devices using this chipset, but typically without removable antennas, and sometimes it can be difficult to find reliable users of the chipset.

### MediaTek MT7612U

This is a relatively new 802.11AC chipset which has increasingly good Linux support built into the kernel.  You *need* Linux 4.19.7 or later, and Linux 5.0 preferred for this to work.  This chipset works very well on Intel and Raspberry Pi 4, and can work on a Raspberry Pi 3 with an up-to-date kernel and proper module flags (`echo "options mt76_usb disable_usb_sg=1" > /etc/modprobe.d/mt76_usb.conf`)

There are several flavors of this card, including:
* [The Panda Wireless PAU0D](https://amzn.to/4bhzJ96)
* [The Alfa AWUS036ACM](https://www.amazon.com/gp/product/B073X6RL9D/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B073X6RL9D&linkId=2c055cf50d65263a2d51f2cba4b67a29) has dual antenna jacks and works well.

### Intel

For mPCI-e or M2, Intel is currently making the most reliable cards - the 802.11AC and 802.11AX devices are well supported in modern Linux, however the WiFi-7 chipsets appear to be less supported currently.

* [Intel AX200](https://amzn.to/3SdiVHT) WiFi-6 / Dual band
* [Intel AX210](https://amzn.to/3SkeRFE) WiFi-6e / Tri band.  Getting the Intel to expose the 6GHz channels can require doing an explicit `iw dev [foo] scan` first.

## GPS

An important factor to keep in mind is that USB GPS devices are *traditional* GPS:  They have GPS receivers *only*.  In contrast to "GPS" implementations on cell phones, they require a much strong signal and typically will not work indoors, because the smartphone GPS system uses a combination of Wi-Fi, Bluetooth, and cellular data to provide a synthetic location.  Pure GPS usually needs an open view of the sky and may take several minutes to get the initial lock.

Some GPS devices we've had luck with include:

* The [BN-808](https://amzn.to/3Zc6u3G) is a more expensive but quite sensitive, multi-standard device (it can use the GPS constellation, but also GLONASS, Galileo, and more) and fuses the multiple locations into one report.
* The [VK-112](https://amzn.to/3wZGreB) is an extremely cheap option, but lacks an external antenna.  It's cheap.
* The [GPYes u-blox](https://amzn.to/3iPgYiY) is another reasonably cheap option with a stronger antenna.

## Other Radios and SDR

### RTLSDR

Most of the SDR capture sources in Kismet use the RTLSDR radios - they're cheap, low power, and easy to get running.  Like Wi-Fi, a SDR radio can only tune to one range of frequencies at a time:  Often it makes sense to get multiple radios, one for each SDR-based protocol you want to monitor.

* The [RTLSDR v4 Kit](https://amzn.to/4eBa8bC) with the radio, several antennas, and mounts, is a good place to start.  You'll need to make sure you have a current version of librtlsdr in your distribution, but the v4 has been available for over a year now and should be well supported.
* The [Same RTLSDR v4](https://amzn.to/4hQTGah) but as the radio only, to save a few dollars.  This radio supports bias-tee injection for powering amps and filters.
* The [nooelec](https://amzn.to/33VbFpn) version of the RTLSDR is low profile for fitting multiple radios into adjacent USB ports.  The basic model lacks bias-t power injection, however.  While the Nooelec radios fit well into most USB connectors, we've had some trouble with reliability and the hardware failing after a few months.
* The [nooelec NESDR SMArTee](https://amzn.to/2BrToUp) has continual bias-t power injection and a similar physical profile allowing multiple radios to be used on adjacent ports.  While the Nooelec radios fit well into most USB connectors, we've had some trouble with reliability and hardware failures.

### CC2540 BTLE

The CC2540 BTLE card is a super cheap BTLE capture card (for advertisements only).  While it lacks an external antenna jack, it can be modified, and the cost makes up for a lot.

* [The basic CC2540](https://amzn.to/3CsNhBO) can capture BTLE advertisements as raw packets.  Make sure to pick the 2540 version for BTLE!

### CC2531 Zigbee

Similar to the CC2540, the CC2531 is an ultra cheap zigbee/802.15.4 capture card.  It lacks an external antenna and is 2.4GHz only, but the cost makes up for it.

* [The basic CC2531](https://amzn.to/48WDIaz) is the zigbee/802.15.4 variant of the above adapter.  Make sure to pick the 2531 version for 802.15.4!

## 1090/ADSB

Coupled with a RTL-SDR, antennas specific for ADSB can help increase your range for plane spotting using the new Kismet ADSB capture source.  Remember though - you're unlikely to get more range than your line of sight, so often it's easier to see more distant planes at a higher altitude.  Some good tools include:

* The [X-Boost 1090mhz](https://amzn.to/4bUx1Hd) antenna is a compact option.
* Optionally, a [1090MHz Filter/Amplifier](https://amzn.to/4ev1ifG).  A filter will significantly improve your ADSB reception by blocking signals from FM radio and over bleed-over.

## Servers / SBCs

Most people will run Kismet on a laptop; if you're looking for some embedded solutions, however, it runs better on some hardware than others:

### ZimaBoard

While not the most powerful device, the [Zima series](https://amzn.to/42e4LL7) of SBCs offer a stable platform.  Being based on Intel processors seems to alleviate some of the difficulties with some devices and drivers, they support SATA attached disks, and can be expanded to use PCI-based capture cards.

### Raspberry Pi 5

Bigger number, better board? [Raspberry Pi 5](https://amzn.to/3SAkaCf) is always an option, but beware, the Pi 5 runs so close to the power budget that you'll certainly need a powered USB hub, and possibly some config tricks to convince the Pi 5 it has enough power.

### Raspberry Pi 4

The [Raspberry Pi 4](https://amzn.to/2P7Hxmu) is a significant upgrade from the model 3; the model with 4 gig of RAM is quite competent for running Kismet in many moderate to busy environments, and a must for running the MediaTek 802.11AC USB cards.
