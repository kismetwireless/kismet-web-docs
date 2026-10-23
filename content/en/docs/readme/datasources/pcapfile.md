---
title: "Replay: Pcapfile"
description: ""
lead: ""
date: 2023-06-17T12:29:12-04:00
lastmod: 2023-06-17T12:29:12-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "pcapfile-da13abe07ac4439c5848f6c85af24b98"
weight: 999
toc: true
---

Kismet can replay previously recorded data in `pcap` and `pcap-ng` formats, including capture files with the `ppi` headers.

Kismet replay is useful for testing, debugging, demo, or reprocessing previous sessions (with some caveats).

### Example source

Typically a pcap replay would be done as a command line option rather than a hard coded source:

```bash
$ kismet -c /path/to/file.pcap
```

### Supported formats

Kismet supports any format loadable by libpcap, primarily `pcap` and `pcap-ng` formats.

When using a `pcap-ng` file, due to how the packets are processed and loaded by libpcap, Kismet will only support `pcap-ng` logs of a single phy type (ie only Wi-Fi, or only Zigbee, but not mixed).  Additionally, all packets will appear to come from a single data source (the pcapfile source), not the original interfaces.

### SDR receiver captures

Some protocols have no capture hardware in Kismet, but an SDR receiver can demodulate them and write the packets as a pcap file or a FIFO, which the pcapfile source reads.  Since Kismet 2026-10-R1 two such formats are decoded:

| Link type | Header magic | Protocol | Devices |
| --------- | ------------ | -------- | ------- |
| 147 (`LINKTYPE_USER0`) | `ESB` | Nordic Enhanced ShockBurst | nRF24 wireless keyboards, mice and their receivers (Logitech Unifying, Microsoft and others) |
| 148 (`LINKTYPE_USER1`) | `ANT` | ANT and ANT+ | heart-rate straps, bike speed, cadence and power sensors, foot pods, fitness equipment |

Both start each packet with a 12-byte header, then the packet as it was sent:

| Octets | ESB | ANT |
| ------ | --- | --- |
| 0-2 | `'E' 'S' 'B'` | `'A' 'N' 'T'` |
| 3 | version, 1 | version, 1 |
| 4 | RF channel (MHz - 2400) | RF channel (MHz - 2400; ANT+ is 57, 2457 MHz) |
| 5 | flags: bit 0 2 Mbit/s, bit 1 CRC ok, bit 2 no ACK, bit 3 bits repaired | flags: bit 1 CRC ok, bit 3 bits repaired, bit 4 ANT+ network |
| 6 | PID | reserved |
| 7 | signal, dBm (signed) | signal, dBm (signed) |
| 8 | address length (3-5) | address length (2) |
| 9 | payload length (0-32) | payload length (8, 16 or 24) |
| 10-11 | reserved | reserved |
| then | address, payload, 2-byte CRC | network address, device number (2, least significant first), device type, transmission type, length, payload, 2-byte CRC |

Kismet relies on the receiver's "CRC ok" flag rather than checking the CRC itself.  Packets with the flag clear are counted as errors and make no device; packets without the header are ignored.  ANT packets whose length octet doesn't match their payload are ignored too, since they are usually another protocol's packet that passed the 16-bit CRC by chance.

The receiver used for these is `wifi-rx` from [80211_iq_demod](https://github.com/thex1le/80211_iq_demod), with `--esb-pcap PATH` or `--ant-pcap PATH`, for example:

```bash
$ kismet -c /tmp/ant.pcap:type=pcapfile,name=ant24
```

nRF24 devices get their kind (Logitech mouse, keyboard, keyboard and mouse, Microsoft device), the receiver a Logitech device is paired with, and counts of mouse, encrypted and unencrypted keystroke reports; a keyboard that sends unencrypted keystrokes raises the [NRFPLAINTEXTKEYS](/docs/readme/alerts/alerts/) alert.  ANT devices are named for their ANT+ device profile, with the heart rate, manufacturer, model, serial number, software version and battery status from their ANT+ data pages.

### Warnings

When processing pcap logfiles, it is easy to send packets faster than the Kismet server can process.  It's always a good idea to use the `pps` source option to limit the packets per second.

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Pcapfile options

{{<configopt pps "rate">}}
Limit the replay to a packets-per-second maximum.  Without this option, pcapfiles are streamed to Kismet as fast as possible, which may outrun the processing queue on the Kismet server.  Pcapfile replays should always be throttled to a rate your server hardware can support to prevent lost packets during the replay; often 1000 to 10000 packets per second is a reasonable starting point.
{{</configopt>}}

{{<configopt realtime true false>}}
Replay a pcapfile in real time, using the time offsets between packets in the original log.
{{</configopt>}}

