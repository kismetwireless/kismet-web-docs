---
title: "Bluetooth: nRF 51822"
description: ""
lead: ""
date: 2022-09-03T13:39:27-04:00
lastmod: 2022-09-03T13:39:27-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "nrf51822-da3645542063d1b12b931cad2044213c"
weight: 230
toc: true
---

The nRF 51822 is a chip used for Bluetooth LE communications.   To use it with Kismet, it must be flashed with sniffer firmware provided by NordicRF.  A pre-flashed version is available from [Adafruit](https://www.adafruit.com/product/2269) and other online retailers.

The nRF 51822 utilizes serial communications so no special libraries are needed for use with Kismet, *however* not all platforms have working serial port drivers (see below).

## Bluetooth

Bluetooth uses a frequency-hopping system with dynamic MAC addresses and other oddities - this makes sniffing it not as straightforward as capturing Wi-Fi.

## nRF 51822 interfaces

nRF 51822 datasources in Kismet can be referred to as simply `nrf51822`.  These devices appear as serial ports, so cannot be auto-detected.  Each nrf51822 source must have a `device` option:

```
source=nrf51822:device=/dev/ttyUSB0
```

Because there is no unique information available for the nrf51822 source, if you have multiple devices on a single system, or are using remote capture, be sure to set a unique UUID for each source!

## Channel Hopping

The firmware does it's own channel hopping so no selections are available.

## Limitations

You must specify a `device=` configuration pointing to the serial port this device has been assigned by the kernel; it can not be automatically detected, and will not appear in the datasource list.

Multiple versions of the Adafruit BLE device are sold, and not all have the sniffer firmware.  Make sure you have a V2 or newer device, *with the sniffer firmware*.

Devices without sniffer firmware *may* be flashable, but may require an external programmer.

### macOS limitations

The nRF 51822 uses a CP2104 serial chip; testing with the [latest drivers](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers) under MacOS Catalina has been unsuccessful; however a driver update may fix that in the future.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device selection

{{<configopt device "/path/to/serial/device">}}
The nRF 518222 devices appear as USB serial devices, and serial devices can not be auto-discovered.

You *must* provide the path to the serial device associated with the nRF 51822 sniffer.
{{</configopt>}}
