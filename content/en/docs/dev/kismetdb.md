---
title: "KismetDB logs"
description: ""
lead: ""
date: 2022-11-11T14:03:21-05:00
lastmod: 2022-11-11T14:03:21-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb-4682b6542aa26ec1a0dc7a046d93af2b"
weight: 999
toc: true
---

## Kismet Log File

The Kismet log file contains all the information gathered by Kismet about devices, supported phy types, packets, GPS coordinates during logging, and similar.  Under previous versions of Kismet, this data could be found in disparate logs such as gpsxml, netxml, nettxt, and pcap.

## Internal Log Structure

The Kismet log file is stored as a SQLite3 database, however it is not designed as a traditional strictly normalized database.

In order to support the arbitrary data collected by Kismet about different phy layers and any  Kismet plugins that may have been loaded, the Kismet log contains basic normalized fields such as location, timestamp, and device keys, but the majority of the data is stored as a serialized JSON object or as binary packet data.

This means that basic queries (time, signal levels, location, device identifiers, and MAC addresses) can be done via SQL queries, but more complex queries will require retrieving the JSON object.

## Log Versions

The log file version is stored in the `db_version` field of the `KISMET` table.  When changes to the base database structure are made, this version will be incremented.

### Version 9

As of February 2025, Kismet has started using db_version 9.  This version adds:
1. `packet_full_len` to the `packets` table.  This contains the original length of the packet.  This is the same as the `caplen` value reported by libpcap, and will be greater than the original packet length when the capture size is limited.

### Version 8

As of October 2021, Kismet has started using db_version 8.  This version adds:
1. `hash` to the `packets` table.  This contains the CRC32 hash of the payload of the packet, not including the capture-specific radio headers.  This is equivalent to the pcapng packet hash.
2. `packetid` to the `packets` table.  This contains the packet id of the packet, which is unique to all packets of the same hash.  This is equivalent to the pcapng packet id option.

### Version 7

As of April 2021, Kismet has started using db_version 7.  This version contains one change:

1. The `packets` table now contains the field `datarate`, a real number.  This is the data rate as seen by Kismet, in mbit/sec.

### Version 6

As of May 2019, Kismet has started using db_version 6.  This version contains one change:

1. the `packets` table now has an additional field, `tags`.  This is a space-separated list of arbitrary packet tags.  These can be used to identify packets tagged by parts of the Kismet code, for instance, WPA handshake packets.

### Version 5

As of February 2019, Kismet has started using db_version 5.  This version contains two major changes:

1. Kismet no longer stores GPS coordinates as normalized integers.  GPS related data will be stored as SQL type `REAL`, an 8-byte double-precision float.
2. Kismet now adds per-packet GPS speed, altitude, and heading records.

### Version 4

Through Kismet 2018/2019 Beta 2, Kismet used db_version 4.  This version *did not* contain per-packet altitude, speed, or heading records, and *did* contain normalized GPS coordinates.

## Data Formats

The Kismet log uses a few consistent formats for data:

### Timestamps

Timestamps are stored as integer seconds since the epoch for low-precision timestamps, and integer seconds since the epoch plus a second field of milliseconds for high-precision timestamps.  This format matches the unix timestamp tv_sec and tv_usec format.

### GPS

*As of KismetDB version 5* the GPS coordinates are stored as 8-byte `REAL` double-precision floats; these are the native GPS coordinate, and no transformation is necessary.

*Prior to database version 5* the GPS coordinates were normalized to integers.

#### *This is deprecated for all logs created under version 5 or newer*.

Latitude and Longitude are normalized to a 6-digit precision integer using the conversion:
*normalized_coord = (coordinate * 100000)*

Coordinates can be automatically converted in SQL queries by using `/`:

```sql
SELECT (lat / 100000.0), (lon / 100000) FROM ...
```

Be sure to specify a floating-point divisor (100000.0), otherwise the result will be converted to an integer.

### GPS Bounding and Average Coordinates

GPS bounding coordinates are stored as 4 values, the minimum extreme latitude and longitude, and the maximum extreme latitude and longitude.  These values define a bounding box which encloses all instances where a device was seen.

The GPS average location is calculated by Kismet as a running average of all packets; this can be the least precise method of isolating the location of a device because it can be heavily influenced by the sampling pattern.  For more precise location calculations, post-processing of the GPS records in the `PACKET` or `DATA` tables will yield better results.

### Device Keys

