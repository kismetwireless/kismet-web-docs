---
title: "GPS - GPSD"
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

[GPSD](https://gpsd.gitlab.io/gpsd/index.html) is a service which parses GPS data from a wide range of GPS vendors, including several binary protocols which normal NMEA parsers cannot decode. 

Modern GPSD is a solid option for controlling most GPS receivers.

Extremely old distributions or versions of GPSD (prior to 2015 or so) may have various issues.  Kismet still supports the now-ancient GPSD text protocol, but will default to the modern JSON protocol.

After 2026-10-R1, Kismet checks each field gpsd sends: a field out of range or of the wrong type is dropped instead of used, a report with an invalid fix mode is dropped whole, and a 3D fix without a usable altitude counts as 2D.  The altitude is the height above mean sea level: `altMSL` when gpsd sends it (gpsd 3.20 and newer), then the older `alt`, then `altHAE` corrected by `geoidSep`.

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

Port number for GPSD.  Typically this will be `2947`
{{</configopt>}}

