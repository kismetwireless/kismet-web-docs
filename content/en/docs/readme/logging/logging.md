---
title: "Logging Basics"
description: ""
lead: ""
date: 2022-08-23T23:15:10-04:00
lastmod: 2022-08-23T23:15:10-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "logging-77528a8d9a5aa7a6ac2ff71b0f8ec4da"
weight: 10
toc: true
---

Kismet supports logging to multiple log formats simultaneously:

| Log | Description |
| -------- | ----------- |
| kismet   | The Kismet log is the new, unified style of logging.  Based on sqlite3, it is a database file containing packets, non-packet data, messages, location information, device records, client records, and more.  It can be converted to other formats with the `kismetdb_to_xyz` tools included in Kismet, or parsed with any language which understands sqlite3 and JSON for scripted handling of Kismet results. |
| pcapng | PCAP-NG is the new PCAP packet capture format supported by Wireshark, Tshark, and other tools.  PCAP-NG logs contain the complete original packet and original radio headers, capture device information, and can merge multiple capture types into a single log. |
| pcapppi | PCAP-PPI is a legacy PCAP packet capture file, with PPI packet headers.  Packets must be translated to the PPi header format, which will not contain the full original information.  PCAP-PPI should only be used for legacy packet processors which cannot be updated to use PCAP-NG. |
| wiglecsv | The wiglecsv log is meant for direct uploading to the [Wigle](https://wigle.net) project, a community wardriving and data collection site. |

## Picking a log format

Kismet can log to multiple logs simultaneously, configured in the `kismet_logging.conf` config file (or in the `kismet_site.conf` override configuration).  Logs are configured by the `log_types=` config option, and multiple types can be specified:

```
log_types=kismet,pcapng
```

Different log formats can be useful in different situations.  The `kismet` log is a unified single log for all Kismet related data - everything shown in the UI is available in the `kismet` log, and all packets and other data records are available.  Some features require the `kismet` log to process historical packets.

For extremely high-density logging, the `pcapng` log may offer better performance.  `pcapng` logs can be processed by Wireshark and other popular tools, and are written as a stream instead of random access; for high-volume logging or rotating logs, it may make sense to use the `pcapng` log instead of the `kismet` log - or to combine them, by turning off packet logging in the `kismet` log.

## Log names and locations

Log naming and location is configured in `kismet_logging.conf` (or `kismet_site.conf` for overrides).  Logging can be disabled entirely with:

```
logging_enabled=false
```

or it can be disabled at launch time by launching Kismet with `-n`:

```bash
$ kismet -n ...
```


The default log title is 'Kismet'.  This can be changed using the `log_title=` option:

```
log_title=SomeCustomName
```

or it can be changed at launch time by running Kismet with `-t ...`:

```bash
$ kismet -t SomeCustomeName ...
```

Kismet stores logs in the directory it is launched from.  This can be changed using the `log_prefix=` option; this is most useful when launching Kismet as a service from systemd or similar when the directory it is being launched from may not be where you want to store logs:

```
log_prefix=/tmp/kismet
```

## Log name templates

The template used to create the logfile names can be changed in the Kismet configs using the `log_template` option.

By default, Kismet will log files as:
```text
{prefix}/{title}-{YYYYMMDD}-{HH-MM-SS}-{#}.{type}
```

using the template
```
log_template=%p/%n-%D-%t-%i.%l
```


Templates are defined with `%` codes:

| Code | Value |
| ---- | ----- |
| %p | Logging prefix |
| %n | Logging title (such as the `-t` option on the command line) |
| %d | Log date as `Mmm-DD-YYYY` |
| %D | Log date as `YYYYMMDD` |
| %t | Log time as `HH-MM-SS` |
| %T | Log time as `HHMMSS` |
| %i | Log number, if multiple logs of the same name are found |
| %I | Multi-part log number padded with zeroes |
| %l | Log type (kismet, pcapng, etc) |
| %h | Home directory |