Device keys are used to uniquely identify a device; the device key is used by Kismet as the indexing value for every device record, and incorporates the unique Kismet server which saw the device, the phy layer driver which processed the device, and the device-specific unique identifier (often the MAC address but not always).

Internally, keys are represented as 128-bit numbers; in the Kismet log they are represented as a TEXT field and each device key will be unique.

### UUIDs

UUIDs, or universally unique identifiers, are used in Kismet to identify specific instances of some long-living objects such as the Kismet server itself and data sources.  UUIDs are stored in the Kismet log as a TEXT blob of the UUID string.

## Log Sections

The Kismet log is divided into multiple sections (stored internally as SQLite3 tables).

### Alerts

The `alerts` section holds records of Kismet IDS alerts.

| Field   |          Type | Description                                            |
| ------- | ------------: | ------------------------------------------------------ |
| ts_sec  |   *timestamp* | Alert timestamp, as second-precision timestamp integer |
| ts_usec |   *timestamp* | Alert timestamp as usec-precision timestamp integer    |
| phyname |        *text* | Related phy name                                       |
| devmac  |        *text* | Primary related device MAC address                     |
| lat     | *real/double* | GPS latitude                    |
| lon     | *real/double* | GPS longitude                   |
| header  |        *text* | Alert header / type                                    |
| json    |        *json* | Full alert content as JSON object                      |

### Data

The `data` section holds arbitrary data records which are *not* packets but which have temporal or locational meaning; typically these will be generated by non-packet-based data sources such as the `sdr-rtl433` source which detects device events but does not supply the raw original bytes.

| Field      |          Type | Description                                            |
| ---------- | ------------: | ------------------------------------------------------ |
| ts_sec     |   *timestamp* | Event timestamp, as second-precision timestamp integer |
| ts_usec    |   *timestamp* | Event timestamp, as usec-precision timestamp integer   |
| phyname    |        *text* | Capturing device phy name                              |
| devmac     |        *text* | Captured device MAC, if any                            |
| lat        | *real/double* | GPS latitude                    |
| lon        | *real/double* | GPS longitude                   |
| alt        | *real/double* | GPS altitude, since database version 5 |
| speed      | *real/double* | GPS speed, since database version 5 |
| heading    | *real/double* | GPS heading, since database version 5 |
| datasource |        *uuid* | UUID of capturing datasource, as text                  |
| type       |        *text* | Type of data record, as text                           |
| json       |        *json* | Arbitrary JSON record of event                         |

### Datasource

The `datasource` section holds up-to-date information about the datasources Kismet is capturing from; a datasource supplies information to Kismet and can be local, remote, packet-based, or event-based.

| Field      | Type   | Description                                                  |
| ---------- | ------ | ------------------------------------------------------------ |
| uuid       | *uuid* | UUID of datasource                                           |
| typestring | *text* | Datasource type (such as `linuxwifi`)                        |
| definition | *text* | Full source definition as passed in the `source=` config or the `-c ...` command-line option |
| name       | *text* | Source name                                                  |
| interface  | *text* | Capture interface (such as `wlan0`)                          |
| json       | *json* | Full device state (packet RRD, messages, etc) as JSON blob   |

### Devices

The `device` section holds complete Kismet device objects; the device object is encoded as a JSON object and contains all phy-related data and all tracked notes, data, and any other information about the device.

| Field            |          Type | Description                                                  |
| ---------------- | ------------: | ------------------------------------------------------------ |
| first_time       |   *timestamp* | First time seen, as second-precision timestamp               |
| last_time        |   *timestamp* | Last time see, as second-precision timestamp                 |
| devkey           |        *text* | Unique device key                                            |
| phyname          |        *text* | Name of primary phy (such as IEEE80211)                      |
| devmac           |   *mac, text* | Device MAC (such as the source MAC address in IEEE80211)     |
| strongest_signal |     *integer* | Strongest recorded signal during lifetime of device, typically in dBm but phy-specific |
| min_lat          | *real/double* | GPS bounding rectangle, minimum latitude |
| min_lon          | *real/double* | GPS bounding rectangle, minimum longitude |
| max_lat          | *real/double* | GPS bounding rectangle, maximum latitude |
| max_lon          | *real/double* | GPS bounding rectangle, maximum longitude |
| avg_lat          | *real/double* | GPS running average latitude          |
| avg_lon          | *real/double* | GPS average running longitude        |
| bytes_data       |     *integer* | Number of bytes of data seen related to this device          |
| type             |        *text* | Phy-specific human-readable type, dependent on the phy       |
| device           |        *json* | Full JSON export of the device record and all enclosed fields |

