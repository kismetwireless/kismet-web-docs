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

*Remember*: Kismet uses the GPS to determine the location *where a packet was seen*.  This is not necessarily the *location of the transmitter*, but can be used to determine where the transmitter is likely located.

The quality of the location estimates is determined in part by the quality of the sampling methods.  Passing a transmitter once in a straight line (such as driving past) limits the possible location to that single path.  By circling the area of the suspected transmitter, or navigating in a grid around it, the data available to deduce the transmitter location is greatly increased.

GPS data is included in the log files, in PPI pcap files, and exported over the REST interface.

Some datasources (such as ADSB) are able to self-source locational data; when absolute location information is available, Kismet will prefer that data.

Remote datasources can be configured with static GPS coordinates, or paired with a remote GPS tool.

In addition to logging GPS data on a per-packet basis, Kismet maintains a running average of device locations which are exported as the average location in the Kismet UI and in device summaries.  Kismet attempts to keep the running average location as accurate as possible by factoring speed into the location counts.

## GPS reception

Modern cell phones use a fusion of GPS, cellular, Wi-Fi, and Bluetooth locational data to generate locational information under almost any condition.  This can lead to a false sense of GPS reception in an area.  USB GPS receivers typically only provide *true* GPS processing without fusion of other locational services.  They typically require a clear view of the sky, and may be unable to obtain a GPS lock inside a building, or even when placed in a window, depending on orientation.

Some GPS units support multiple GPS variants implemented by different countries; these "multi-constellation" receivers may be able to obtain a stronger location signal in more locations, but typically are more expensive.

When testing GPS, be sure to give the receiver as much a view of the sky as possible.

## Configuring GPS in Kismet

Kismet can handle multiple GPS types.  Generally, you will only want to define a single GPS per Kismet instance, however if multiple GPS devices are defined, Kismet will use the lcoation of the GPS with the most recent valid location report.

GPS definitions take the form of:

```
gps=[gpstype]:option1=value1,option2=value2
```

GPS is configured in the [kismet.conf](/docs/readme/configuring/configfiles/) configuration file, or preferably, the [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf) configuration override.
