---
title: "Bluetooth: Sniffle BLE (Sonoff ZBDongle-P)"
description: "Sniffle BLE passive sniffer firmware on the Sonoff ZBDongle-P (TI CC2652P)"
lead: ""
images: []
menu:
  docs:
    parent: ""
    identifier: "sniffle-ble"
weight: 236
toc: true
---

[Sniffle](https://github.com/nccgroup/Sniffle) is an actively-maintained open-source BLE 4.x/5 sniffer firmware for TI's CC13x2/CC26x2 chip family. A common, inexpensive way to get this hardware is the Sonoff ZBDongle-P, a USB dongle normally sold for Zigbee use that can be reflashed with Sniffle firmware instead.

## Flashing a Sonoff ZBDongle-P with Sniffle

The Sniffle BLE datasource utilizes serial communications, so no special libraries are needed to build or use it. The dongle does not ship with Sniffle firmware pre-installed, so it must be flashed first.

### Identify the chip revision

The Sonoff ZBDongle-P uses a Silicon Labs CP2102N USB-serial bridge in its standard configuration. According to [Sniffle's own README](https://github.com/nccgroup/Sniffle/blob/master/README.md), some units built in 2022 used a plain CP2102 chip instead, which is capped at a lower baud rate. This chip determines which firmware file and baud rate is needed; flashing the wrong one risks bricking the device.

The USB descriptor cannot be used to tell the two chip revisions apart on this device. Sonoff/ITead overwrite the standard Silicon Labs descriptor strings with their own branding, and both chip revisions share the same USB VID:PID. The only reliable method is opening the case and reading the chip marking printed on the PCB directly.

### Get the flashing tool

Use [`sultanqasim/cc2538-bsl`](https://github.com/sultanqasim/cc2538-bsl):

```bash
git clone https://github.com/sultanqasim/cc2538-bsl.git
cd cc2538-bsl
pip install pyserial intelhex
```

The original `JelmerT/cc2538-bsl` has a known reset-related bug on this hardware, so use the fork above instead. Do not install the optional `python-magic` dependency mentioned in its README; see the known issue below.

### Get the firmware

Download a firmware release from the [Sniffle repository's releases page](https://github.com/nccgroup/Sniffle/releases), and place the `.hex` file in the same `cc2538-bsl` directory that was cloned above (or adjust the path in the flash command below to match wherever it was saved). Which file is needed depends on the chip revision present on the board:

* CP2102N (standard): `sniffle_cc1352p1_cc2652p1.hex`, used at Sniffle's default runtime baud rate of 2,000,000.
* CP2102 (some 2022 chip-shortage units): `sniffle_cc1352p1_cc2652p1_1M.hex` instead. This chip cannot reliably run at 2,000,000 baud, so this variant needs `baud=921600` set on the Kismet source once flashed (see Source parameters, below). This baud difference only applies to talking to the already-flashed firmware, not to the flashing step itself.

### Flash the dongle

From inside the `cc2538-bsl` directory, `--bootloader-sonoff-usb` automates bootloader entry over the USB serial DTR/RTS lines:

```bash
python3 cc2538-bsl.py -p /dev/ttyUSB0 --bootloader-sonoff-usb -ewv sniffle_cc1352p1_cc2652p1.hex
```

`-e` erases, `-w` writes, and `-v` verifies. Keep `-v` despite the extra time it takes, since a failed or mismatched flash on this chip family can brick the device.

If automated bootloader entry fails, the fallback is opening the enclosure and holding the BOOT button on the PCB while it powers on.

If the flash fails immediately with `CmdException: Could not determine firmware type. Magic indicates 'text/x-hex'` before any bootloader communication happens, this is a known `python3-magic`/`libmagic` incompatibility in `cc2538-bsl` on some systems, unrelated to the firmware file or dongle. `python-magic` is only an optional dependency of `cc2538-bsl`, and removing it works around the issue by routing the tool into its own extension-based fallback detection instead:

```bash
sudo apt-get remove python3-magic
```

### Verify the firmware boots

Before configuring anything in Kismet, confirm the flashed firmware actually runs, using Sniffle's own reference client, `sniff_receiver.py`, found at `python_cli/sniff_receiver.py` in the [Sniffle repository](https://github.com/nccgroup/Sniffle):

```bash
git clone https://github.com/nccgroup/Sniffle.git
cd Sniffle/python_cli
pip install pyserial
python3 sniff_receiver.py -s /dev/ttyUSB0 --advonly
```

BLE advertisements should be seen scrolling by immediately. The `--advonly` flag matters here: without it, Sniffle's CLI defaults to connection-following mode instead of general scanning.

## Sniffle BLE interfaces

Sniffle BLE datasources in Kismet can be referred to as `sniffle_ble`. This device appears as a serial port, so it cannot be auto-detected. Each `sniffle_ble` source must have a `device` option:

```
source=sniffle_ble:name=sniffleBLE,device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_XXXXXXXX-if00-port0
```

Using the stable `/dev/serial/by-id/...` path rather than a plain `/dev/ttyUSB0` is recommended, since `ttyUSB` numbering depends on plug-in order and can collide with other serial devices, such as a GPS receiver, on multi-device kits.

## Limitations

Like the Ubertooth One, legacy BLE advertisements cycle across 3 primary channels (37, 38, 39); this datasource listens to only one channel at a time, it does not hop. General "detect anything nearby" coverage is therefore roughly 1/3 of total advertisement traffic for a given channel choice. Use the `channel` option to choose deliberately, or run multiple dongles on different channels for fuller coverage.

Passive discovery, on any sniffer hardware, only ever reveals what a device chooses to broadcast. Some devices intentionally broadcast no service information at all in their advertisements as a privacy measure.

You must specify a `device` option pointing to the serial port this device has been assigned by the kernel. It can not be automatically detected, and will not appear in the datasource list.

## Supported Hardware

This datasource has been confirmed working with the Sonoff ZBDongle-P 3.0 (TI CC2652P) flashed with Sniffle firmware. Other TI CC13x2/CC26x2-family hardware supported by Sniffle itself should also work, since the datasource speaks Sniffle's own serial protocol rather than anything Sonoff-specific, but only the Sonoff ZBDongle-P has been directly tested.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel control

{{<configopt channel "37|38|39">}}
Primary advertising channel to listen on. Defaults to 37 if not specified.
{{</configopt>}}

### Baud rate

{{<configopt baud "921600">}}
Override the serial baud rate. Only needed for the plain-CP2102 chip revision flashed with the `_1M` firmware variant described above; CP2102N units (standard) should omit this and use the default.
{{</configopt>}}
