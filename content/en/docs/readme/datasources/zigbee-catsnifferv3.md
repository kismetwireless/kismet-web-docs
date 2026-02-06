---
title: "Zigbee: Catsniffer v3"
description: ""
lead: ""
date: 2025-10-21T18:34:17-0400
lastmod: 2025-10-21T18:34:29-0400
images: []
menu:
  docs:
    parent: ""
    identifier: "catsnifferv3zigbee"
weight: 510
toc: true
---

The [CatSniffer](https://electroniccats.com/store/catsniffer-v3/) is a multi-radio embedded swiss army knife tool.  With the
appropriate firmware, it can capture Zigbee traffic with Kismet.

While the CatSniffer v1 and v2 devices contain the same radios, it appears the
Zigbee control firmware has not been ported to the previous microcontroller
used, so they currently can not capture Zigbee with Kismet.

## Added 2025-10

The CatSniffer Zigbee datasource is available on Kismet git and release builds
`2025-10` and later.

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

The CatSniffer hardware supports only the 2.4GHz Zigbee channels (12-26).

Despite sharing the frequency range with Wi-Fi on the 2.4GHz band, 802.15.4 uses a different physical encoding standard; a Wi-Fi card is not able to see 802.15.4 packets or networks, and an 802.15.4 device is not able to see Wi-Fi packets.

## CatSniffer v3 Zigbee Capture Firmware

Before using the CatSniffer v3 with Kismet, both the **RP2040 serial passthrough firmware** and the **Zigbee capture firmware** must be flashed to the device. The CatSniffer v3 contains two processors which are programmed separately:

* An **RP2040** (USB interface / serial passthrough)
* A **TI CC1352P** (Zigbee radio)

Precompiled firmware images are available from the [CatSniffer Firmware GitHub releases page](https://github.com/ElectronicCats/CatSniffer-Firmware/releases).

---

### Required firmware files

Download the following firmware files:

**RP2040 serial passthrough firmware**

* [`SerialPassthroughwithboot_RP2040_v1.1.uf2`](https://github.com/ElectronicCats/CatSniffer-Firmware/releases/download/board-v3.x-v1.1.0/SerialPassthroughwithboot_RP2040_v1.1.uf2)

**Zigbee capture firmware (CC1352P)**

* [`sniffer_fw_CC1352P_7_v1.10.hex`](https://github.com/ElectronicCats/CatSniffer-Firmware/releases/download/board-v3.x-v1.2.2/sniffer_fw_CC1352P_7_v1.10.hex)

Flashing the CC1352P firmware requires the [`cc2538-bsl`](https://github.com/ElectronicCats/CatSniffer-Tools/blob/main/cc2538-bsl/cc2538-bsl.py) utility from the CatSniffer Tools repository.

---

### Flashing the RP2040 serial passthrough firmware

This step was tested on Windows. Linux behavior should be similar, though the volume may have to be mounted manually.

1. Connect the unflashed CatSniffer v3 to the system using its USB-C port.
2. Quickly double-click the **reset1** button.
3. A removable storage device named **RPI-RP2** should appear. At this point, the on-board LEDs should be off.
4. Copy the `SerialPassthroughwithboot_RP2040_v1.1.uf2` file into the root of the **RPI-RP2** volume.
5. Once the file is copied, the volume should automatically disconnect.

---

### Verifying RP2040 firmware behavior

1. Press and hold the **boot1** button.
2. While holding **boot1**, press and release **reset1**.
3. Release the **boot1** button.

Two solid blue LEDs should now be visible. After physically disconnecting and reconnecting the device, the LEDs should exhibit a sequential “waterfall” blink pattern, indicating that the serial passthrough firmware is running correctly.

In some cases, the serial passthrough firmware may need to be loaded **twice** before the waterfall LED behavior appears. The cause of this behavior is currently unknown.

A general visual reference for flashing the serial passthrough firmware is available here:

* [https://www.youtube.com/watch?v=GgVDzQrIjXc](https://www.youtube.com/watch?v=GgVDzQrIjXc)
  Note that the Zigbee firmware used in this documentation differs from the firmware shown in that video while the passthrough firmware is the same.

---

### Preparing a Linux environment for Zigbee firmware flashing

The following steps were tested using a Kali Linux virtual machine.

Install required Python dependencies for `cc2538-bsl.py`:

```bash
pip install pyserial
pip install intelhex
pip install python-magic
```

---

### Flashing the CC1352P Zigbee firmware

1. Connect the CatSniffer v3 to the Linux system.
2. The device should enumerate as `/dev/ttyACM0`.

Verify the device identity:

```bash
lsusb
```

Expected output should be similar to:

```
ID 2e8a:00c0 Arduino RaspberryPi Pico
```

Additional confirmation:

```bash
udevadm info -a -n /dev/ttyACM0 | grep ATTRS{product}
```

Expected output:

```
ATTRS{product}=="RaspberryPi Pico"
```

3. Use the `cc2538-bsl.py` uploader to flash the Zigbee firmware:

```bash
sudo python3 cc2538-bsl.py -e -w -v sniffer_fw_CC1352P_7_v1.10.hex
```

The CatSniffer `catnip` uploader did not function reliably during testing; `cc2538-bsl.py` is recommended.

After flashing, you may need to unplug and reconnect the device before it begins operating normally.

---

### Testing the CatSniffer with cat_sniffer.py

To validate that the device is working correctly, use the `cat_sniffer.py` tool from the CatSniffer Tools repository:

* [https://github.com/ElectronicCats/CatSniffer-Tools/blob/main/pycatsniffer_bv3/cat_sniffer.py](https://github.com/ElectronicCats/CatSniffer-Tools/blob/main/pycatsniffer_bv3/cat_sniffer.py)

A Zigbee device must be active nearby, and the correct channel must be known.

Example usage:

```bash
cd pycatsniffer_bv3
sudo python3 cat_sniffer.py sniff /dev/ttyACM0 -phy 1 -ch 15 -v
```

To capture packets directly into Wireshark:

```bash
sudo python3 cat_sniffer.py sniff /dev/ttyACM0 -phy 1 -ch 12 -ff -ws -v
```

Type `stop` in the CLI to end capture and save the PCAP file. Closing Wireshark directly may terminate the script.

---

### Known issues

* The current version of `cat_sniffer.py` does **not** display Zigbee channel information correctly. The channel is not embedded in the packet frame, contrary to the tool’s assumption.

## Supported Hardware

While the CatSniffer v1 and v2 devices may be capable of running the sniffer
firmware, it is not immediately obvious if there is a version of the sniffer
firmware which works on the v1 and v2 versions of the hardware.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

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
source=catsniffer_zigbee:device=/dev/ttyUSB0,name=Foo,channel_hop=false,channel=12
```
{{</configopt>}}


{{<configopt channels "channel1,channel2,...,channelN">}}
Set a fixed list of channels instead of probing the source for all supported channels.

The list of channels must be:

* Comma separated
* Contained in quotes

Example:

```
source=catsniffer_zigbee:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"
```

If defining datasources on the command line when launching Kismet, be aware that most shells will elide the quotes, leading to a setup error.  You can avoid this by surrounding the source definition in single quotes:

```bash
kismet -c 'catsniffer_zigbee:device=/dev/ttyUSB0,name=Foo,channels="12,13,14,15"'
```
{{</configopt>}}
