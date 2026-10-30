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
    identifier: "receiver_range-972a7b869585cce7b6044277c46132ee"
weight: 248
toc: true
---

After 2026-10-R1, Kismet records the [receiver range](/docs/readme/configuring/receiver_range/): how far away devices which report their own position are heard, in each direction.

Ranges are kept by kind of device, the phy name (such as `ADSB` or `AIS`), with `UAV` for drones.  Each kind has a record for all data sources together, and one for each data source which heard it.

Distances are kept in bins of `kismet.range.bin_degrees` degrees of bearing from Kismet, starting at north and going clockwise; bin 0 covers 0 up to 1 degree.  Distances are in meters, and are 0 in directions nothing has been heard from.

## Range records

| Field | Content |
| ----- | ------- |
| `kismet.range.kind` | Kind of device |
| `kismet.range.source_uuid` | Data source UUID; only in a data source's record |
| `kismet.range.source_name` | Data source name |
| `kismet.range.samples` | Positions counted |
| `kismet.range.hull_samples` | Positions counted while Kismet's location was unknown |
| `kismet.range.rejected` | Positions rejected as bad decodes |
| `kismet.range.first_time`, `kismet.range.last_time` | First and last position counted (unix time) |
| `kismet.range.center` | Kismet's average location, `[lon, lat]`; only once Kismet's location has been known |
| `kismet.range.moved` | Furthest Kismet has been from its average location, in meters |
| `kismet.range.bin_degrees` | Degrees of bearing in each bin |
| `kismet.range.furthest`, `kismet.range.furthest_bearing` | Furthest distance, and its bearing in degrees |

The full record of one kind or data source also has:

| Field | Content |
| ----- | ------- |
| `kismet.range.distance` | Furthest distance in each bin, over all time |
| `kismet.range.altitude` | Altitude, in meters, of the furthest position in each bin |
| `kismet.range.time` | Time (unix time) of the furthest position in each bin |
| `kismet.range.signal` | Signal, in dBm, of the furthest position in each bin, or 0 if unknown |
| `kismet.range.day_distance` | Furthest distance in each bin over the last day |
| `kismet.range.bands` | By altitude: a list of bands, each with `kismet.range.band.min_alt` and `kismet.range.band.max_alt` in meters (0 for no upper limit), and `kismet.range.band.distance`, the furthest distance in each bin for positions in the band |
| `kismet.range.hull` | The area positions were heard over while Kismet's location was unknown: a convex hull, counterclockwise, as a list of `[lon, lat]` corners |

{{< kismet_api receiver_range >}}
