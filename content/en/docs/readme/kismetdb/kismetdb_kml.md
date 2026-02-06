---
title: "Kismetdb to KML"
description: ""
lead: ""
date: 2022-10-10T14:58:53-04:00
lastmod: 2022-10-10T14:58:53-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "kismetdb_kml-bfab5368eaa9336056656ed0c6196529"
weight: 40
toc: true
---

The `kismetdb_to_kml` tool processes the unified [kismetdb](/docs/readme/logging/kismetdb/) log and exports the positional data as a basic KML.

This tool is available as part of Kismet when built from source, or in the kismet-logtools package, as of `2019-02`.

```bash
kismetdb_to_kml --in some-kismet-file.kismet --out some-file.kml
```

## KML

KML is an XML-based markup language for use with Google Earth, or other utilities designed to process the Google Earth formats. 

The output KML from `kismetdb_to_kml` is quite basic; for more complex needs, we suggest either editing the `kismetdb_to_kml` source to extend it (patches welcome!) or creating a custom processor to meet your needs.

## Arguments

{{<argumentshort i in filename>}}
Path to the kismetdb file to process
{{</argumentshort>}}

{{<argumentshort o out filename>}}
Path to the KML file that will be written
{{</argumentshort>}}

{{<argumentshort s skip-clean>}}
By default, `kismetdb_to_kml` runs a SQL Vacuum command to optimize the database and clean up any journal files.  Skipping this process will save time on larger captures.
{{</argumentshort>}}

{{<argument verbose>}}
Add status output to the console.
{{</argument>}}

{{<argumentshort f force>}}
Force overwriting any existing files, by default `kismetdb_to_kml` will refuse to erase existing output files.
{{</argumentshort>}}

{{<argument basic-location>}}
By default, `kismetdb_to_kml` computes a final average across all the packets seen; this can be more precise than the running average Kismet computes.  

If packets were not logged, or to save time and processing, passing `--basic-location` will use the average location stored in the device record instead.
{{</argument>}}

{{<argumentshort e exclude>}}
Exclude records within `dist` *meters* of the location provided.  

This can be used to exclude packets close to your home, or other sensitive locations.
{{</argumentshort>}}
