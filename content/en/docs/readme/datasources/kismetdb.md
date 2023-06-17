---
title: "Replay: Kismetdb"
description: ""
lead: ""
date: 2023-06-17T12:29:21-04:00
lastmod: 2023-06-17T12:29:21-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb-56ba4d9cb60613c227d40fe6aa482a2a"
weight: 999
toc: true
---

Kismet can replay previously recorded data in a kismetdb log.

Kismet replay is useful for testing, debugging, demo, or reprocessing previous sessions (with some caveats).

### Example source

Typically a kismetdb replay would be done as a command line option rather than a hard coded source:

```bash
$ kismet -c /path/to/file.kismet
```
### Warnings

Not all data in a kismetdb log is currently replayed: Non-packet data such as JSON records is not loaded.

When replaying a kismetdb log, all packets will appear to originate from a single datasource (the kisemtdb source), not the orignial interfaces.

When processing logfiles, it is easy to send packets faster than the Kismet server can process.  It's always a good idea to use the `pps` source option to limit the packets per second.

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Kismetdb options

{{<configopt pps "rate">}}
Limit the replay to a packets-per-second maximum.  Without this option, packets are streamed to Kismet as fast as possible, which may outrun the processing queue on the Kismet server.  Kismetdb replays should always be throttled to a rate your server hardware can support to prevent lose packets during the replay; often 1000 to 10000 packets per second is a reasonable starting point.
{{</configopt>}}

{{<configopt realtime true false>}}
Replay a kismetdb log in real time, using the time offsets between packets in the original log.
{{</configopt>}}

