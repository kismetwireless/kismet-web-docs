---
title: "Zigbee - SDR 900MHz (RTL-SDR)"
description: "Legacy 900MHz IEEE 802.15.4 BPSK/O-QPSK receiver using a RTL-SDR and a bundled GNU Radio decoder"
lead: ""
images: []
menu:
  docs:
    parent: ""
    identifier: "zigbee-sdrzigbee900-7f3a1c9e6b2d4f08a51e9c7d3b6a2f14"
weight: 520
toc: true
---

Kismet can decode the legacy 900MHz IEEE 802.15.4 PHYs (802.15.4-2006 clause 6.6 BPSK, and the optional clause 6.8 O-QPSK PHY) using a cheap [RTL-SDR](https://www.rtl-sdr.com) software defined radio. Unlike most SDR datasources in Kismet, which spawn an existing third-party decode tool (`rtl_433`, for example), there is no independent open-source decoder for this legacy PHY, so the demodulation and frame sync is a GNU Radio flowgraph bundled directly with Kismet (`zigbee900_live_rx.py`).

The SDR 900MHz source can be manually specified with `zigbee900sdr`:
```
source=zigbee900sdr:name=zigbee900
```

## Required software

The Kismet SDR 900MHz source is Python/GNU Radio glue spawned by a small C capture helper (`kismet_cap_sdr_zigbee900`), similar in shape to the `rtl_433`/`rtl_433_v2` datasource. The following must be available on the system running the capture:

* `python3`, found via `$PATH` at capture time
* [GNU Radio](https://www.gnuradio.org) (3.10 or newer), including its Python bindings
* [gr-osmosdr](https://github.com/osmocom/gr-osmosdr), used to talk to the RTL-SDR hardware
* `numpy`

On most distributions these are available as packages (`gnuradio`, `gr-osmosdr`, `python3-numpy`, or similarly named); consult your distribution's packaging if a `pip install` is more convenient.

## Building and installing the datasource

After 2026-10-R1, the SDR 900MHz capture helper is built and installed with Kismet when `configure` finds librtlsdr and libusb (`RTL-SDR Zigbee 900M` in the `configure` summary), and is packaged as `kismet-capture-zigbee900`.  `make install` installs the GNU Radio decoder script as `<prefix>/share/kismet/zigbee900/zigbee900_live_rx.py` (`/usr/share/kismet/zigbee900/` for packages), where the capture helper looks for it.

Through 2026-10-R1, the helper and script had to be built and copied by hand:

```bash
cd capture_sdr_zigbee900
make
sudo cp kismet_cap_sdr_zigbee900 /usr/local/bin/
sudo mkdir -p /usr/share/kismet/zigbee900
sudo cp zigbee900_live_rx.py /usr/share/kismet/zigbee900/
```

If you'd rather keep the script somewhere else, point at it directly with the `script=` source option (see Source parameters, below).

After 2026-10-R1, the capture helper is no longer installed suid-root; it, and the script, run as the user who launched Kismet, so that user needs permission to use the RTL-SDR USB device.  The `kismet-capture-zigbee900` package installs a udev rule which gives the `kismet` group access; otherwise, use the udev rules installed with `librtlsdr` or `rtl-sdr`.  If the helper is run as root (such as by running Kismet with `sudo`), `script=` is refused, and only the installed script is used.

## Legacy 900MHz IEEE 802.15.4

The 902-928MHz US/international ISM band supports two of the PHYs defined in IEEE 802.15.4-2006:

| PHY   | Clause | Chip rate  | Data rate | Status in this datasource                                  |
| ----- | ------ | ---------- | --------- | ------------------------------------------------------------ |
| BPSK  | 6.6    | 600kchip/s | 40kb/s    | Confirmed against a real transmitter and the standard text   |
| O-QPSK| 6.8    | 1Mchip/s   | 250kb/s   | Passes offline decode tests; not yet confirmed against a real O-QPSK transmission |

Both PHYs share the same channel plan, so no separate configuration is needed to pick between them; the decoder listens for both simultaneously on whichever channel is tuned.

Kismet also decodes what it can of the network above 802.15.4: Zigbee and Thread beacons, the Zigbee network (NWK) header, 6LoWPAN and Thread MLE.  Devices are labelled as Zigbee coordinators, routers and devices, Zigbee Green Power devices, Thread devices or 6LoWPAN devices.  The device details show the network, role, PAN and short address, the device's IEEE (EUI-64) address when a Zigbee NWK header carries it, the extended PAN ID, the Thread network name and the Zigbee stack profile.  Green Power devices, which have no MAC address of their own, are tracked by their source ID.  Frames encrypted at the 802.15.4 MAC layer can't be read past their header.

After 2026-10-R1, Kismet learns more about Thread networks:

* Thread Discovery Requests and Responses are decoded.  A response gives the network's name, extended PAN ID, Thread version, whether it is accepting new devices, whether a native commissioner may join, and the joiner port; a request marks its sender as scanning for networks or looking for one to join.  An open network raises the [THREADJOINABLE](/docs/readme/alerts/alerts/#threadjoinable) alert.
* Thread 1.1 beacons also give the version and whether the network is accepting new devices, and their extended PAN ID is shown in the right byte order; before, it was reversed like a Zigbee one.
* Most Thread frames are encrypted, so a device on a PAN which Kismet has seen to be a Thread network, on the same channel, is labelled Thread with the network's name and extended PAN ID, unless its own frames say it is Zigbee.
* Thread routers and end devices are told apart by their short address (RLOC16), which gives the router and child ID, and an end device is linked to its parent router.  Routers show the children, and the routers of their network, heard in the last hour; sleepy end devices show how often they poll their parent, and CSL end devices their CSL period.  The MAC key index and MLE key sequence show how many times the network key has rotated.

| Field | Contents |
| ----- | -------- |
| `802154.device.thread_version` | Thread version: 2 Thread 1.1, 3 1.2, 4 1.3, 5 1.4 |
| `802154.device.thread_joining` | Whether its network takes new devices: 1 no, 2 the devices its commissioner lists, 3 any |
| `802154.device.thread_native` | Its network allows a native commissioner |
| `802154.device.thread_joiner_port` | The UDP port joining devices use to reach it |
| `802154.device.thread_discovery` | Its discovery requests: 1 looking for networks, 2 looking for a network to join |
| `802154.device.thread_router_id`, `thread_child_id` | Router and child ID from its short address; child ID 0 for a router |
| `802154.device.thread_parent` | The device key of its parent router |
| `802154.device.thread_children`, `thread_routers` | A router's children, and the routers of its network, heard in the last hour |
| `802154.device.thread_polls`, `thread_poll_interval` | Data polls sent to its parent, and the usual time between them in milliseconds |
| `802154.device.thread_csl_period` | Its CSL period, in units of 10 symbols (160 µs at 2.4 GHz) |
| `802154.device.thread_key_index`, `thread_key_seq` | The key index of its MAC security, and the key sequence of its MLE security |

### 900MHz channels

| Channel | Frequency  |
| ------- | ---------- |
| 1       | 906MHz     |
| 2-9     | 908-922MHz (2MHz spacing) |
| 10      | 924MHz     |

Channel numbering follows 802.15.4-2006 6.1.2.1 (`Fc = 906 + 2*(k-1) MHz`). The 868MHz European single-channel band (channel 0 in the standard) is not implemented by this datasource.

## SDR 900MHz interfaces

Kismet identifies this source as `zigbee900sdr`:

```
source=zigbee900sdr:name=zigbee900
```

A specific RTL-SDR can be targeted with a `zigbee900sdr-<idx or serial>` interface, the same convention the `rtl433`/`rtl433_v2` datasource uses. Bare `zigbee900sdr` refers to device 0.

```
source=zigbee900sdr-0:name=zigbee900_first
source=zigbee900sdr-1:name=zigbee900_second
source=zigbee900sdr-AB12CD34:name=zigbee900_by_serial
```

This lets a `zigbee900sdr` source run alongside other RTL-SDR-backed sources, or a second `zigbee900sdr` instance, each pinned to its own physical device.

## Reported per-frame metadata

Each decoded frame carries the channel it was captured on and a signal strength reading.

Channel and frequency reflect whatever channel the decoder was actually tuned to at capture time, not just the source's nominal channel at open. `kismet.device.base.frequency` is reported in kHz, following the 802.15.4-2006 6.1.2.1 channel plan.

Signal strength is a dBFS style reading of channel power, sampled ahead of the receive chain's squelch and AGC stages; downstream of AGC the amplitude is normalized toward a fixed reference, so measuring there would not reflect the real received power. This is a relative value, not a calibrated absolute dBm reading, the same caveat that applies to most RTL-SDR based Kismet datasources.

## Limitations

* The O-QPSK PHY has only been validated with synthetic, known-plaintext test data offline; it has not been confirmed against a real over-the-air O-QPSK transmission. Treat O-QPSK reception as unverified until tested with real hardware transmitting that PHY.
* Radio gain (RTL-SDR gain plus IF and baseband gain stages) is fixed in `zigbee900_live_rx.py` rather than exposed as a source option. These values were tuned against one RTL-SDR Blog V4 unit at short range; a different unit, antenna, or link distance may need the script's `RTL_GAIN` and related constants adjusted directly. A transmitter very close to the receiver can saturate the ADC at the default gain.
* Reported signal strength is relative, not a calibrated absolute dBm reading. See Reported per-frame metadata, above.

## Supported hardware

This datasource has been tested against a [RTL-SDR Blog V4](https://www.rtl-sdr.com/buy-rtl-sdr-dvb-t-dongles/). Other RTL2832U-based dongles use the same `gr-osmosdr` `rtl` backend and should work in principle, but only the Blog V4 has been directly confirmed.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Script location

{{<configopt script "/path/to/zigbee900_live_rx.py">}}
Override the decoder script path. Defaults to `<prefix>/share/kismet/zigbee900/zigbee900_live_rx.py` (through 2026-10-R1, always `/usr/share/kismet/zigbee900/zigbee900_live_rx.py`); only needed if the script has been placed somewhere other than the default install location described above.  After 2026-10-R1, `script=` is refused when the capture helper runs as root.

```
source=zigbee900sdr:name=zigbee900,script=/opt/kismet/zigbee900_live_rx.py
```
{{</configopt>}}

### Channel control options

{{<configopt channel "1-10">}}
Set the initial channel. Defaults to channel 1 (906MHz) if not specified. This source supports Kismet's normal [channel hopping](/docs/readme/datasources/channelhop/#configuration) across all 10 channels.
{{</configopt>}}

### Source identification

{{<configopt uuid "uuid-value">}}
Override the auto-generated source UUID. By default the UUID is derived from the targeted RTL-SDR device's own manufacturer, product, and serial strings, the same approach the `rtl433` datasource uses, so it is already stable and distinct per physical device without needing this option set explicitly.
{{</configopt>}}
