---
title: "RRD datasets"
description: ""
lead: ""
date: 2023-01-10T12:02:55-05:00
lastmod: 2023-01-10T12:02:55-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "rrd-6f3dfb47fa3b4b8f0f210e673fd520ab"
weight: 51
toc: true
---

Kismet uses a format known as "RRD" or "Round Robin Database" to store summarized trend data over a long timeline.

The RRD concept comes from [RRDTool](https://oss.oetiker.ch/rrdtool/) and the [Cacti](https://www.cacti.net/) monitoring tool.

## RRD usage

Typically data is added to a RRD dataset either on a schedule (once per second, for instance), or when events occur (such as new packets).

When new data is added to a RRD, or when the RRD is serialized for storage or presentation to an API call, the data is "fast-forwarded" to the current time:  If no new data has occurred for the past 60 seconds, for example, serializing the dataset will cause the minutes record to be zeroed and the average added to the minutes record.

Kismet supports several accumulators for RRD data, including additive (new samples are added to existing samples, such as packet counts) and peak (only the highest event count for that time is used, such as high watermark records for packet rates or temperature measurements).

## The RRD dataset

A RRD dataset stores trends with decreasing precision.  In Kismet, a RRD typically stores:

* The last minute of events with second precision.
* The last hour of events with minute precision.
* The last day of events with hour precision.

The RRD data is stored as a ring - instead of allocating and removing records, the next timeslot in the ring is used.

Additionally, the dataset includes:

* The time of serialization (used for formatting the RRD for presentation)
* The nil or blank value for unused data

## An example dataset

A example RRD dataset might look like:

```json
{
 "kismet.packetchain.processed_packets_rrd": {
  "kismet.common.rrd.day_vec": [ 68, 73, 121, 134, 124, 69, 98, 103, 69, 92, 98, 104, 79, 128, 107,
    92, 82, 71, 72, 75, 68, 71, 72, 75 ],

  "kismet.common.rrd.blank_val": 0,

  "kismet.common.rrd.last_time": 1673302851,

  "kismet.common.rrd.serial_time": 1673302851,

  "kismet.common.rrd.minute_vec": [ 95, 87, 28, 116, 158, 128, 47, 13, 271, 159, 165, 2, 60, 49, 149,
   27, 55, 157, 130, 169, 51, 50, 108, 103, 85, 33, 62, 244, 53, 109, 13, 155, 105, 37, 51, 174, 51,
   41, 40, 173, 49, 155, 5, 54, 88, 106, 64, 54, 71, 164, 62, 12, 154, 2, 156, 36, 47, 47, 127, 1 ],

  "kismet.common.rrd.hour_vec": [ 71, 81, 78, 67, 68, 74, 63, 66, 74, 75, 73, 82, 96, 89, 73, 75, 74,
   73, 90, 82, 87, 61, 73, 66, 81, 71, 67, 65, 90, 67, 66, 80, 68, 76, 66, 62, 70, 68, 63, 59, 67, 61,
   67, 67, 66, 74, 70, 72, 71, 71, 83, 75, 78, 69, 68, 78, 80, 74, 77, 73 ]
  }
}
```

## Processing a RRD dataset

To process a RRD dataset for display, simply consult the serialization time, and use it to find the starting timeslot.

To find the position of the latest data, modulo the timeslot by the precision of the record you wish to index.

For example, to find the latest record of the minute data:

```javascript
// 60 seconds in a minute; modulo 60 yields 51
let slot = (data["kismet.common.rrd.serial_time"] % 60;
```

Our most recent record is at index 51.  One second in the past is index 50, and so on.  At position 0, the ring loops.

Envisioned a different way, as an incremental time-based array, the first record is the current time + 1, and the entire array can be indexed using a modulo operation:

```javascript
let slot = data["kismet.common.rrd.serial_time"] % 60;
for (let i = 0; i < 60; i++) {
    let index_slot = (slot + 1 + i) % 60;
    let value = data["kismet.common.rrd.minute_vec"][index_slot];
    console.log(index_slot, value);
}
```

First we find the current time slot, then we iterate the length of the ring (60), starting at `now + 1`.

Similarly, to find the latest minute record:

```javascript
// Divide timestamp to get minutes, modulo 60 to get bin
let slot = Math.floor(data["kismet.common.rrd.serial_time"] / 60) % 60;
```

and to compute hours:

```javascript
let slot = Math.floor(data["kismet.common.rrd.serial_time"] / 3600) % 24;
```
