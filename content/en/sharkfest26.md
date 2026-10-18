---
layout: "docs"
title: "Sharkfest 2026 Resources"
description: ""
date: 2026-07-20
images: []
toc: true
homepage: false
aliases: ["/sharkfest26/"]
---

## Sharkfest 2026 Resources

Many of these will link to the US version of Amazon, but should be available
world-wide.

What matters is the chipset inside, so be sure to get a device with the right
innards!

### Cheap Linux Hardware
* [Lenovo M920Q](https://www.amazon.com/Lenovo-ThinkCentre-M920Q-Micro-Desktop/dp/B0FMS8DX87) - Lenovo mini PC
* [HP EliteDesk](https://www.amazon.com/HP-EliteDesk-Hexa-Core-Bluetooth-DisplayPort/dp/B0CHWPQNGF) - HP equivalent mini PC
* [ZimaBlade](https://www.amazon.com/ZimaBlade-Personal-Capacity-Quad-Core-Expandable/dp/B0FBFQDXSQ) - Zimablade micro Intel board, may be more hassle to get working than Lenovo or HP

### Wi-Fi

#### 802.11 6e tri-band capable USB (2.5GHz, 5GHz, 6GHz)
* [Panda PAU0F AXE3000](https://www.amazon.com/Panda-Wireless®-PAU0F-AXE3000-Adapter/dp/B0D972VY9B) - Panda mt792x tri-band, works well in Linux
* [eDUP AX3000](https://www.amazon.com/EDUP-Wireless-802-11AX-Tri-Band-Compatible/dp/B0CZ82RM5L) - eDUP mt792x tri-band
* [Alfa AWUS036AXML](https://www.amazon.com/ALFA-AWUS036AXML-802-11axe-Adapter-AXE3000/dp/B0BY8GMW32) - more expensive but reliable mt792x

#### 802.11 dual-band capable USB (2.4GHz, 5GHz)
* [Panda PAU0D](https://www.amazon.com/Panda-Wireless®-Wireless-Adapter-Antennas/dp/B0B2QD6RPX) - mt7612
* [Alfa AWUS036ACM](https://www.amazon.com/gp/product/B073X6RL9D) - more expensive but reliable, also using the mt7612 chipset

#### Software
* [gr-ieee-80211](https://github.com/bastibl/gr-ieee802-11) - GNU Radio IEEE 802.11a and 802.11g decoder
* [Nuand wi-phy](https://www.nuand.com/bladerf-wiphy/) - FPGA gateware modem for 802.11n on the Nuand BladeRF SDR

### Bluetooth
#### Hardware
* [cc2540](https://www.amazon.com/YOURRYONG-CC2531-protocol-analysis-antenna/dp/B0CXND3NZC) - TI CC2540 BLE sniffer with external antenna
* [Bluefruit nrf](https://www.adafruit.com/product/2269) - Bluefruit NRF5182 sniffer
* [Ubertooth One](https://greatscottgadgets.com/ubertoothone/) - Discontinued Bluetooth Classic and BTLE discovery tool
* [Olimex WCH-BLE Analyzer Pro](https://www.olimex.com/Products/RISC-V/WCH/WCH-BLE-Analyzer-PRO/) - Multiple BLE sniffers on one device, but with questionable official software
* [WCH-BLE Analyzer Pro via Digikey](https://www.digikey.com/en/products/detail/olimex-ltd/WCH-BLE-ANALYZER-PRO/26716965) - Digikey source for the WCH-BLE device
* [Sonoff USB](https://www.amazon.com/SONOFF-Universal-Wireless-Assistant-Zigbee2MQTT/dp/B0B6P22YJC) - Sonoff USB dongle supported by SniffLE

#### Software
* [SniffLE](https://github.com/nccgroup/Sniffle) - Sniffer firmware and tools for multiple hardware devices
* [Reverse Engineered WCH-BLE Drivers](https://github.com/xecaz/BLE-Analyzer-pro-linux-capture) - Reverse engineered WCH-BLE USB drivers for PCAP on Linux and macOS
* [Ice9 SDR sniffer](https://github.com/mikeryan/ice9-bluetooth-sniffer) - Mike Ryan's ice9 Bluetooth sniffer for multiple SDR platforms
* [Android HCI Snoop](https://medium.com/propeller-health-tech-blog/bluetooth-le-packet-capture-on-android-a2109439b2a1) - Directions for using an Android device to snoop

### Zigbee
#### Hardware
* [cc2531](https://www.amazon.com/YOURRYONG-CC2531-protocol-analysis-antenna/dp/B0CXND3NZC) - TI CC2531 zigbee sniffer with external antenna
* [Sonoff USB](https://www.amazon.com/SONOFF-Universal-Wireless-Assistant-Zigbee2MQTT/dp/B0B6P22YJC) - Sonoff USB supported by SniffLE and other tools

#### Software
* [FutureSDR Web Zigbee](https://www.futuresdr.org/blog/wasm-zigbee/) - Decoding zigbee entirely in the browser using webUSB and wasm

### LORA

#### Hardware
* [catwan](https://github.com/ElectronicCats/CatWAN_USB_Stick/wiki/#using-lora-sniffer-tool) - catwan multi-radio tool with lora support
* [rtlsdr](https://www.amazon.com/RTL2832U-Software-Defined-Receiver-Multipurpose/dp/B0GYP1C4X3) - cheap SDR

#### Software
* [lorapipe](https://github.com/krak3n77/lorapipe) - firmware for sniffing Lora packets on commodity lora radios
* [catwan lorasniffer](https://github.com/calefrey/scapy-meshtastic/tree/main/LoRaSniffer) - firmware for sniffing lora packets on catwan multiradio tools
* [decoding lora with rtlsdr](https://www.rtl-sdr.com/decoding-the-iot-lora-protocol-with-an-rtl-sdr/) - rtl-sdr post about decoding lora with cheap radios

### SDR
* [HackRF](https://greatscottgadgets.com/hackrf/pro/) - 8bit TX capable SDR
* [BladeRF](https://www.nuand.com/bladerf-2-0-micro/) - 16 bit TX capable SDR + FPGA

* [RTL_433](https://github.com/merbanan/rtl_433) - Sensor decoder for 300, 433, 900 MHz sensors with a RTL-SDR

