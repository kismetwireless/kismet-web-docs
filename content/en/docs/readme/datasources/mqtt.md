---
title: "MQTT"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "mqtt-b71f9b4028704928befd9449b64c4db4"
weight: 750
toc: true
---

Added: `2023-08`

The MQTT source subscribes to a topic on an MQTT broker, and imports the JSON messages published to it as if they had been captured by a Kismet datasource.

This allows Kismet to use data from tools which publish to MQTT, such as `rtl_433`, without running the tool under Kismet.

MQTT sources are named `mqtt`, and must include the `host`, `topic`, and `mapping` options:

```bash
kismet -c 'mqtt:host=broker.local,topic=rtl_433/+/events,mapping=RTL433,name=rtl433mqtt'
```

## Compiling MQTT support

MQTT support requires libmosquitto, and is enabled by default.  If libmosquitto is not available, MQTT support can be disabled by passing `--disable-mosquitto` to `./configure`.

## Kismet MQTT support

The MQTT source runs inside the Kismet server, rather than as a separate capture tool, and can not be used as a remote capture.

Every message received on the topic becomes a packet in Kismet, time-stamped as it arrives and tagged with the current GPS location.  The `mapping` option tells Kismet what kind of data the messages contain, and which part of Kismet decodes them:

| Mapping | Data |
|---|---|
| `RTL433` | `rtl_433` JSON; sensors become devices, as with the [rtl_433](/docs/readme/datasources/sensor-sdrrtl433/) source, and meter records are handled as meters |
| `RTLamr` | `rtlamr` JSON, as with the [rtlamr](/docs/readme/datasources/meter-sdrrtlamr/) source |
| `adsb` or `RTLadsb` | ADS-B, either raw hex messages in an `adsb` or `adsb_raw_msg` field, or `rtl_adsb` style JSON |
| `antsdr-droneid` | DJI DroneID records, as with the [AntSDR DroneID](/docs/readme/datasources/drone-antsdr-droneid/) source |
| `radview` | Radview radiation records |
| `radiacode` | Radiacode radiation records |

The mapping is case-sensitive.

Topic wildcards (`+` and `#`) are supported, and every message received is processed.

Data imported over MQTT is logged in the [kismetdb](/docs/readme/logging/kismetdb/) log `data` table.  It is not logged in pcapng, as there are no packets to log.

If the connection to the broker is lost, Kismet raises an alert and the connection is re-established automatically.

## MQTT source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

MQTT sources do not have a stable UUID unless one is set with the `uuid` option; set one if the source should keep the same identity across restarts.

### Connection options

{{<configopt host "hostname or address">}}
The MQTT broker to connect to.  This option is required.
{{</configopt>}}

{{<configopt port "port">}}
The broker port; by default `1883`.
{{</configopt>}}

{{<configopt topic "topic">}}
The topic to subscribe to.  Wildcards are allowed.  This option is required.
{{</configopt>}}

{{<configopt mapping "mapping">}}
The type of data published to the topic; see the table above.  This option is required.
{{</configopt>}}

{{<configopt identity "client id">}}
The MQTT client ID; by default `kismet-` followed by the source UUID.
{{</configopt>}}

### Authentication and TLS options

{{<configopt user "username">}}
The username to log in to the broker with.  A `password` must also be given, and logins are only allowed over TLS.
{{</configopt>}}

{{<configopt password "password">}}
The password to log in to the broker with.
{{</configopt>}}

{{<configopt tls true false>}}
Connect to the broker with TLS.  By default TLS is off, unless one of the TLS file options is set.  If no CA is given, the system certificates in `/etc/ssl/certs` are used.
{{</configopt>}}

{{<configopt tls_ca_file "/path/to/ca.pem">}}
A CA certificate file used to verify the broker.
{{</configopt>}}

{{<configopt tls_ca_dir "/path/to/ca/dir">}}
A directory of CA certificates used to verify the broker.
{{</configopt>}}

{{<configopt tls_certfile "/path/to/cert.pem">}}
A client certificate, for brokers which require certificate authentication.
{{</configopt>}}

{{<configopt tls_keyfile "/path/to/key.pem">}}
The key for the client certificate.  Requires `tls_certfile`.
{{</configopt>}}

{{<configopt tls_keyfile_pw "password">}}
The password for an encrypted client key.
{{</configopt>}}

### Location options

{{<configopt metagps "name">}}
Attach a named [meta GPS](/docs/readme/datasources/datasources/#attaching-a-meta-gps) to the source.
{{</configopt>}}

### Debugging options

{{<configopt debug true false>}}
Show libmosquitto log messages as Kismet debug messages.
{{</configopt>}}
