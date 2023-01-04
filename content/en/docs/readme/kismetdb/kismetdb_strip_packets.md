---
title: "Kismetdb packet stripping"
description: ""
lead: ""
date: 2022-10-10T15:17:49-04:00
lastmod: 2022-10-10T15:17:49-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb_strip_packets-131c6669cb25adffc02a441fc835d102"
weight: 50
toc: true
---

The `kismetdb_strip_packets` tool processes the unified [kismetdb](/docs/readme/logging/kismetdb/) log and deletes the stored packets.

This tool is available as part of Kismet when built from source, or in the kismet-logtools package, as of `2019-02`.

## Packet data

Kismet stores packets as binary data in the [kismetdb log file](/docs/readme/logging/logging/).

Packet data is invaluable for analyzing results, replaying data, capturing handshakes, and more; It can also be large, take a lot of room, and contain personally identifiable or private information gathered during a capture. 

Before sharing a packet log (for instance with sites which may accept kismetdb logs directly), the packet data can be stripped.

The `kismetdb_strip_packets` tool will retain all metadata - MAC addresses, signal, and location - but will erase the contents of the packets.

```bash
$ kismetdb_strip_packets --in some-kismet-file.kismet --out some-other-file.kismet
```

## Arguments

{{<argument verbose>}}
Add more status output to the console while `kismetdb_strip_packets` runs.
{{</argument>}}

{{<argument force>}}
By default, `kismetdb_strip_packets` will not overwrite the target file if it exists already.  `--force` will cause it to clobber the destination.
{{</argument>}}

{{<argument skip-clean>}}
By default, `kismetdb_strip_packets` runs a SQL Vacuum command to optimize the database and clean up any journal files.  Skipping this process will save time on larger captures.
{{</argument>}}

