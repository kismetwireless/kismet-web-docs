---
title: "Kismetdb to PCAP"
description: ""
lead: ""
date: 2022-10-02T08:44:38-04:00
lastmod: 2022-10-02T08:44:38-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb_to_pcap-672c989ebe039cdd16244b5def3c89dc"
weight: 20
toc: true
---

The `kismetdb_to_pcap` tool converts the unified [kismetdb](/docs/readme/logging/kismetdb/) log to standard PCAP format logs for use with any tool that processes PCAP logs - [Wireshark](https://www.wireshark.org), [tcpdump](https://tcpdump.org), or any number of other processing tools.

The more modern PCAP-NG format allows for mixing different types of data (for instance, Wi-Fi and Bluetooth) into one logfile, and preserves which capture source it was received on, but isn't well supported by all tools (Wireshark and tshark offer excellent support, however).

`kismetdb_to_pcap` can convert to PCAP, PCAP-NG, split packets based on type, datasource, generate multiple smaller log files, and more.

## Converting to PCAP-NG

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcapng
```

This converts the log to a standard pcapng file.  This file contains the most information and is most useful in tools like Wireshark.

If you have only one type of data - for instance, Wi-Fi packets captured from a single interface - this file will be usable with any tool which uses libpcap (such as aircrack, tcpdump, and almost all other tools); otherwise it will be necessary to export individual original-format PCAP files for each capture type for legacy tools.

## Converting to legacy PCAP

`kismetdb_to_pcap` can log to legacy PCAP files as well:

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcap --old-pcap
```

Legacy PCAP files are limited to one DLT, or data link type; the link type is the type of packet, for instance raw 802.11, radiotap signal headers, Bluetooth, and so on.

Legacy PCAP files have no concept of interfaces or data sources, so if you have multiple datasources in Kismet, all the packets will be available, but it will be impossible to see what source originally captured each packet, unless you split by datasource (more on this in the next section).

If your kismetdb log has more than one link type, you can specify which one will be included in the legacy pcap using the `--dlt` option:

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcap --old-pcap --dlt 127
```

To see what linktypes are included in your kismetdb log, use the `--list-datasources` option (see the next section for more).

## Listing and selecting datasources

`kismetdb_to_pcap` will list the datasources and what link types each has captured:

```bash
$ kismetdb_to_pcap --in some-kismet-log.kismet --list-datasources
* Found KismetDB version 6
* Collecting info about datasources...
Datasource #0 (5FE308BD-0000-0000-0000-00C0CAA6846C xenon-mt2 wlx00c0caa6846c) 766980 packets
   DLT 127: IEEE802_11_RADIO 802.11 plus radiotap header
Datasource #1 (5FE308BD-0000-0000-0000-00C0CAA68473 xenon-mt1 wlx00c0caa68473) 704950 packets
   DLT 127: IEEE802_11_RADIO 802.11 plus radiotap header
Datasource #2 (5FE308BD-0000-0000-0000-00C0CAA68471 xenon-mt0 wlx00c0caa68471) 3656794 packets
   DLT 127: IEEE802_11_RADIO 802.11 plus radiotap header
Datasource #3 (689C0913-0000-0000-0000-0000865F0805 rtladsb-0 rtladsb-0) 0 packets
   No packets seen by this datasource
Datasource #4 (5FE308BD-0000-0000-0000-9CEFD5FDD05C xenon-rt28 wlx9cefd5fdd05c) 0 packets
   No packets seen by this datasource
```

Each datasource has a unique identifier, or UUID.  Because multiple datasources could have the same interface (for example when using remote capture), datasources must be referred to by UUID.

Logs can be extracted for one or more datasources:

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcap --old-pcap --datasource 5FE308BD-0000-0000-0000-00C0CAA6846C --datasource 5FE308BD-0000-0000-0000-00C0CAA68473
```

will generate a legacy PCAP log with only the first and second interfaces.


## Splitting logs

If you have multiple datasources and want to generate a log file for each, or extremely large log files and want to split the logs by packet count or by log size, `kismetdb_to_pcap` can do that, as well:

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcap --old-pcap --split-datasources
```

will make a pcap for each datasource named `some-kismet-log.kismet-[uuid]`.

The `--split-packets [#]` and `--split-size [kb]` options allow splitting packets by count or by total packet size in Kb:

```bash
kismetdb_to_pcap --in some-kismet-log.kismet --out some-pcap-log.pcap --old-pcap --split-packets 10000
```

will make a pcap every 10000 packets, named `some-pcap-log.pcap-[XXXXXX]`.

The `--split-datasources` option can be combined with the `--split-packets` or the `--split-size` options.

## Parameters

{{<argumentshort i in filename>}}
Path to the kismetdb file to process
{{</argumentshort>}}

{{<argumentshort o out filename>}}
Path to the pcap or pcapng file that will be written
{{</argumentshort>}}

{{<argumentshort s skip-clean>}}
`kismetdb_to_pcap` automatically optimizes and cleans the kismetdb file when opening it, repairing any partial journal files and reducing the overall size.  If this has already been done, or you don't want to alter the logfile, you can skip cleaning up the log.
{{</argumentshort>}}

{{<argumentshort f force>}}
Force overwriting any existing files, by default `kismetdb_to_pcap` will refuse to erase existing output files.
{{</argumentshort>}}

{{<argumentshort v verbose>}}
Verbose output and progress
{{</argumentshort>}}

{{<argument old-pcap>}}
`kismetdb_to_pcap` generates PCAP-NG files by default.  The PCAP-NG format is more flexible and contains more of the original information, but may not be readable by all tools.

This will force generating original PCAP format files.  PCAP will support only one link type per file.
{{</argument>}}

{{<argument dlt "linktype#">}}
Limit dumping packets of a single link type; required when generating legacy PCAP files instead of PCAP-NG.

Available linktypes are shown in the `--list-datasources` output.
{{</argument>}}

{{<argument list-datasources>}}
List datasources and link types in the capture file.
{{</argument>}}

{{<argument datasource uuid>}}
Includes packets from this datasource.

Multiple datasource arguments can be provided to include multiple sources in a single output file.
{{</argument>}}

{{<argument split-datasource>}}
Split the output into multiple files, by the datasource which captured the packet.
{{</argument>}}

{{<argument split-packets num>}}
Split the output into multiple files, with each file containing at most {num} packets.
{{</argument>}}

{{<argument split-size size-in-kb>}}
Split the output into multiple files, with each file containing at most {kb} bytes.
{{</argument>}}

