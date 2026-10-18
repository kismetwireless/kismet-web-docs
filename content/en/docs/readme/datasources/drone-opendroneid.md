---
title: "Drone: Open Drone ID / Remote ID"
description: ""
lead: ""
date: 2026-10-18T11:10:52-04:00
lastmod: 2026-10-18T11:10:52-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "drone-opendroneid-3f6b1c0e9a2d4b7e8c5f1a2b3c4d5e6f"
weight: 851
toc: true
---

Added: `2026-10`

Kismet decodes Open Drone ID broadcast Remote ID (ASTM F3411 and ASD-STAN EN 4709-002), the drone identification broadcast required in the US by the FAA and in the EU.  It is not a separate data source: Remote ID is decoded from the packets captured by existing Wi-Fi and Bluetooth sources.

Remote ID is broadcast over:

* **Wi-Fi beacons**, as a vendor element (ASD-STAN OUI `FA:0B:BC`, and the older Parrot OUI `90:3A:E6`)
* **Wi-Fi NAN** (Neighbor Awareness Networking) service discovery frames
* **BLE 4 legacy advertising**, as service data `0xFFFA`
* **BLE 5 extended advertising**, as service data `0xFFFA`, sometimes on the long range coded PHY

## Sources which can see Remote ID

* Any [Wi-Fi](/docs/readme/datasources/wifi-linux/) source in monitor mode sees Remote ID beacons and NAN frames.  NAN discovery normally happens on channel 6.
* Bluetooth LE sniffers which capture advertisements: [Sniffle](/docs/readme/datasources/bluetooth-sniffle-ble/), [nRF51822](/docs/readme/datasources/bluetooth-nrf51822/), [TI CC2540](/docs/readme/datasources/bluetooth-ticc2540/), [Ubertooth](/docs/readme/datasources/bluetooth-ubertooth/), and others.  BLE 5 extended Remote ID needs a sniffer which follows extended advertising, such as Sniffle with `auxadv=true` (and `phy=coded` for long range transmitters).
* The [Linux HCI Bluetooth](/docs/readme/datasources/bluetooth-hci-bluetooth/) source.

## Kismet Remote ID support

Each Remote ID transmitter becomes a `Drone / UAV` device, with a UAV record (`uav.device`) and a Remote ID record (`uav.remoteid`).  Kismet decodes all the Remote ID message types, and message packs:

* **Basic ID**: serial number, CAA registration, UTM or session ID, and the aircraft type
* **Location**: position, altitudes, height, speed, direction, status, and accuracy
* **Authentication**: reassembled from its pages
* **Self ID**: the operator's description of the flight
* **System**: the operator location, operating area, and EU category and class
* **Operator ID**

Drone positions are added to the UAV telemetry history.  The operator location is recorded as the UAV app location; when the drone reports it as the takeoff location, it is also recorded as the home location.

Remote ID fields only appear in the record once a message containing them has been received, and values the drone reports as unknown are removed, so the record never shows stale data.

Remote ID transmitters normally use random BLE addresses; they are kept even when random BLE addresses are being ignored.

## Limitations

* Kismet reports what the drone broadcasts.  Remote ID broadcasts are not authenticated (authentication messages are recorded but not verified), so a transmitter can claim any identity and location.
* A drone which broadcasts over several transports, such as Wi-Fi and BLE at the same time, appears as a separate device for each transmitter address.
* A Wi-Fi NAN Remote ID transmitter also creates an empty Wi-Fi access point device for its NAN cluster.
