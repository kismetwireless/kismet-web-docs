---
title: "LoRa: LoraPipe"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "lora-lorapipe-f862ea4b16d74c229738ea6e5940e9b7"
weight: 300
toc: true
---

Added: `2026-10`

The LoraPipe source captures LoRa packets from a LoRa radio microcontroller running the LoraPipe sniffer firmware, connected over a serial port.

Kismet decodes [Meshtastic](https://meshtastic.org) and [MeshCore](https://github.com/meshcore-dev/MeshCore) mesh networks from LoRa captures, and records other LoRa packets as generic LoRa.

LoraPipe sources are named `lorapipe`, and must include the `device` and `region` options:

```bash
kismet -c lorapipe:device=/dev/ttyUSB0,region=US
```

## Supported hardware

The LoraPipe source requires a LoRa microcontroller running LoraPipe sniffer firmware, connected via USB serial.

## Compiling LoraPipe support

LoraPipe support is built automatically, and needs no additional libraries.

## Kismet LoraPipe support

LoRa radios receive on one frequency, bandwidth, spreading factor, and sync word at a time.  The sync word separates networks: Meshtastic uses `0x2b`, and MeshCore uses `0x12`.  Kismet passes packets to the Meshtastic or MeshCore decoder based on the sync word they were received with.

Changing channels on a LoRa radio is slow, and mesh networks transmit infrequently, so the LoraPipe source hops at most once every 30 seconds.  For best results, lock the source to the channel used by the network you want to watch.

Packets are logged in [pcapng](/docs/readme/logging/pcap/) and [kismetdb](/docs/readme/logging/kismetdb/) logs with LoRaTAP headers, which Wireshark can decode.

## Channels

Channels can be given as a protocol preset, or as raw radio settings.

### Presets

Preset channels are named `protocol-region-preset`:

```
meshtastic-US-LONG_FAST
meshcore-US-NARROW
```

Preset names are not case-sensitive, and underscores are ignored, so `meshtastic-us-longfast` is the same as `meshtastic-US-LONG_FAST`.

**Meshtastic** presets are `LONG_FAST`, `LONG_SLOW`, `LONG_MODERATE`, `LONG_TURBO`, `MEDIUM_FAST`, `MEDIUM_SLOW`, `SHORT_FAST`, `SHORT_SLOW`, and `SHORT_TURBO`.  The frequency is chosen the same way the Meshtastic firmware chooses the default frequency slot for the preset in the region.  Turbo presets are not available in `EU_868`.

**MeshCore** presets are taken from the preset list used by the MeshCore apps, and grouped by region: for example `meshcore-US-NARROW`, `meshcore-EU_868-NARROW`, and `meshcore-ANZ-DEFAULT`.

The frequency and radio settings of every preset in every region are listed in the [channel reference](#channel-reference) below.

The LoRa header carries the coding rate, so a radio receives packets of any coding rate on the same frequency, bandwidth, and spreading factor.  MeshCore presets which differ only in coding rate share a single slot in the hopping list.

### Raw radio settings

Any radio configuration can be given as `frequency-bandwidth-spreading-coding-syncword`, with the frequency in MHz, the bandwidth in kHz, and the sync word in hex:

```
906.875-250-11-5-2b
910.525-62.5-7-5-12
```

### Regions

The region selects the channel list for hopping, and the presets available.  The supported regions are `US`, `EU_433`, `EU_868`, `EU_866`, `EU_N_868`, `CN`, `JP`, `ANZ`, `ANZ_433`, `RU`, `KR`, `TW`, `IN`, `NZ_865`, `TH`, `UA_433`, `MY_433`, `MY_919`, `SG_923`, `PH_433`, `PH_868`, `PH_915`, `KZ_433`, `KZ_863`, `NP_865`, `BR_902`, `ITU1_2M`, `ITU2_2M`, `ITU3_2M`, `ITU2_125CM`, `ITU1_70CM`, `ITU2_70CM`, `ITU3_70CM`, and `LORA_24`.

The hopping list for a region contains the Meshtastic presets, followed by the MeshCore presets for the region.  A source can only be opened in a region with at least one preset; regions with no Meshtastic or MeshCore presets, such as `EU_866`, `EU_N_868`, and the `ITU` amateur bands, can not currently be used.

## LoraPipe source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Device options

{{<configopt device "/path/to/serial/device">}}
The serial device of the LoraPipe radio.  This option is required.
{{</configopt>}}

{{<configopt baud "baudrate">}}
The serial baud rate; by default `115200`.  This should only be changed if the LoraPipe firmware was built for a different rate.
{{</configopt>}}

### Channel options

{{<configopt region "region">}}
The region used to build the channel list.  This option is required.
{{</configopt>}}

{{<configopt channel "preset or radio settings">}}
The channel to tune to when the source opens.  If no channel is given, the first channel of the region is used.

To stay on a single channel, also set `channel_hop=false`:

```
source=lorapipe:device=/dev/ttyUSB0,region=US,channel=meshcore-US-NARROW,channel_hop=false
```
{{</configopt>}}

The common [channel and hopping](/docs/readme/datasources/channelhop/) options are also supported.

## Meshtastic

Kismet decodes Meshtastic packets, including node info, position, and text messages.  Packets on encrypted channels are decrypted when the channel key is known; the default channel for every modem preset, with the default key, is always enabled.

Additional channels and keys are set in `kismet_meshtastic.conf`, as `meshtastic_key=channelname,base64key`:

```
meshtastic_key=MyChannel,AQ==
```

The channel name must exactly match the Meshtastic channel name, and the key is the base64 key shown by the Meshtastic apps or in a channel URL.

The number of messages kept per channel is set with `meshtastic_num_messages`, by default `128`.

Channels and recent messages are available from the REST API at `/meshtastic/channels.json`.

## MeshCore

Kismet decodes MeshCore packets.  Devices are created from node adverts, which carry the node public key, name, type (companion, repeater, room server, or sensor), and optional location, and are signed by the node.  Only adverts with valid signatures create devices; other packets refer to nodes by the first bytes of their public key, and are attributed to nodes already known from adverts.

When a packet is relayed through the mesh, the repeater which transmitted it is credited with relaying the packet.

Group messages on the public channel are decrypted automatically.  Private channels and hashtag channels are set in `kismet_meshcore.conf`:

```
meshcore_key=MyChannel,base64key
meshcore_hashtag=#test
```

Private channel keys are the 16 or 32 byte channel secret shown by the MeshCore apps, in base64.  Hashtag channel keys are derived from the channel name.

The number of messages kept per channel is set with `meshcore_num_messages`, by default `128`.

Channels and recent messages are available from the REST API at `/meshcore/channels.json`.

Direct messages between nodes are encrypted with keys known only to the two nodes, and can not be decoded.

An advert with an invalid signature raises the `MESHCOREBADSIG` alert, as it may be an attempt to impersonate a node.

## Channel reference

The channels generated for each region, in hopping order, with the radio settings each one tunes to.  Channels marked "not hopped" are MeshCore presets which share a frequency, bandwidth, and spreading factor with an earlier preset; they are left out of the hopping list, but can still be used with `channel=`.

### US

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-US-LONG_TURBO` | 908.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-US-LONG_FAST` | 906.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-US-LONG_SLOW` | 905.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-US-MEDIUM_FAST` | 913.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-US-MEDIUM_SLOW` | 914.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-US-SHORT_FAST` | 918.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-US-SHORT_SLOW` | 920.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-US-LONG_MODERATE` | 902.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-US-SHORT_TURBO` | 926.750 | 500 | 7 | 4/5 | `0x2b` |
| `meshcore-US-NARROW` | 910.525 | 62.5 | 7 | 4/5 | `0x12` |
| `meshcore-US-SOCAL` | 927.875 | 62.5 | 7 | 4/5 | `0x12` |
| `meshcore-US-COSTA_RICA` | 910.525 | 125 | 11 | 4/5 | `0x12` |

### EU_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-EU_433-LONG_TURBO` | 433.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-EU_433-LONG_FAST` | 433.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-EU_433-LONG_SLOW` | 433.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-EU_433-MEDIUM_FAST` | 433.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-EU_433-MEDIUM_SLOW` | 433.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-EU_433-SHORT_FAST` | 433.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-EU_433-SHORT_SLOW` | 433.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-EU_433-LONG_MODERATE` | 433.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-EU_433-SHORT_TURBO` | 433.750 | 500 | 7 | 4/5 | `0x2b` |
| `meshcore-EU_433-LONG` | 433.650 | 250 | 11 | 4/5 | `0x12` |
| `meshcore-EU_433-NARROW` | 433.650 | 62.5 | 8 | 4/8 | `0x12` |
| `meshcore-EU_433-PORTUGAL` | 433.375 | 62.5 | 9 | 4/6 | `0x12` |

### EU_868

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-EU_868-LONG_FAST` | 869.525 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-EU_868-LONG_SLOW` | 869.4625 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-EU_868-MEDIUM_FAST` | 869.525 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-EU_868-MEDIUM_SLOW` | 869.525 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-EU_868-SHORT_FAST` | 869.525 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-EU_868-SHORT_SLOW` | 869.525 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-EU_868-LONG_MODERATE` | 869.5875 | 125 | 11 | 4/8 | `0x2b` |
| `meshcore-EU_868-NARROW` | 869.618 | 62.5 | 8 | 4/8 | `0x12` |
| `meshcore-EU_868-SF7` | 869.618 | 62.5 | 7 | 4/5 | `0x12` |
| `meshcore-EU_868-CZECH` | 869.432 | 62.5 | 7 | 4/5 | `0x12` |
| `meshcore-EU_868-LEGACY` | 869.525 | 250 | 11 | 4/5 | `0x12` |
| `meshcore-EU_868-DEFAULT` (not hopped) | 869.618 | 62.5 | 8 | 4/5 | `0x12` |
| `meshcore-EU_868-PORTUGAL` (not hopped) | 869.618 | 62.5 | 7 | 4/6 | `0x12` |

### CN

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-CN-LONG_TURBO` | 470.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-CN-LONG_FAST` | 478.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-CN-LONG_SLOW` | 493.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-CN-MEDIUM_FAST` | 507.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-CN-MEDIUM_SLOW` | 504.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-CN-SHORT_FAST` | 494.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-CN-SHORT_SLOW` | 492.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-CN-LONG_MODERATE` | 476.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-CN-SHORT_TURBO` | 502.750 | 500 | 7 | 4/5 | `0x2b` |

### JP

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-JP-LONG_TURBO` | 923.250 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-JP-LONG_FAST` | 923.375 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-JP-LONG_SLOW` | 920.8125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-JP-MEDIUM_FAST` | 920.625 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-JP-MEDIUM_SLOW` | 921.375 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-JP-SHORT_FAST` | 922.375 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-JP-SHORT_SLOW` | 923.125 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-JP-LONG_MODERATE` | 922.1875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-JP-SHORT_TURBO` | 923.250 | 500 | 7 | 4/5 | `0x2b` |

### ANZ

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-ANZ-LONG_TURBO` | 921.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-ANZ-LONG_FAST` | 919.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-ANZ-LONG_SLOW` | 918.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-ANZ-MEDIUM_FAST` | 926.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-ANZ-MEDIUM_SLOW` | 927.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-ANZ-SHORT_FAST` | 918.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-ANZ-SHORT_SLOW` | 920.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-ANZ-LONG_MODERATE` | 915.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-ANZ-SHORT_TURBO` | 926.750 | 500 | 7 | 4/5 | `0x2b` |
| `meshcore-ANZ-DEFAULT` | 915.800 | 250 | 10 | 4/5 | `0x12` |
| `meshcore-ANZ-NARROW` | 916.575 | 62.5 | 7 | 4/7 | `0x12` |
| `meshcore-ANZ-MID` | 915.075 | 125 | 9 | 4/5 | `0x12` |
| `meshcore-ANZ-SA_WA` | 923.125 | 62.5 | 8 | 4/8 | `0x12` |
| `meshcore-ANZ-NZ_NARROW` | 917.375 | 62.5 | 7 | 4/5 | `0x12` |
| `meshcore-ANZ-NZ_GISBORNE` | 917.375 | 250 | 11 | 4/5 | `0x12` |
| `meshcore-ANZ-QLD` (not hopped) | 923.125 | 62.5 | 8 | 4/5 | `0x12` |

### ANZ_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-ANZ_433-LONG_TURBO` | 434.300 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-ANZ_433-LONG_FAST` | 434.425 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-ANZ_433-LONG_SLOW` | 434.6125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-ANZ_433-MEDIUM_FAST` | 434.425 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-ANZ_433-MEDIUM_SLOW` | 434.425 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-ANZ_433-SHORT_FAST` | 433.425 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-ANZ_433-SHORT_SLOW` | 433.425 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-ANZ_433-LONG_MODERATE` | 433.7375 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-ANZ_433-SHORT_TURBO` | 434.300 | 500 | 7 | 4/5 | `0x2b` |

### RU

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-RU-LONG_TURBO` | 868.950 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-RU-LONG_FAST` | 869.075 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-RU-LONG_SLOW` | 869.0125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-RU-MEDIUM_FAST` | 868.825 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-RU-MEDIUM_SLOW` | 869.075 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-RU-SHORT_FAST` | 869.075 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-RU-SHORT_SLOW` | 868.825 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-RU-LONG_MODERATE` | 868.8875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-RU-SHORT_TURBO` | 868.950 | 500 | 7 | 4/5 | `0x2b` |

### KR

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-KR-LONG_TURBO` | 922.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-KR-LONG_FAST` | 922.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-KR-LONG_SLOW` | 920.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-KR-MEDIUM_FAST` | 920.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-KR-MEDIUM_SLOW` | 920.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-KR-SHORT_FAST` | 921.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-KR-SHORT_SLOW` | 922.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-KR-LONG_MODERATE` | 921.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-KR-SHORT_TURBO` | 922.750 | 500 | 7 | 4/5 | `0x2b` |

### TW

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-TW-LONG_TURBO` | 920.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-TW-LONG_FAST` | 923.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-TW-LONG_SLOW` | 923.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-TW-MEDIUM_FAST` | 922.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-TW-MEDIUM_SLOW` | 924.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-TW-SHORT_FAST` | 924.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-TW-SHORT_SLOW` | 922.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-TW-LONG_MODERATE` | 921.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-TW-SHORT_TURBO` | 922.750 | 500 | 7 | 4/5 | `0x2b` |

### IN

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-IN-LONG_TURBO` | 865.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-IN-LONG_FAST` | 865.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-IN-LONG_SLOW` | 866.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-IN-MEDIUM_FAST` | 866.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-IN-MEDIUM_SLOW` | 865.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-IN-SHORT_FAST` | 865.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-IN-SHORT_SLOW` | 865.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-IN-LONG_MODERATE` | 865.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-IN-SHORT_TURBO` | 865.750 | 500 | 7 | 4/5 | `0x2b` |

### NZ_865

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-NZ_865-LONG_TURBO` | 864.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-NZ_865-LONG_FAST` | 864.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-NZ_865-LONG_SLOW` | 867.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-NZ_865-MEDIUM_FAST` | 865.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-NZ_865-MEDIUM_SLOW` | 866.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-NZ_865-SHORT_FAST` | 864.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-NZ_865-SHORT_SLOW` | 866.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-NZ_865-LONG_MODERATE` | 866.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-NZ_865-SHORT_TURBO` | 864.750 | 500 | 7 | 4/5 | `0x2b` |

### TH

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-TH-LONG_TURBO` | 920.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-TH-LONG_FAST` | 923.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-TH-LONG_SLOW` | 923.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-TH-MEDIUM_FAST` | 922.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-TH-MEDIUM_SLOW` | 924.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-TH-SHORT_FAST` | 924.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-TH-SHORT_SLOW` | 922.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-TH-LONG_MODERATE` | 921.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-TH-SHORT_TURBO` | 922.750 | 500 | 7 | 4/5 | `0x2b` |

### UA_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-UA_433-LONG_TURBO` | 434.250 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-UA_433-LONG_FAST` | 434.375 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-UA_433-LONG_SLOW` | 434.5625 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-UA_433-MEDIUM_FAST` | 434.375 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-UA_433-MEDIUM_SLOW` | 434.375 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-UA_433-SHORT_FAST` | 433.375 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-UA_433-SHORT_SLOW` | 433.375 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-UA_433-LONG_MODERATE` | 433.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-UA_433-SHORT_TURBO` | 434.250 | 500 | 7 | 4/5 | `0x2b` |

### MY_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-MY_433-LONG_TURBO` | 433.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-MY_433-LONG_FAST` | 433.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-MY_433-LONG_SLOW` | 434.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-MY_433-MEDIUM_FAST` | 434.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-MY_433-MEDIUM_SLOW` | 433.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-MY_433-SHORT_FAST` | 433.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-MY_433-SHORT_SLOW` | 433.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-MY_433-LONG_MODERATE` | 433.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-MY_433-SHORT_TURBO` | 433.750 | 500 | 7 | 4/5 | `0x2b` |

### MY_919

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-MY_919-LONG_TURBO` | 919.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-MY_919-LONG_FAST` | 922.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-MY_919-LONG_SLOW` | 922.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-MY_919-MEDIUM_FAST` | 921.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-MY_919-MEDIUM_SLOW` | 923.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-MY_919-SHORT_FAST` | 923.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-MY_919-SHORT_SLOW` | 921.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-MY_919-LONG_MODERATE` | 920.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-MY_919-SHORT_TURBO` | 921.750 | 500 | 7 | 4/5 | `0x2b` |

### SG_923

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-SG_923-LONG_TURBO` | 917.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-SG_923-LONG_FAST` | 917.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-SG_923-LONG_SLOW` | 924.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-SG_923-MEDIUM_FAST` | 922.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-SG_923-MEDIUM_SLOW` | 919.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-SG_923-SHORT_FAST` | 917.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-SG_923-SHORT_SLOW` | 923.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-SG_923-LONG_MODERATE` | 923.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-SG_923-SHORT_TURBO` | 917.750 | 500 | 7 | 4/5 | `0x2b` |

### PH_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-PH_433-LONG_TURBO` | 434.250 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_433-LONG_FAST` | 434.375 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-PH_433-LONG_SLOW` | 434.5625 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-PH_433-MEDIUM_FAST` | 434.375 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-PH_433-MEDIUM_SLOW` | 434.375 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-PH_433-SHORT_FAST` | 433.375 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-PH_433-SHORT_SLOW` | 433.375 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-PH_433-LONG_MODERATE` | 433.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_433-SHORT_TURBO` | 434.250 | 500 | 7 | 4/5 | `0x2b` |

### PH_868

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-PH_868-LONG_TURBO` | 869.250 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_868-LONG_FAST` | 869.375 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-PH_868-LONG_SLOW` | 869.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-PH_868-MEDIUM_FAST` | 868.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-PH_868-MEDIUM_SLOW` | 868.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-PH_868-SHORT_FAST` | 868.375 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-PH_868-SHORT_SLOW` | 869.125 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-PH_868-LONG_MODERATE` | 868.5625 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_868-SHORT_TURBO` | 869.250 | 500 | 7 | 4/5 | `0x2b` |

### PH_915

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-PH_915-LONG_TURBO` | 917.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_915-LONG_FAST` | 917.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-PH_915-LONG_SLOW` | 915.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-PH_915-MEDIUM_FAST` | 915.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-PH_915-MEDIUM_SLOW` | 915.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-PH_915-SHORT_FAST` | 916.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-PH_915-SHORT_SLOW` | 917.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-PH_915-LONG_MODERATE` | 916.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-PH_915-SHORT_TURBO` | 917.750 | 500 | 7 | 4/5 | `0x2b` |

### KZ_433

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-KZ_433-LONG_TURBO` | 434.325 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-KZ_433-LONG_FAST` | 434.450 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-KZ_433-LONG_SLOW` | 434.6375 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-KZ_433-MEDIUM_FAST` | 434.450 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-KZ_433-MEDIUM_SLOW` | 434.450 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-KZ_433-SHORT_FAST` | 433.450 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-KZ_433-SHORT_SLOW` | 433.450 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-KZ_433-LONG_MODERATE` | 433.7625 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-KZ_433-SHORT_TURBO` | 434.325 | 500 | 7 | 4/5 | `0x2b` |

### KZ_863

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-KZ_863-LONG_TURBO` | 863.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-KZ_863-LONG_FAST` | 866.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-KZ_863-LONG_SLOW` | 866.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-KZ_863-MEDIUM_FAST` | 865.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-KZ_863-MEDIUM_SLOW` | 867.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-KZ_863-SHORT_FAST` | 867.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-KZ_863-SHORT_SLOW` | 865.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-KZ_863-LONG_MODERATE` | 864.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-KZ_863-SHORT_TURBO` | 865.750 | 500 | 7 | 4/5 | `0x2b` |

### NP_865

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-NP_865-LONG_TURBO` | 867.750 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-NP_865-LONG_FAST` | 867.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-NP_865-LONG_SLOW` | 865.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-NP_865-MEDIUM_FAST` | 865.125 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-NP_865-MEDIUM_SLOW` | 865.875 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-NP_865-SHORT_FAST` | 866.875 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-NP_865-SHORT_SLOW` | 867.625 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-NP_865-LONG_MODERATE` | 866.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-NP_865-SHORT_TURBO` | 867.750 | 500 | 7 | 4/5 | `0x2b` |

### BR_902

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-BR_902-LONG_TURBO` | 906.250 | 500 | 11 | 4/8 | `0x2b` |
| `meshtastic-BR_902-LONG_FAST` | 903.875 | 250 | 11 | 4/5 | `0x2b` |
| `meshtastic-BR_902-LONG_SLOW` | 903.3125 | 125 | 12 | 4/8 | `0x2b` |
| `meshtastic-BR_902-MEDIUM_FAST` | 906.625 | 250 | 9 | 4/5 | `0x2b` |
| `meshtastic-BR_902-MEDIUM_SLOW` | 907.375 | 250 | 10 | 4/5 | `0x2b` |
| `meshtastic-BR_902-SHORT_FAST` | 904.375 | 250 | 7 | 4/5 | `0x2b` |
| `meshtastic-BR_902-SHORT_SLOW` | 905.125 | 250 | 8 | 4/5 | `0x2b` |
| `meshtastic-BR_902-LONG_MODERATE` | 906.6875 | 125 | 11 | 4/8 | `0x2b` |
| `meshtastic-BR_902-SHORT_TURBO` | 905.750 | 500 | 7 | 4/5 | `0x2b` |
| `meshcore-BR_902-DEFAULT` | 923.125 | 62.5 | 8 | 4/8 | `0x12` |

### LORA_24

| Channel | Frequency (MHz) | Bandwidth (kHz) | SF | CR | Sync |
|---|---|---|---|---|---|
| `meshtastic-LORA_24-LONG_TURBO` | 2423.5625 | 1625 | 11 | 4/8 | `0x2b` |
| `meshtastic-LORA_24-LONG_FAST` | 2420.71875 | 812.5 | 11 | 4/5 | `0x2b` |
| `meshtastic-LORA_24-LONG_SLOW` | 2443.26562 | 406.25 | 12 | 4/8 | `0x2b` |
| `meshtastic-LORA_24-MEDIUM_FAST` | 2446.71875 | 812.5 | 9 | 4/5 | `0x2b` |
| `meshtastic-LORA_24-MEDIUM_SLOW` | 2428.84375 | 812.5 | 10 | 4/5 | `0x2b` |
| `meshtastic-LORA_24-SHORT_FAST` | 2408.53125 | 812.5 | 7 | 4/5 | `0x2b` |
| `meshtastic-LORA_24-SHORT_SLOW` | 2474.34375 | 812.5 | 8 | 4/5 | `0x2b` |
| `meshtastic-LORA_24-LONG_MODERATE` | 2442.04688 | 406.25 | 11 | 4/8 | `0x2b` |
| `meshtastic-LORA_24-SHORT_TURBO` | 2447.9375 | 1625 | 7 | 4/5 | `0x2b` |

These regions have no Meshtastic or MeshCore presets, and can not currently be used: `EU_866`, `EU_N_868`, `ITU1_2M`, `ITU2_2M`, `ITU3_2M`, `ITU2_125CM`, `ITU1_70CM`, `ITU2_70CM`, `ITU3_70CM`.
