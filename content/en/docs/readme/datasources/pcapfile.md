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

