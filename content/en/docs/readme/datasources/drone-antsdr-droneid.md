---
title: "Drone: AntSDR DroneID"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "drone-antsdr-droneid-568319851a43422192265fe116b83a56"
weight: 850
toc: true
---

Added: `2024-04`

The AntSDR DroneID source receives DJI DroneID records decoded from RF by an AntSDR running a DJI DroneID demodulator, which publishes the decoded records over TCP.

DJI drones broadcast DroneID over RF, including the drone serial number and model, the location, altitude and speed of the drone, the location of the pilot (the app), and the home location.  Kismet creates a UAV device for each drone, and records its location.

AntSDR DroneID sources are named `antsdr-droneid`, and must include the `host` and `port` options:

```bash
kismet -c antsdr-droneid:host=192.168.1.10,port=41030
```

The port is the TCP port of the DroneID service on the AntSDR; there is no default.

## Supported hardware

The AntSDR DroneID source requires an AntSDR SDR running a DJI DroneID demodulator which provides a TCP service.

## Compiling AntSDR DroneID support

AntSDR DroneID support is built automatically, and needs no additional libraries.

## Kismet AntSDR DroneID support

Each DroneID record creates or updates a `DJI UAV` device, named from the drone model and serial number.  When the drone location is reported, it is used as the device location, along with the altitude, heading, and speed.

The home location and the app (pilot) location are recorded with the UAV, and shown in the UAV details in the web UI.  See the [UAV API](/docs/api/uav_drone/) for the UAV records.

DroneID records are logged in the [kismetdb](/docs/readme/logging/kismetdb/) log `data` table, and the UAV devices in the devices table.

DroneID records can also be imported from an MQTT broker using the [MQTT](/docs/readme/datasources/mqtt/) source with `mapping=antsdr-droneid`.

## AntSDR DroneID source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Connection options

{{<configopt host "hostname or address">}}
The address of the AntSDR.  This option is required.
{{</configopt>}}

{{<configopt port "port">}}
The TCP port of the DroneID service on the AntSDR.  This option is required.
{{</configopt>}}

## Limitations

* Newer DJI drones may send encrypted DroneID; records which can not be decoded are ignored.
* If the connection to the AntSDR is lost, the source reports an error and Kismet re-opens it.
* Only IPv4 addresses are supported.
