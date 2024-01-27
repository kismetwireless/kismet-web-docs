---
title: "GPS"
description: ""
lead: ""
date: 2022-09-14T21:06:55-04:00
lastmod: 2022-09-14T21:06:55-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "gps_intro-c40e26be2ccf2ca9ed202f595ad59863"
weight: 10
toc: true
---

## GPS in Kismet

Kismet can integrate with a GPS device to provide geolocation coordinates for devices.

GPS data is included in the log files, in PPI pcap files, and exported over the REST interface.

Kismet can not use GPS to determine the absolute location of the device; it can only use it to determine the location of the receiver.

The location estimate of a device can be improved by circling the suspected location or mapping in a grid-like pattern.

Some datasources (such as ADSB) are able to self-source locational data; when absolute location information is available, Kismet will prefer that data.

Remote datasources can be configured with static GPS coordinates, or paired with a remote GPS tool.

In addition to logging GPS data on a per-packet basis, Kismet maintains a running average of device locations which are exported as the average location in the Kismet UI and in device summaries.  Kismet attempts to keep the running average location as accurate as possible by factoring speed into the location counts.

## Configuring GPS in Kismet

Kismet can handle multiple GPS types.  Generally, you will only want to define a single GPS per Kismet instance, however if multiple GPS devices are defined, Kismet will use the lcoation of the GPS with the most recent valid location report.

GPS definitions take the form of:

```
gps=[gpstype]:option1=value1,option2=value2
```

GPS is configured in the [kismet.conf](/docs/readme/configuring/configfiles/) configuration file, or preferably, the [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf) configuration override.


## GPS reception

Modern cell phones use a fusion of GPS, cellular, Wi-Fi, and Bluetooth locational data to generate locational information under almost any condition.

By comparison, traditional GPS-only receivers require a clear view of the sky, and will rarely obtain a signal lock if the receiver is indoors or in a window.

When testing GPS, be sure to give the receiver as much a view of the sky as possible.

