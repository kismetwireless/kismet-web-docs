---
title: "Pcap-NG Ringbuffer"
description: ""
lead: ""
date: 2026-06-10T22:11:03-0400
lastmod: 2026-06-10T22:11:09-0400
images: []
menu:
  docs:
    parent: ""
    identifier: "pcapngringbuffer"
weight: 45
toc: true
---

`Added 2026-06`

In some cases, it may be useful to maintain a size-limited rotating PCAP-NG
log collection.  Kismet supports these via the ringbuffer log system.

## How it works

The PCAP-NG ringbuffer logs write continuous packets to a memory-backed
collection of logfiles stored in tmpfs.  When an event of interest occurs, the
logs can be snapshotted to permanent disk storage using the [snapshot
API](/docs/api/packet_capture/#packets-from-temporary-ring-buffer).

## When to use it

The PCAP-NG ringbuffer system is most useful for long-running sensors where
capturing all packets is unfeasible or undesirable.  The ringbuffer snapshot
allows triggering captures around events without losing packets.

## Log type

```
log_types=pcap_ring
```

## Configuring

PCAP-NG ringbuffer captures can be controlled via the options in `kismet_logging.conf`;
using `kismet_site.conf` is preferred.

### Location of ringbuffers

The ringbuffers should be located in a RAM-based directory.  On most systems this
is `/tmp` or `/run`.  Placing the backing files on a traditional disk negates
the performance benefits and may cause excessive writing to flash-backed
storage.

```
pcapng_ring_dir=/run/kismet/ring
```

### Ring slot size

The ring logs are divided into slots.  When the active slot reaches the maximum
size, it is rotated to the next slot.  Total RAM used by the ringbuffer logs is
approximately `pcapng_ring_file_size_mb * pcapng_ring_file_count`

```
pcapng_ring_file_size_mb=8
```

### Number of ring slots

The number of ringbuffer positions.  By default, 8 slots are retained of 8MB
each, providing a 64MB rolling window of recent traffic.

```
pcapng_ring_file_count=8
```

### Persist directory

When the ringbuffer is snapshotted, permanent PCAP-NG files are made in the
snapshot directory.  Kismet will create this directory if it is missing.

```
pcapng_ring_persist_dir=/var/lib/kismet/captures
```

### Trigger time window

The snapshot API captures the existing ringbuffer for context and continues to
copy new packets for a specified number of seconds.  By default, 30 seconds of
packets are captured.

```
pcapng_ring_default_post_seconds=30
```

### Total persistent snapshot cap

The PCAP-NG ringbuffer is primarily designed for very long running Kismet
sensors where snapshot events could consume excessive storage.  This sets a hard
limit on the total size of all snapshots.  If exceeded, snapshots are removed,
oldest first.

```
pcapng_ring_persist_max_total_mb=2048
```

### Persistent capture time cap

The PCAP-NG ringbuffer is primarily designed for very long running Kismet
sensors.  This sets a limit on the age of snapshots; snapshots older than this
many days are automatically removed.

```
pcapng_ring_persist_max_age_days=14
```

### Minimum disk space available

The PCAP-NG ringbuffer is primarily designed for very long running Kismet
sensors where snapshot events could consume excessive storage.  This sets a
minimum free space (in MB) that must be free on the persistent storage disk.

```
pcapng_ring_persist_min_free_mb=256
```

### Pruning timer

This controls how often the retention system scans for outdated files.  Smaller
values keep the backlog of expired snapshots smaller, but may take more CPU.

```
pcapng_ring_persist_prune_interval=60
```

## Filtering

By default, the PCAP-NG ringbuffer logs inherit the duplicate and data packet
filter settings from the PCAP-NG logfile.  To override and set custom duplicate
and data logging for PCAP-NG ringbuffer logs, use the following.

```
pcapng_ring_log_duplicate_packets=true
pcapng_ring_truncate_duplicate_packets=false
pcapng_ring_log_data_packets=true
```

