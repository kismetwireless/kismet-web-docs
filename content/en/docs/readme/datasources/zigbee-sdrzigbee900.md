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
Override the auto-generated source UUID. By default the UUID is derived from the targeted RTL-SDR device's own manufacturer, product, and serial strings, the same approach the `rtl433`/`rtlamr` datasources use, so it is already stable and distinct per physical device without needing this option set explicitly.
{{</configopt>}}
