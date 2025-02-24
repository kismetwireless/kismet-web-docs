---
title: "Wi-Fi: Hak5 Wifi Coconut"
description: ""
lead: ""
date: 2022-08-29T21:57:37-04:00
lastmod: 2022-08-29T21:57:37-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "hak5-coconut-wifi-2333df0294d60eb6ad8883534e73f805"
weight: 140
toc: true
---

The WiFi Coconut source works with the [Hak5 WiFi Coconut](https://shop.hak5.org/products/wifi-coconut), a USB device with 14 2.4GHz Wi-Fi radios.

Kismet will auto-detect Coconut devices as `hak5_coconut`, or you may manually specify the type:

```
source=coconut:type=hak5_coconut
```

## Supported hardware

The WiFi Coconut source works with the Hak5 WiFi hardware.

## Compiling Coconut support

WiFi Coconut requires libUSB support, and you will need to enable Coconut support at compile time by passing `--enable-wifi-coconut` to `./configure`.

WiFi Coconut support is also built into packages from the main Kismet repositories for Kali, Debian Bullseye, Debian Bookworm, Ubuntu Focal, and Ubuntu Jammy.

Kismet Hak5 WiFi Coconut support will also work on macOS!

## Kismet WiFi Coconut support

The WiFi Coconut presents as 14 Wi-Fi radios.  Under Linux, these can either be configured as 14 independent sources in Kismet, or as the WiFi Coconut source.

When configured with Coconut support, Kismet will load the userspace driver from the WiFi Coconut tool, configure each radio on a channel, and report packets from all 14 2.4GHz channels simultaneously in Kismet.

Under macOS, there is no monitor-mode capable USB driver for the Wi-Fi card used in the Coconut, and the Kismet datasource is required.

## BladeRF WiPhy source parameters

### Interfaces

The WiFi Coconut is addressed as `coconut-X` where `X` is the position on the USB topology that the Coconut was found.

If there is only one Coconut, it can be configured as `coconut`; for multiple Coconut devices on a single system you will need to configure as the USB position, such as `coconut-8`.

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Coconut options

{{<configopt disable_leds true false>}}
Once the WiFi Coconut is opened and enabled, disable the LEDs.
{{</configopt>}}
