---
title: "PCAP"
description: ""
lead: ""
date: 2022-08-24T16:05:05-04:00
lastmod: 2022-08-24T16:05:05-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "pcap-e5320013c0567a6de791ded9a3ee86d0"
weight: 30
toc: true
---

PCAP (and PCAP-NG) are standard formats for recording packets, which most tools which manipulate packets accept, including Tcpdump and Wireshark.  

A kismetdb log can be converted to PCAP-NG, or Kismet can write the packet logs directly.

There are two main flavors of PCAP supported by Kismet:

1. `pcapppi`

    `pcapppi` is the legacy PCAP format, which uses PPI packet headers.  This version of the pcap log can only handle Wi-Fi packets, and manipulates the packet headers to fit the PPI standard (only one antenna signal value and other limitations).  Generally the `pcapng` format should be used, but not all tools understand the new format.

2. `pcapng`

    `pcapng` is the modern pcap standard supported by Wireshark, Tshark, and other tools.

    PCAP-NG allows for mixing packet types (such as Wi-Fi, BTLE, and Zigbee) as well as retaining the original capture interface (which datasource in Kismet saw the packet), the original headers (pure radiotap packet headers with more complete signal info, timestamps, etc).  It also allows Kismet to log the packet without manipulation (such as header translation to PPI), allows for annotations, other data, and more.

    Whenever possible, the PCAP-NG log file will have richer content.

## When to enable PCAP 

Typically there is no need to enable both the `kismet` log type and the PCAP log types at the same time, since the PCAP log can be created using the `kismetdb_to_pcap` tool which is part of Kismet.

### Log type

```
log_types=pcapppi
```

and

```
log_types=pcapng
```


## Filtering

### Duplicate packets

Kismet can record duplicate packets when multiple datasources capture the same data.  In some instances, keeping duplicate packets is desirable (such as remote captures used for device location), while in others, logging duplicates may be a waste of space.

```
pcapng_log_duplicate_packets=false
```

and

```
ppi_log_duplicate_packets=false
```

### Data packets

Kismet typically logs all types of packets.  To discard data packets, retaining only management frames:

```
pcapng_log_data_packets=false
```

and

```
ppi_log_data_packets=false
```

