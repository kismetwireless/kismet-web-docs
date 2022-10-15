---
title: "GPS - Virtual"
description: ""
lead: ""
date: 2022-09-15T15:41:03-04:00
lastmod: 2022-09-15T15:41:03-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_virtual-c85dc85d8ba9dce50d63ae5e05fe3c13"
weight: 90
toc: true
---

A virtual GPS always reports a single, fixed, static location.

The virtual GPS can be helpful for injecting location data on a stationary Kismet server.

## Configuration 

```
gps=virtual:lat={xyz},lon={xyz},alt={xyz}
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

### Virtual options 

{{<configopt lat latitude>}}
*REQUIRED*

Latitude to report, as decimal degrees 
{{</configopt>}}


{{<configopt lon longitude>}}
*REQUIRED*

Longitude to report, as decimal degrees
{{</configopt>}}


{{<configopt alt altitude>}}
Altitude to report, in meters
{{</configopt>}}

