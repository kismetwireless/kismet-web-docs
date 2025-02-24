---
title: "Kismetdb to device JSON"
description: ""
lead: ""
date: 2022-10-06T22:12:21-04:00
lastmod: 2022-10-06T22:12:21-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb_device_json-c99c861fec8b11a7ade72bde88e02296"
weight: 30
toc: true
---

The `kismetdb_dump_devices` tool processes the unified [kismetdb](/docs/readme/logging/kismetdb/) log and exports the device records as JSON for use with other tools.

This tool is available as part of Kismet when built from source, or in the kismet-logtools package, as of `2019-02`.

```bash
kismetdb_dump_devices --in some-kismet-file.kismet --out some-json-file.json
```

## Streaming via `stdout`

Like many other command line tools, specifying `-` as the output file will cause `kismetdb_dump_devices` to stream the output to the console, making it simple to pipe it to other tools:

```bash
kismetdb_dump_devices --in some-kismetdb.kismet --out - | python -mjson.tool
```

## Arguments

{{<argumentshort i in filename>}}
Path to the kismetdb file to process
{{</argumentshort>}}

{{<argumentshort o out filename>}}
Path to the pcap or pcapng file that will be written
{{</argumentshort>}}

{{<argumentshort s skip-clean>}}
By default, `kismetdb_strip_packets` runs a SQL Vacuum command to optimize the database and clean up any journal files.  Skipping this process will save time on larger captures.
{{</argumentshort>}}

{{<argument json>}}
Output as a JSON file; useful when using the `kismetdb_statistics` tool to populate an index of log files or similar.
{{</argument>}}

{{<argument verbose>}}
Add status output to the console.
{{</argument>}}

{{<argumentshort f force>}}
Force overwriting any existing files, by default `kismetdb_to_pcap` will refuse to erase existing output files.
{{</argumentshort>}}

{{<argument json-path>}}
Reformat field names to be compatible with JSON path searching and ELK by rewriting all `.` to `_`; For example, `kismet.base.key` becomes `kismet_base_key`.

This is turned on automatically when ELK mode is enabled.
{{</argument>}}

{{<argument ekjson>}}
Export as an `ekjson` format; Instead of exporting a JSON array of the devices, instead export each device as an object on a single line.

While not technically valid JSON, this format can be used to stream processing or inserting into other tools (such as ELK), and can be processed line-by-line with far fewer resources than a single array of all options.

This will automatically enable JSON path mode.
{{</argument>}}
