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

The SDR 900MHz capture helper is not currently part of Kismet's default `make` / `make install`, so it needs one extra manual step after building Kismet itself:

```bash
cd capture_sdr_zigbee900
make
sudo cp kismet_cap_sdr_zigbee900 /usr/local/bin/
```

Adjust the destination to match wherever your Kismet install places its other capture helpers (typically the same directory as `kismet_cap_linux_wifi`, etc.) if you configured a different `--prefix`.

The GNU Radio decoder script also needs to be somewhere Kismet's capture helper can find it. The default location it looks for is:

```bash
sudo mkdir -p /usr/share/kismet/zigbee900
sudo cp capture_sdr_zigbee900/zigbee900_live_rx.py /usr/share/kismet/zigbee900/
sudo chmod +x /usr/share/kismet/zigbee900/zigbee900_live_rx.py
```

If you'd rather keep the script somewhere else, point at it directly with the `script=` source option instead of installing it to the default path (see Source parameters, below).

## Legacy 900MHz IEEE 802.15.4

The 902-928MHz US/international ISM band supports two of the PHYs defined in IEEE 802.15.4-2006:

| PHY   | Clause | Chip rate  | Data rate | Status in this datasource                                  |
| ----- | ------ | ---------- | --------- | ------------------------------------------------------------ |
| BPSK  | 6.6    | 600kchip/s | 40kb/s    | Confirmed against a real transmitter and the standard text   |
| O-QPSK| 6.8    | 1Mchip/s   | 250kb/s   | Passes offline decode tests; not yet confirmed against a real O-QPSK transmission |

Both PHYs share the same channel plan, so no separate configuration is needed to pick between them; the decoder listens for both simultaneously on whichever channel is tuned.

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

The capture helper always uses the first RTL-SDR device it finds; see Limitations, below, if more than one SDR is attached to the system.

## Limitations

* Only the first RTL-SDR device on the system is used. There is currently no option to select a specific unit by serial number, and only one `zigbee900sdr` source can be run at a time on a given system.
* The default source UUID is a fixed value derived from the capture helper's own name, not from the RTL-SDR's hardware serial number (unlike the `rtl433`/`rtlamr` datasources). If you script around the UUID, set one explicitly with `uuid=` rather than relying on the default.
* The O-QPSK PHY has only been validated with synthetic, known-plaintext test data offline; it has not yet been confirmed decoding a real over-the-air O-QPSK transmission. Treat O-QPSK reception as unverified until tested against real hardware transmitting that PHY.
* Radio gain (RTL-SDR gain plus IF/baseband gain stages) is fixed in `zigbee900_live_rx.py` rather than exposed as a source option. These values were tuned against one specific RTL-SDR Blog V4 unit at short range; a different unit, antenna, or link distance may need the script's `RTL_GAIN` and related constants adjusted directly.

## Supported hardware

This datasource has been tested against a [RTL-SDR Blog V4](https://www.rtl-sdr.com/buy-rtl-sdr-dvb-t-dongles/). Other RTL2832U-based dongles use the same `gr-osmosdr` `rtl` backend and should work in principle, but only the Blog V4 has been directly confirmed.

## Source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Script location

{{<configopt script "/path/to/zigbee900_live_rx.py">}}
Override the decoder script path. Defaults to `/usr/share/kismet/zigbee900/zigbee900_live_rx.py`; only needed if the script has been placed somewhere other than the default install location described above.

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
Override the auto-generated source UUID. See Limitations, above, for why this matters more here than on most other datasources.
{{</configopt>}}
