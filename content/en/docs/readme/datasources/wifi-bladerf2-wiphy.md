---
title: "Wi-Fi: Bladerf2 Wiphy"
description: ""
lead: ""
date: 2022-08-29T17:10:56-04:00
lastmod: 2022-08-29T17:10:56-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "sdr-bladerf2-wiphy-162a6334803713f73bbeda9a8a974c88"
weight: 130
toc: true
---

The BladeRF2 WiPhy source works with the [Nuand BladeRF2 A9](https://www.nuand.com/product/bladerf-xa9/) with the [WiPhy](https://www.nuand.com/bladerf-wiphy/) FPGA image.

Kismet will auto-detect BladeRF2 devices as `bladerf-wiphy`, or you may manually specify the type:

```
source=bladerf-wiphy-0:type=bladerf-wiphy
```

## Supported hardware

The BladeRF2 WiPhy source requires a BladeRF2 (aka BladeRF Micro), with the larger FPGA (the A9 variant).

It requires the WiPhy FPGA image.

## Compiling WiPhy support 

WiPhy support in Kismet requires the latest versions of LibBladeRF2; as these are not available in many distributions, Kismet does not enable it by default.

You will need to enable WiPhy support at compile time by passing `--enable-bladerf` to `./configure` during the compile stage.

WiPhy support is also built into packages from the main Kismet repositories for Kali and Ubuntu Jammy.

Kismet WiPhy support will also work on macOS!

## Kismet WiPhy support 

BladeRF2 WiPhy integrates with the Linux mac80211hwsim virtual 802.11 driver layer.  Kismet can use this as a normal Wi-Fi interface in Linux with no additional support, using the Linux Wi-Fi datasource.

The Kismet WiPhy support will directly communicate with the BladeRF2 SDR using libBladeRF2, and will work without the mac80211hwsim layer and on macOS.

## BladeRF WiPhy source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.


