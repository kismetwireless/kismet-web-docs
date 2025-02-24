---
title: "GPS - GPSd"
description: ""
lead: ""
date: 2022-09-15T14:45:27-04:00
lastmod: 2022-09-15T14:45:27-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_gpsd-29ba7e51391f912fea79f516e8da1457"
weight: 40
toc: true
---

[GPSd](https://gpsd.gitlab.io/gpsd/index.html) is a service which parses GPS data from a wide range of GPS vendors, including several binary protocols which normal NMEA parsers cannot decode.

Modern GPSd is a solid option for controlling most GPS receivers.

Extremely old distributions or versions of GPSd (prior to 2015 or so) may have various issues. Kismet still supports the now-ancient GPSd text protocol, but will default to the modern JSON protocol.

## Configuration

```
gps=gpsd:host=localhost,port=2947
```

To determine the proper path to your GPS unit, look below in the `device` options.

## GPS options

### Common options

{{<configopt name name>}}
Set an arbitrary human-readable name for the GPS.  This will be used in the Kismet GPS logs.
{{</configopt>}}

{{<configopt reconnect true false>}}
Automatically attempt to re-open the GPS if an error occurs or the connection is interrupted.

This is enabled by default.
{{</configopt>}}

### GPSD options

{{<configopt host "hostname-for-gpsd">}}
*REQUIRED*

Hostname to connect to; typically this will be `localhost`
{{</configopt>}}


{{<configopt port port>}}
*REQUIRED*

Port number for GPSd.  Typically this will be `2947`
{{</configopt>}}
