---
title: "GPS - TCP"
description: ""
lead: ""
date: 2022-09-15T15:10:49-04:00
lastmod: 2022-09-15T15:10:49-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_tcp-b76cdf9dd27d2ff2af38df0e3293fcd1"
weight: 70
toc: true
---

Kismet can connect to a basic NMEA GPS replicated over a TCP stream.

Typically this would come from a smartphone app like `BlueNMEA` on Android or `NMEA GPS` on iPhone.

For a network-based GPSd connection, use the `gpsd` GPS instead.

## Configuration

```
gps=tcp:host={host},port={port}
```

## GPS options

### Common options

{{<configopt name name>}}
Set an arbitrary human-readable name for the GPS.  This will be used in the Kismet GPS logs.
{{</configopt>}}


{{<configopt reconnect true false>}}
Automatically attempt to re-open the GPS if an error occurs or the connection is interrupted.

This is enabled by default.
{{</configopt>}}

### TCP options

{{<configopt host hostname>}}
*REQUIRED*

Hostname of the system running a GPS TCP stream service.
{{</configopt>}}


{{<configopt port port>}}
*REQUIRED*

Port on which the NMEA stream is running
{{</configopt>}}
