---
title: "Cell: Qualcomm DIAG"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "cell-diag-04c39596d3dcdb0223e3b8be13561298"
weight: 401
toc: true
---

Added: `2026-10`

The cell DIAG source (`celldiag`) reads the Qualcomm diagnostic (DIAG) port of a cellular modem.  It sets the modem's diagnostic log mask, reads the stream of log records the modem produces, and decodes them inside the capture tool into cell observations for the `Cellular` phy, the same devices the [cell AT source](/docs/readme/datasources/cell-at/) creates.

From the DIAG stream, Kismet gets:

* Every LTE and NR serving and neighbor cell measurement the modem makes (LTE ML1 serving, idle and connected neighbor, and per-cell measurements; NR ML1).
* The LTE RRC messages the modem receives, including each cell's SIB1.  The identity in a SIB1 (MCC, MNC, TAC, and cell ID) is added to later measurements of that cell, so cells the AT commands only report by PCI and channel get their full identity.
* NR RRC, and the serving cell bandwidth and number of antennas.
* The modem's GNSS position reports.
* The security signalling, which raises the [cell security alerts](#alerts).

For how this compares to the AT source, and running both on one modem, see [AT and DIAG](/docs/readme/datasources/cell-at/#at-and-diag).

## Supported hardware

The DIAG source needs a Qualcomm-based modem which exposes its DIAG port:

* **Quectel RM520N-GL** series (SDX62), over USB or PCIe.  This is the reference modem for the DIAG source.
* **Quectel RM500Q** series (SDX55).
* **Quectel EG25-G / EC2x / EG2x** (MDM9607).  These need an [SPC unlock](#spc-unlock) before the modem accepts a log mask.
* **Telit LM960** (SDX24).

The supported modem models for the AT source are listed on the [cell AT](/docs/readme/datasources/cell-at/#supported-hardware) page.  A modem without a DIAG port, or one from a vendor which doesn't use Qualcomm chipsets, can only use the AT source.

## Adding the source

Like the AT source, the DIAG source is named by the modem IMEI:

```bash
$ kismet -c celldiag-<imei>
```

The source type is `celldiag`.  To find the modem, the source sends `AT+CGSN` to the modem's AT ports and matches the IMEI, then opens the DIAG port of the same USB device.  To list the modems:

```bash
$ kismet_cap_cell_diag --list
```

If the DIAG port can't be found, name it with `diagport=`; if the AT port can't be found, name it with `atport=`, which skips the scan.  A PCIe modem uses `/dev/mhi_DIAG` and `/dev/mhi_DUN` on Linux; with more than one PCIe modem, name both ports:

```
source=celldiag-<imei>:atport=/dev/mhi_DUN,diagport=/dev/mhi_DIAG
```

The `CELLDIAG_SCAN_PORTS` environment variable replaces the set of ports scanned for the AT port, as a space-separated list of paths or globs.

On macOS, supported Quectel modems are reached over libusb; see [cell modems over libusb](/docs/readme/datasources/cell-usb/).

### Linux permissions

The capture tool needs read and write access to the modem's DIAG and AT ports; see the [cell AT permissions](/docs/readme/datasources/cell-at/#linux-permissions).

### One DIAG client at a time

The DIAG source claims the DIAG port exclusively while it runs.  Other DIAG tools can't use the port at the same time, and the DIAG source can't open a port another program holds.

## What the source changes on the modem

To get the log records, the DIAG source sends the modem a log mask when it opens.  The mask is held in the modem's RAM; when the source closes, it clears the mask it set, so the modem doesn't keep streaming to the next DIAG client.  `nomask=true` reads whatever an earlier tool enabled, and sets and clears nothing.

### SPC unlock

The EG25-G, EC2x, and EG2x (MDM9607) refuse a log mask until they are unlocked with the service programming code (SPC).  Without it, the open fails with `DIAG LOG_CONFIG handshake failed on <port> (wrong port, or SPC-gated?)`.  Pass the code, which is `000000` by factory default:

```
source=celldiag-<imei>:spc=000000
```

The RM500Q, RM520N-GL, and LM960 don't need it.  The code is never written to the logs.

### Masks

The `mask=wardrive` default subscribes to the cell log records Kismet decodes, at low volume: LTE ML1 serving cell, neighbor, and per-cell measurement records (`0xB193`, `0xB192`, `0xB195`, `0xB17F`), LTE serving cell configuration (`0xB197`), LTE RRC (`0xB0C0`), NR RRC (`0xB821`), NR ML1 (`0xB97F`), and GNSS (`0x1476`, `0x14D8`).  Only the records the modem advertises are requested.

`mask=full` subscribes to every log record the modem advertises.  This is a very high volume and is intended for diagnosing a modem, not for normal capture.

`nas=true` adds the LTE NAS (EMM) messages needed for the NAS security alerts.  These messages carry the SIM's own IMSI and GUTI into the raw stream, so they are off by default; `mask=full` includes them.

### F3 and QSH debug messages

`f3=all`, `f3=high`, or `f3=error` turns on the modem's F3 debug messages, and `qsh=on` turns on the QSH trace.  Both are high volume and only for debugging the modem.  Kismet doesn't decode them; they are kept in the raw DIAG stream in the kismetdb.  The QSH trace setting survives a reboot of the modem, so the source turns it off again when it closes.

## Alerts

The decoder watches the RRC and NAS signalling for the patterns a cell-site simulator ("IMSI catcher") shows, following the heuristics of the EFF [Rayhunter](https://github.com/EFForg/rayhunter) project.  Each match is logged as a `CellSecurity` record in the kismetdb, and raises a Kismet alert naming the cell:

| Alert | Severity | Raised when | Needs |
|-------|----------|-------------|-------|
| `CELLNULLCIPHER` | high | an RRC or NAS security mode command selects the null cipher (EEA0) | RRC: the default mask; NAS: `nas=true` |
| `CELLNULLINTEGRITY` | high | an RRC or NAS security mode command selects null integrity (EIA0) | as above |
| `CELL2GREDIRECT` | high | an RRC connection release redirects the modem to a 2G (GERAN) carrier | the default mask |
| `CELLINCOMPLETESIB` | low | a SIB1 schedules fewer than two system information messages (once per cell per capture) | the default mask |
| `CELLIDREQUEST` | high | the network requests the modem's identity after authentication, or after a disconnect with no new connection | `nas=true` |
| `CELLIDREQNOAUTH` | low | an identity request followed by a disconnect or attach reject without authentication | `nas=true` |

Some of these happen on normal networks:

* A network without VoLTE redirects to 2G for a voice call (circuit switched fallback), which also raises `CELL2GREDIRECT`.
* `CELLIDREQNOAUTH` is often a roaming or inactive SIM.
* A redirect to a carrier other than 2G is logged as a `CellSecurity` record but raises no alert.

`CELLINCOMPLETESIB` only needs the SIB1 each cell broadcasts; the other alerts come from the signalling when the modem connects to the network.

The alerts are configured like any other Kismet alert; see [alerts](/docs/readme/alerts/alerts/).

## Live SIBs in Wireshark

With `gsmtap=on`, each LTE RRC and LTE NAS message is also sent as a GSMTAP UDP packet to `127.0.0.1` port `4729`, for Wireshark to decode as it is received:

```bash
$ wireshark -k -i lo -f "udp port 4729"
$ kismet -c celldiag-<imei>:gsmtap=on
```

`gsmtap=<ipv4>` or `gsmtap=<ipv4>:<port>` sends it elsewhere; only IPv4 addresses and `localhost` are accepted.  NR RRC isn't sent, because GSMTAP has no type for it.  Sending never blocks the capture; failures are counted and reported when the source closes.

## Logging

The source logs the decoded observations, a session record for each capture, the security records, and the raw DIAG stream into the [kismetdb](/docs/readme/logging/kismetdb/); nothing is written to separate files.

The raw DIAG stream is logged by default as packets with link type 147 (`LINKTYPE_USER0`), so a capture can be decoded again later; `kismetdb_to_hdlc` extracts it.  `rawpackets=off` leaves it out, and `kis_log_packets=false` in `kismet_logging.conf` leaves out all packets.

The raw stream holds everything the modem logs under the selected mask, which can include identifiers from the modem's own signalling; treat the kismetdb from a DIAG capture as sensitive.

See [kismetdb cell logs](/docs/readme/kismetdb/kismetdb_cell/) for the record types and the tools to extract them.

## Status

The source reports its state in the datasource details in the web UI and on the message bus every `stats_interval` seconds: whether data is arriving from the port, the number of observations, and how many records were decoded.

A busy stream can lose bytes between the modem and Kismet; the only sign of it is DIAG frames which fail their checksum.  When 10 or more frames fail in one status interval, the source raises an error message and sets a warning on the source.

## DIAG source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Port options

{{<configopt diagport "/path/to/tty" "usb:bus-addr:if">}}
The DIAG port, instead of finding it from the modem's AT port.
{{</configopt>}}

{{<configopt atport "/path/to/tty" "usb:bus-addr:if">}}
The AT port used to identify the modem, instead of scanning for it.
{{</configopt>}}

{{<configopt usb auto force off>}}
How modems with no host serial driver are reached over [libusb](/docs/readme/datasources/cell-usb/); the same as the [AT source option](/docs/readme/datasources/cell-at/#port-options).
{{</configopt>}}

### Modem options

{{<configopt spc 000000>}}
Send this six digit SPC to unlock the modem before setting the log mask.  Needed on the EG25-G, EC2x, and EG2x.
{{</configopt>}}

{{<configopt mask wardrive full>}}
The log records to request.  `wardrive` (the default) requests the cell records Kismet decodes; `full` requests every record the modem advertises, at a very high volume.
{{</configopt>}}

{{<configopt nas true false>}}
Also request the LTE NAS messages, for the NAS security alerts.  These include the SIM's IMSI and GUTI.  Off by default.
{{</configopt>}}

{{<configopt nomask true false>}}
Don't set or clear a log mask; read whatever the modem is already sending.
{{</configopt>}}

{{<configopt f3 off all high error>}}
Turn on the modem's F3 debug messages, at every severity (`all`), or without the lowest severities (`high`, `error`).  They are kept in the raw stream, not decoded.  Off by default.
{{</configopt>}}

{{<configopt qsh on off>}}
Turn on the modem's QSH trace, for debugging captures.  It is turned off again when the source closes.  Off by default.
{{</configopt>}}

{{<configopt profiles "/path/to/profiles">}}
A directory of modem profiles (`capture_cell_at/profiles/` in the Kismet source), which supply per-modem defaults for `mask=`, `f3=`, and `spc=`, matched on the modem firmware.  An option set on the source always wins.  Profiles are not used by default; `CELLDIAG_PROFILES` in the environment sets the directory for every source.
{{</configopt>}}

### Output options

{{<configopt rawpackets on off>}}
Log the raw DIAG stream into the kismetdb.  On by default.
{{</configopt>}}

{{<configopt gsmtap off on "ipv4:port">}}
Send LTE RRC and NAS messages as GSMTAP UDP packets, to `127.0.0.1:4729` or the given address.  Off by default.
{{</configopt>}}

### Other options

{{<configopt enabled true false>}}
With `enabled=false`, the source is defined but idle: the DIAG port isn't opened.
{{</configopt>}}

{{<configopt replay "/path/to/capture.hdlc">}}
Decode a saved raw DIAG capture, such as one extracted with `kismetdb_to_hdlc`, instead of a live modem; use the full path to the file.  No modem is opened and no mask is sent.
{{</configopt>}}

{{<configopt stats_interval seconds>}}
Seconds between status reports; default 30, `0` turns them off.
{{</configopt>}}

{{<configopt clock_anchor_sec seconds>}}
How often the modem clock is read and paired with the host clock in the log, in seconds.  The default is 30; `0` reads it only at the start and end of the capture.
{{</configopt>}}

{{<configopt debug true false>}}
Verbose messages, and every configuration request sent to the modem and its reply in the session log.  On by default; `debug=false`, or `KISMET_CELLDIAG_DEBUG=0` in the environment, turns it off.
{{</configopt>}}

None of the DIAG source options can be changed while the source runs; close the source and open it again with a new definition.
