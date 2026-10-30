---
title: "Receiver range"
description: ""
lead: ""
date: 2026-10-29T12:00:00-04:00
lastmod: 2026-10-29T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "receiver-range-4160d35730a4600be58b86ffeb7090e6"
weight: 47
toc: true
---

Added: `after 2026-10-R1`

Devices which report their own position, such as aircraft (ADSB), vessels (AIS), drones (Remote ID), and Meshtastic and MeshCore nodes, show how far away Kismet can hear them.  Kismet records the furthest distance a device of each kind is heard at in each degree of bearing, for each data source and for all of them together.  This is drawn as the range outline on the web UI map, much like the coverage plot of an ADSB receiver.

For each kind of device, Kismet keeps:

* The furthest distance in each direction over all time, with the altitude, time, and signal of the position which set it
* The furthest distance in each direction over the last day
* For devices which report an altitude, the furthest distance in each direction below 3000m, from 3000m to 7500m, and above 7500m

The range needs Kismet's own location, from a [GPS](/docs/readme/gps/gps_intro/) or a data source with a fixed location.  When Kismet's location isn't known, the positions go into the area devices were heard over instead: a convex hull around them, drawn on the map without range rings.

A mobile Kismet's range is its range around itself, wherever it has been.

Positions are only counted when they agree with the device's previous position: the first position from a device, repeated positions, and positions which jump further than the device could have moved are skipped, so a bad position decode doesn't stretch the outline.  Positions further away than the limit for the kind of device are taken as bad decodes.

The range is saved every five minutes and when Kismet exits, and loaded when Kismet starts.  The saved file holds where Kismet was, so it's only readable by the user running Kismet.

The range can be read and cleared with the [receiver range API](/docs/api/receiver_range/).

The receiver range options are in `kismet.conf`; as with other options, changes are best made in [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf).

{{<configopt range_tracking true false>}}
Record the receiver range.  Enabled by default.
{{</configopt>}}

{{<configopt range_save true false>}}
Save the receiver range to `range_file`, and load it at startup.  Enabled by default.
{{</configopt>}}

{{<configopt range_file path>}}
The file the receiver range is saved in, by default `%h/.kismet/kismet_range.json`.
{{</configopt>}}

{{<configopt range_max_km "kind,km">}}
The furthest distance, in kilometers, a position for a kind of device can be from Kismet; positions further away are taken as bad decodes.  The kind is the phy name, such as `ADSB`, or `UAV` for drones.  May be repeated for each kind, up to 2000km.

By default the limits are 600km for `ADSB`, 250km for `AIS`, 25km for `UAV`, 400km for `Meshtastic` and `MeshCore`, and 500km for anything else.

```
range_max_km=ADSB,400
```
{{</configopt>}}
