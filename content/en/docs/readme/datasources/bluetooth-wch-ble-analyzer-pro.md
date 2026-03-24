---
title: "Bluetooth: WCH BLE Analyzer Pro"
description: "WCH BLE Analyzer Pro triple-radio BLE sniffer hardare"
lead: ""
images: []
menu:
  docs:
    parent: ""
    identifier: "wch-ble-analyzer-pro"
weight: 235
toc: true
---

The [WCH BLE Analyzer Pro](https://www.olimex.com/Products/RISC-V/WCH/WCH-BLE-Analyzer-PRO/) is a 3-radio BLE analyzer device which consists of 3 microcontroller-based BLE radios and a USB hub.

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## WCH BLE interfaces

Kismet can address the WCH BLE Analyzer Pro in two ways:

1.  A single logical device, consisting of the three radios.  Each radio will be configured for one of the three advertising channels, and packets will be tagged accordingly.
2.  Individual radios, where each MCU is address independently by Kismet.

To configure as a single logical device, use the device identifier `wch-btle-N` where `N` is the number of the device (typically 0, unless you have multiple WCH BLE Analyzer units).

```
source=wch-btle-0:name="wch ble pro"
```

To configure each MCU independently, use the device identifiers `wch-btle-mcu-X-Y` where `X` and `Y` are the bus and address numbers of the devices on the USB bus (discoverable with `lsusb` or similar tools, or via `kismet_cap_wch_ble_analyzer_pro --list`)

```
source=wch-btle-mcu-32-14:name="wch ble mcu 1"
source=wch-btle-mcu-32-16:name="wch ble mcu 2"
source=wch-btle-mcu-32-17:name="wch ble mcu 3"
```


## Channel Hopping

Each radio is configured to a static channel.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel control

{{<configopt channel "channel number">}}
Configure the channel of a *wch-btle-mcu* single interface.  This option is only useful in single-radio MCU mode.
{{</configopt>}}


{{<configopt channel1 "channel number">}}
Configure the channel of the first MCU in a *wch-btle* logical device.  This option is only useful when using the entire device as a combined logical device.
{{</configopt>}}

{{<configopt channel2 "channel number">}}
Configure the channel of the second MCU in a *wch-btle* logical device.  This option is only useful when using the entire device as a combined logical device.
{{</configopt>}}

{{<configopt channel3 "channel number">}}
Configure the channel of the third MCU in a *wch-btle* logical device.  This option is only useful when using the entire device as a combined logical device.
{{</configopt>}}
