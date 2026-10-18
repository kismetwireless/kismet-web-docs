---
title: "UAV drones"
description: ""
lead: ""
date: 2022-11-08T21:52:53-05:00
lastmod: 2022-11-08T21:52:53-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "uav_drone-761a97a5034a56ae216a8ca7c13d6788"
weight: 390
toc: true
---

Kismet can identify UAVs and drones by specific fingerprints (such as DJI DroneID elements in
WiFi beacons), by [Open Drone ID / Remote ID](/docs/readme/datasources/drone-opendroneid/) broadcasts,
or by common SSIDs and manufacturers.

Remote ID devices include a `uav.remoteid` record in the UAV device data, with the decoded Basic ID,
Location, System, Self ID, Operator ID and authentication fields.  Fields only appear once they have
been received.

{{< kismet_api uav_drone >}}
