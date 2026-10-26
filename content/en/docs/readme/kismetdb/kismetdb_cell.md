---
title: "Kismetdb cell logs"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb_cell-a838879bf757354b4a973bf747b33d64"
weight: 60
toc: true
---

Added: `2026-10`

The [cell AT](/docs/readme/datasources/cell-at/) and [cell DIAG](/docs/readme/datasources/cell-diag/) sources write their detailed logs only into the [kismetdb](/docs/readme/logging/kismetdb/) log: the raw AT exchanges, the session records, the decoded observations, and the raw DIAG stream.  None of this is shown on the Kismet console or written to other files.  The `kismetdb_to_*` cell tools extract it.

The kismetdb log must be enabled, with `kis_log_data_packets=true` (the default) for the `data` table records and `kis_log_packets=true` (the default) for the raw DIAG stream.

## Record types

Records in the kismetdb `data` table, by `type`:

| Type | Source | Contents |
|------|--------|----------|
| `Cellular` | both | a decoded cell observation which Kismet matched to a cell device |
| `CellModem` | both | a decoded observation Kismet could not key to a cell, such as a neighbor report with a channel but no PCI |
| `RawAT` | AT | every AT command and its full response, one record per exchange |
| `ClockAnchor` | both | the modem clock read and paired with the host clock |
| `CellLog` | both | one session record per capture (the port, the modem make, model, firmware and IMEI, and the options), and with `debug` on, extra detail such as each DIAG configuration request and its reply |
| `CellSecurity` | DIAG | a security finding; see the [cell alerts](/docs/readme/datasources/cell-diag/#alerts) |
| `DiagCrcCensus` | DIAG | a count of the DIAG frames which failed their checksum, at the end of a capture |
| `RawDiagDrop` | DIAG | the first raw DIAG stream data dropped because Kismet was too busy |
| `RawDiagAbort` | DIAG | written by the server when a DIAG source fails in the middle of its stream |

Read both `Cellular` and `CellModem` to get every observation.

The raw DIAG stream is in the `packets` table, with link type 147.

## kismetdb_to_cellndjson

Extracts the decoded observations (`Cellular` and `CellModem`), plus the `RawAT` and `ClockAnchor` records, as NDJSON: one JSON record per line, with the host timestamp, the location, the record type, and the source.

```bash
$ kismetdb_to_cellndjson --in drive.kismet --out drive-cell.ndjson
```

| Option | |
|--------|---|
| `-i`, `--in` | the kismetdb file |
| `-o`, `--out` | the output file, or `-` for stdout |
| `-f`, `--force` | overwrite an existing output file |
| `-v`, `--verbose` | verbose output |

## kismetdb_to_atlog

Extracts the `RawAT` records of the AT sources as JSON lines, one per AT exchange, in capture order:

```json
{"ts_mono_ns": 402931118273, "ts_utc": "2026-10-01T16:51:03.412887Z",
 "cmd": "AT+QENG=\"servingcell\"", "response": "+QENG: ...\r\n\r\nOK\r\n",
 "duration_ms": 38.75, "err": null}
```

`ts_mono_ns` is the host monotonic clock, and orders the records; `ts_utc` is the host wall clock.

```bash
$ kismetdb_to_atlog --in drive.kismet --out - --source <uuid>
```

| Option | |
|--------|---|
| `-i`, `--in` | the kismetdb file |
| `-o`, `--out` | the output file, or `-` for stdout |
| `-s`, `--source` | only this datasource, by UUID or name |
| `-f`, `--force` | overwrite an existing output file |
| `-v`, `--verbose` | verbose output |

## kismetdb_to_celllog

Reads the `CellLog` session and debug records, merged with the source's `RawAT` exchanges into one transcript per datasource, in capture order.  The output is text by default, or JSON lines with `--json`.

```bash
$ kismetdb_to_celllog --in drive.kismet --out -
$ kismetdb_to_celllog --in drive.kismet --out - --sessions
$ kismetdb_to_celllog --in drive.kismet --out drive-log.jsonl --json
```

| Option | |
|--------|---|
| `-i`, `--in` | the kismetdb file |
| `-o`, `--out` | the output file, or `-` for stdout |
| `-s`, `--source` | only this datasource, by UUID or name |
| `-j`, `--json` | write JSON lines instead of text |
| `-n`, `--no-rawat` | leave out the `RawAT` exchanges |
| `-S`, `--sessions` | only the session records |
| `-f`, `--force` | overwrite an existing output file |
| `-v`, `--verbose` | verbose output |

## kismetdb_to_hdlc

Rebuilds the raw DIAG stream of a DIAG source from the `packets` table, as a raw HDLC capture file.  The file can be decoded again with the DIAG source's `replay=` option, or by other Qualcomm DIAG tools.

Each stream is one modem and one session; a source which reopens starts a new session.

```bash
$ kismetdb_to_hdlc --in drive.kismet --list
$ kismetdb_to_hdlc --in drive.kismet --out drive.hdlc
$ kismetdb_to_hdlc --in drive.kismet --out-dir hdlc/
$ kismet -c celldiag-000000000000000:replay=/full/path/to/drive.hdlc
```

The tool reports gaps, overlaps, damaged data, and data the source reported dropping.  A stream with no end marker is reported as possibly missing its end; a stream whose source failed in the middle is reported as a warning.

| Option | |
|--------|---|
| `-i`, `--in` | the kismetdb file |
| `-o`, `--out` | the output `.hdlc` file, or `-` for stdout; needs exactly one stream |
| `-O`, `--out-dir` | write one `.hdlc` per stream into this directory, named by the source name and session start time |
| `-l`, `--list` | list the streams, with their size, gaps, end marker, and drops |
| `-s`, `--source` | only this datasource |
| `-S`, `--session` | only this session (from `--list`) |
| `-t`, `--type` | the datasource type to read (default `celldiag`) |
| `-d`, `--dlt` | the packet link type to read (default 147) |
| `--strict` | write nothing and exit with status 3 on any gap, overlap, damaged data, or reported drop |
| `--require-end` | with `--strict`, also fail a stream which has no end marker |
| `-f`, `--force` | overwrite existing output files |
| `-v`, `--verbose` | verbose output |

The exit status is 0 on success, 1 on an error, 2 when the log has no DIAG packets (such as a capture with `rawpackets=off`), and 3 on a `--strict` failure.
