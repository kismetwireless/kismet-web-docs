---
title: "Wiglecsv"
description: ""
lead: ""
date: 2022-08-24T20:03:08-04:00
lastmod: 2022-08-24T20:03:08-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "wiglecsv-7c369bce9c4baf95050e8c7a9bd0a2d4"
weight: 40
toc: true
aliases:
    - /docs/readme/wigle/
---

[Wigle](https://wigle.net) is a community for wardriving and mapping WiFi networks.

Kismet log files (kismetdb) can be converted to the Wigle CSV format, but Kismet can also directly log to the Wigle format with the `wiglecsv` log.

Wigle does not collect packet contents, so a `wiglecsv` log does not contain packets - it is a simplified CSV text file of WiFi Access Points and Bluetooth devices, and their locations.  If you want to save packet contents, be sure to also turn on `kismet` or `pcapng` logs!

Since Wigle is designed for mapping wireless, Kismet will only create entries in the `wiglecsv` log when a GPS is connected and a location is available.  If you have no GPS location, the `wiglecsv` will be empty.

## Log type

```
log_types=wiglecsv
```

Kismet will automatically create a wiglecsv file while running.  This can be combined with other log types like `kismet` and `pcapng`, but does not need to be.  *Remember* you can't recover packet data from a `wiglecsv` log, so if you want to process the packets later, be sure to log another format too!

## Converting kismetdb to wiglecsv

The `kismetdb` log can be converted to Wigle format using the `kismetdb_to_wiglecsv` tool included as part of Kismet or in the `kismet-logtools` package.

The simplest way to convert a kismetdb log to a wiglecsv is to simply run the conversion tool:

```
kismetdb_to_wiglecsv --in some-kismet-log-file.kismet --out some-wigle-file.csv
```

## Conversion options

Converting a kismetdb log can take a lot of space and time, because each packet is examined and the coordinates written to the CSV file.  This can be sped up with various options to the `kismetdb_to_wiglecsv` tool:

{{<argument verbose>}}
Add more status output to the console while running, useful for long files that take a significant amount of time to process.
{{</argument>}}


{{<argument skip-clean>}}
By default, `kismetdb_to_wiglecsv` performs a database cleanup and optimization stage (optimizing existing data, cleaning up stray journal files, etc).  If you are running multiple passes on a file, or have already cleaned it using `kismetdb_clean`, you can save time by skipping this stage.
{{</argument>}}


{{<argument rate-limit limit-in-seconds>}}
By default, `kismetdb_to_wiglecsv` will only emit one record per second per access point.  This prevents overloading the Wigle servers with insane quantities of data with no useful positional updates.  If you find you are generating extremely large data sets, you can increase this time.
{{</argument>}}


{{<argument cache-limit number-of-devices>}}
`kismetdb_to_wiglecsv` will cache device information from the database to speed up looking up SSIDs and other device data.  By default, the last 1000 devices are cached, but if you have a very large number of devices, or a very small amount of ram, increasing or decreasing this cache may speed up processing.
{{</argument>}}

## Uploading to Wigle

Once your log is converted, you can upload it to [Wigle](https://www.wigle.net) by creating an account there and choosing the file from your computer.