### Messages

The `messages` section holds text messages from Kismet; typically printed to the 'Messages' section of the UI or to the console.

| Field   |          Type | Description                                               |
| ------- | ------------: | --------------------------------------------------------- |
| ts_sec  |   *timestamp* | Message time, as second-precision integer                 |
| lat     | *real/double* | GPS latitude                       |
| lon     | *real/double* | GPS longitude                     |
| alt        | *real/double* | GPS altitude, since database version 5 |
| speed      | *real/double* | GPS speed, since database version 5 |
| heading    | *real/double* | GPS heading, since database version 5 |
| msgtype |        *text* | Message type/category (`INFO`, `ERROR`, `ALERT`, `FATAL`) |
| message |        *text* | Arbitrary message as printed by Kismet                    |

### Packets

The `packets` section holds raw binary packets; packets can be of any DLT (data link type) supported by Kismet, and are tagged with per-packet GPS location (when available).

The `packets` section is directly analogous to a pcap (or pcap-ng) file and can be directly converted to those formats with tools found in `log_tools/` in the Kismet directory.

Packets are stored in the raw, original capture format; in the case of Wi-Fi this may be a format such as Radiotap which, itself, also encodes the frequency, signal levels, and detailed antenna data.  Kismet exposes a normalized subset of per-packet data to facilitate slicing the Kismet log into manageable pieces easily.

| Field      | Type          | Description |
| ---------- | ------------: | ------------------------------------------------------------                                                                                                    |
| ts_sec | *timestamp*   | Packet time, as second-precision integer |
| ts_usec    | *timestamp*   | Packet time, as usec-precision integer |
| phyname    | *text*        | Name of capturing phy                                                                                                                                           |
| sourcemac  | *text*        | MAC address of packet source (if available) |
| destmac    | *text*        | MAC address of packet destination (if available)                                                                                                                |
| transmac   | *text*        | MAC address of packet transmitter (if available) |
| frequency  | *real*        | Decimal frequency of packet, in KHz (if available)                                                                                                              |
| devkey     | *text*        | DEPRECATED.  This field is no longer used because packets are not a 1:1 relationship with devices, but the field is retained for schema compatibility. |
| lat        | *real/double* | GPS latitude  |
| lon        | *real/double* | GPS longitude |
| packet_len | *integer*     | Total packet length, in bytes |
| packet_full_len | *integer* | Original packet length (may be larger than available packet length), in bytes |
| signal     | *integer*     | Received signal level of packet (typically in DBm but may be phy-specific) |
| datasource | *uuid*        | UUID of capturing Kismet data source, as string                                                                                                                 |
| dlt        | *int*         | DLT (Data Link Type) of packet content; this correlates to the original packet format as understood by pcap (such as raw 802.11, radiotap, raw btle, and so on) |
| packet     | *blob*        | Raw binary packet content |
| error      | *int*         | Boolean, packet was flagged by Kismet as an error in rx or otherwise invalid due to parsing errors |
| tags       | *text*        | Arbitrary space-separated list of tags added by packet dissectors in Kismet                                                                                     |
| datarate   | *real*        | Datarate, in mbit/sec |
| hash       | int         | CRC32 hash of the packet contents (not including radio headers), equivalent to the pcap-ng hash record. |
| packetid   | *int*         | Unique packet ID, equivalent to the packet ID field in pcap-ng.  Can be used to correlate duplicate packets across multiple interfaces. |

### Snapshots

The `snapshots` section holds arbitrary time-based snapshots of data; this functions as a catch-all for Kismet plugins and other temporal data.

| Field    |          Type | Description                                |
| -------- | ------------: | ------------------------------------------ |
| ts_sec   |   *timestamp* | Snapshot time, as second-precision integer |
| ts_usec  |   *timestamp* | Snapshot time, as usec-precision integer   |
| lat      | *real/double* | GPS latitude        |
| lon      | *real/double* | GPS longitude       |
| snaptype |        *text* | Snapshot record type                       |
| json     |        *json* | Snapshot record, as JSON object            |

## REST API

If the Kismet Databaselog is enabled, Kismet will expose an API for extracting historic data.  If the databaselog is not enabled, these APIs will not be available and will return an error.

The `kismetdb` REST API [can be found here.](/docs/api/kismetdb/)
