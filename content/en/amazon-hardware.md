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

### Mediatek MT7612U

This is a relatively new 802.11AC chipset which has increasingly good Linux support built into the kernel.  You *need* Linux 4.19.7 or later, and Linux 5.0 preferred for this to work.  This chipset works very well on Intel and Raspberry Pi 4, and can work on a Raspberry Pi 3 with an up-to-date kernel and proper module flags (`echo "options mt76_usb disable_usb_sg=1" > /etc/modprobe.d/mt76_usb.conf`)

There are several flavors of this card, including:
* [The Alfa AWUS036ACM](https://www.amazon.com/gp/product/B073X6RL9D/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B073X6RL9D&linkId=2c055cf50d65263a2d51f2cba4b67a29) has dual antenna jacks and works well.
* [The SparkLAN module](https://www.amazon.com/gp/product/B01CGXT2K2/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01CGXT2K2&linkId=574efef4be0b654d5cbbe22c75c1c133) has U.Fl antenna jacks and works well for building an enclosed system where space is at a premium, but the cost is significantly higher.


## GPS

An important factor to keep in mind is that USB GPS devices are *traditional* GPS:  They have GPS receivers *only*.  In contrast to "GPS" implementations on cell phones, they require a much strong signal and typically will not work indoors, because the smartphone GPS system uses a combination of Wi-Fi, Bluetooth, and cellular data to provide a synthetic location.  Pure GPS usually needs an open view of the sky and may take several minutes to get the initial lock.

Some GPS devices we've had luck with include:
* The [Transsystem GPS/Glonass/Galileo/BeiDou](https://amzn.to/3BxkCGO) device is unfortunately pricey, but has been one of the better performing receivers available.
* The [VK-112](https://amzn.to/3wZGreB) is an extremely cheap option, but lacks a repositionable antenna.
* The [Stratux uBlox](https://amzn.to/3iPgYiY) is another reasonably cheap option with a stronger antenna.
* The [Neo-7M uBlox](https://amzn.to/3rxJw4B) device coupled with an [active antenna](https://amzn.to/3BIAmHk) may be an acceptable option for some situations where portability isn't as great a concern.

## Other Radios and SDR

### RTLSDR

Most of the SDR capture sources in Kismet use the RTLSDR radios - they're cheap, low power, and easy to get running.  Like Wi-Fi, a SDR radio can only tune to one range of frequencies at a time:  Often it makes sense to get multiple radios, one for each SDR-based protocol you want to monitor.

* The [RTLSDR Kit](https://amzn.to/2JcSeAq) with the radio, several antennas, and mounts, is a good place to start.
* The [stand-alone RTLSDR-blog radio](https://amzn.to/2J9DNgd) comes with BIAS-T power injection (for running external amps and filters).
* The [nooelec](https://amzn.to/33VbFpn) version of the RTLSDR is low profile for fitting multiple radios into adjacent USB ports.  The basic model lacks bias-t power injection, however.
* The [nooelec smartee](https://amzn.to/2BrToUp) has continual bias-t power injection and a similar physical profile allowing multiple radios to be used on adjacent ports.

### CC2540 BTLE

The CC2540 BTLE card is a super cheap BTLE capture card (for advertisements only).  While it lacks an external antenna jack, it can be modified, and the cost makes up for a lot.

* [The basic CC2540](https://amzn.to/3cWFXNt)
* [The CC2540 plus programmer cable](https://amzn.to/3aL5SpA).  Generally you won't need to reprogram these, but it's handy to have.

### CC2531 Zigbee

Similar to the CC2540, the CC2531 is an ultra cheap zigbee/802.15.4 capture card.  It lacks an external antenna and is 2.4GHz only, but the cost makes up for it.

* [The basic CC2531](https://amzn.to/2wRTBkJ)

## 1090/ADSB

Coupled with a RTL-SDR, antennas specific for ADSB can help increase your range for plane spotting using the new Kismet ADSB capture source.  Remember though - you're unlikely to get more range than your line of sight, so often it's easier to see more distant planes at a higher altitude.  Some good tools include:

* The [FlightAware 1090MHz antenna](https://amzn.to/2WB4jqE) from the FlightAware team.
* An [N to SMA cable](https://amzn.to/2UrekDT) is needed to connect the antenna to the RTL-SDR.  Notice you need a *standard* SMA cable not a RP-SMA for most SDRs!  Generally you want to keep this as short as possible.
* Optionally, a [1090MHz Filter/Amplifier](https://amzn.to/2xdCh9U).  If you have a busy RF environment, are near a large FM broadcast antenna, or are otherwise getting weak signals, a combination filter and amplifier can dramatically increase your coverage.  You'll need a [bias-tee capable sdr](https://amzn.to/2BrToUp) to power the amplifier!


## Servers / SBCs
Most people will run Kismet on a laptop; if you're looking for some embedded solutions, however, it runs better on some hardware than others:

### Intel Compute Stick CS125

[The CS125](https://www.amazon.com/gp/product/B01AZC4NHS/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01AZC4NHS&linkId=3d65eddea39288d20b7648fa8d2f3186) is a tiny Intel Atom quad-core processor with 2 gig of RAM.  It's got on-board Intel 802.11AC and Bluetooth, can run Linux, and with a modern kernel (5.0 or higher) the onboard 802.11AC works excellently.  We use these as distributed sensors and portable systems; With 2GB of ram you're likely good for about 60,000 devices per session before RAM becomes a problem.  They're also fantastic as distributed fixed sensors w/ rolling logs.  You can also use USB Wi-Fi cards, RTLSDR, and so on with them.

### Intel Compute Stick CS325

[The CS325](https://www.amazon.com/gp/product/B01AZC4IKK/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01AZC4IKK&linkId=8634aa969f4abbb751bb0767aa6b8714) is the updated version of the 125; it's got a M3 processor instead of an Atom, 4GB of RAM, and USB-C.  This is much more suited for a portable Kismet system connected to a Windows laptop, or as a replacement for a full mobile system in a vehicle, due to its cost.  Like the 125 you can use SDR and USB Wi-Fi cards as well as the internals.

### Intel NUC

The [Intel NUC](https://www.amazon.com/gp/product/B01N4EP1N0/ref=as_li_tl?ie=UTF8&tag=kismetwireles-20&camp=1789&creative=9325&linkCode=as2&creativeASIN=B01N4EP1N0&linkId=8c910e05edb01b221c7127d748ad6d8c) is an excellent device for serious capture, but it's not the best for portability or if your budget is tight.  Don't forget [RAM](https://amzn.to/2WzgKTH) and a [SSD](https://amzn.to/2U96waU).  For aggregating multiple remote captures or busy environments, a strong server with lots of RAM is a must!

### Raspberry Pi 4

The [Raspberry Pi 4](https://amzn.to/2P7Hxmu) is a significant upgrade from the model 3; the model with 4 gig of RAM is quite competent for running Kismet in many moderate to busy environments, and a must for running the Mediatek 802.11AC USB cards.

