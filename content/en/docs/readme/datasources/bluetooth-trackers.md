---
title: "Bluetooth: Trackers, battery, and distance"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "bluetooth-trackers-8e2d41c7a9b35f60d1e4c7b2a6f9038d"
weight: 250
toc: true
---

Added: `2026-10`

Kismet decodes several kinds of information which Bluetooth devices advertise in the clear: location tracker advertisements, battery levels, and transmit power, which Kismet uses to estimate the distance to the device.  This is not a separate data source; it is decoded from the advertisements seen by existing Bluetooth sources.

## Sources which can see advertised data

* Bluetooth LE sniffers which capture advertisements: [Sniffle](/docs/readme/datasources/bluetooth-sniffle-ble/), [nRF51822](/docs/readme/datasources/bluetooth-nrf51822/), [TI CC2540](/docs/readme/datasources/bluetooth-ticc2540/), [Ubertooth](/docs/readme/datasources/bluetooth-ubertooth/), and others.
* The [Linux HCI Bluetooth](/docs/readme/datasources/bluetooth-hci-bluetooth/) source.  The HCI source reports the advertised service UUIDs, service data, manufacturer data, and transmit power level, rather than the raw packets, which is enough to decode everything on this page.

## Location trackers

Kismet identifies these location trackers from their advertisements:

| Tracker | Advertisement | Separated from owner |
|---------|---------------|----------------------|
| Samsung SmartTag | Service data `0xFD5A` | Yes |
| Apple Find My (AirTag, Find My network accessories, AirPods) | Apple manufacturer data, type `0x12` | Yes |
| Google Find My Device network (FMDN) | Service data `0xFEAA`, frame type `0x40` or `0x41` | From the DULT advertisement |
| DULT (IETF Detecting Unwanted Location Trackers) | Service data `0xFCB2` | Yes |
| Tile | Service data `0xFEED` (activated) or `0xFEEC` | No |
| Chipolo | Service data `0xFE33` | No |
| Pebblebee | Service UUID `0xFA25` | No |

Lost iPhones, iPads, and Macs send the same Find My advertisement as AirTags, but are not reported as trackers.

A tracker may alternate between its vendor advertisement and the DULT advertisement; the vendor advertisement names the type, and the DULT advertisement adds the finding network ID and whether the tracker is separated from its owner.  A tracker which only sends DULT is reported with the type `dult`.

Tile, Chipolo, and Pebblebee trackers are only identified; they do not advertise whether they are separated from their owner.

Trackers become `BTLE Tracker` devices, with a tracker record (`btle.device.tracker` for BTLE sniffers, `bluetooth.device.tracker` for the HCI source).  Fields are only present when the tracker type advertises them:

* **type**: `samsung_smarttag`, `apple_findmy`, `google_fmdn`, `dult`, `tile`, `chipolo`, or `pebblebee`
* **state** and **state_name**: the operating state the tracker advertises
* **separated**: the tracker advertises that it is away from its owner
* **battery**: `full`, `medium`, `low`, `very_low`, or `unknown`
* **subtype**: the kind of Apple device (`airtag`, `findmy_accessory`, `airpods`)
* **maintained**: the owner connected to an Apple tracker within its current key period
* **privacy_id**, **ephemeral_id**: the rotating identifier the tracker advertises.  The SmartTag privacy ID is recorded as advertised; the Tile identifier and the FMDN ephemeral ID are stored as a salted hash, never the identifier itself.  The salt is chosen when Kismet starts, so the hash only links advertisements within one run of Kismet.
* **network_id**: the finding network ID from the DULT advertisement
* **follow_time** and **follow_locations**: how long a separated tracker has been seen, and at how many places (see below)

Trackers normally use random BLE addresses; they are kept even when random BLE addresses are being ignored with `btle_ignore_random`.

### Trackers following you

When a tracker which advertises that it is separated from its owner keeps showing up as you move, Kismet raises the [TRACKERFOLLOW](/docs/readme/alerts/alerts/#trackerfollow) alert.  The alert is raised when the tracker has been seen:

* continuously while separated, for at least 30 minutes, with no gap longer than 20 minutes, and
* at three or more places at least 100 meters apart.

This needs a GPS with a fix; without a GPS, Kismet still counts the time but no places, and does not raise the alert.  The alert is raised once per tracker; it can be raised again if the tracker stops advertising that it is separated, or is not seen for over 20 minutes, and then meets the conditions again.

These thresholds are fixed.  The alert rate can be changed, or the alert disabled, like any other alert:

```
alert=TRACKERFOLLOW,0/min,0/sec
```

Kismet tracks each tracker by its Bluetooth address; a tracker which changes its address starts over as a new device.

## Battery levels

Kismet records the battery level from devices which advertise it without a connection:

* **apple_proximity**: AirPods and Beats, with the left, right, and case levels and charging state
* **fast_pair**: Google Fast Pair devices (when not in pairing mode), with the left, right, and case levels
* **bthome**: BTHome v2 sensors which are not encrypted
* **pvvx**, **atc1441**: thermometers running the pvvx or ATC1441 custom firmware, with percent and voltage
* **eddystone_tlm**: Eddystone TLM beacons, voltage only
* **battery_service**: devices which repeat the Battery Service level as service data
* **ruuvi**: Ruuvi tags (data format 5), voltage only

The battery record (`btle.device.battery` or `bluetooth.device.battery`) has the source, the percent (`-1` if not known), the charging state, the voltage in millivolts when it is advertised, and for earbuds the levels of each bud and the case.

## Estimated distance

Devices which say how much power they transmit get an estimated distance from the signal received.  In order of preference, Kismet uses:

* the 1 meter calibrated power from iBeacon and AltBeacon beacons
* the 0 meter power from Eddystone UID and URL beacons
* the transmit power from Ruuvi tags
* the TX Power Level record which many other devices advertise

The ranging record (`btle.device.ranging` or `bluetooth.device.ranging`) has the source, the expected signal at 1 meter, the smoothed signal used for the estimate, and the estimated distance in meters (between 0.1 and 1000).

The estimate uses the log-distance path loss model, and is rough at best: walls, bodies, antenna orientation, and the receiving radio all change the signal.  It is most useful to tell near from far, or to see whether a device is getting closer.

The estimate needs a signal level in dBm from the source.  For devices which only send the TX Power Level record, the Linux HCI source needs a `kismet_cap_linux_bluetooth` from the same release, which passes the record to Kismet.

{{<configopt btle_distance_exponent exponent>}}
The path loss exponent used for the distance estimate.  `2.0` matches free space and open areas; `2.5` to `4.0` is typical indoors.  Larger values give shorter distances for the same signal.  Values outside `1.0` to `6.0` are ignored and `2.0` is used.

This option is set in `kismet.conf` (or `kismet_site.conf`); the default is `2.0`:

```
btle_distance_exponent=3.0
```
{{</configopt>}}

## Limitations

* Kismet reports what the device advertises.  None of these advertisements are authenticated, so a device can claim to be any tracker, battery level, or transmit power.
* Kismet does not connect to devices; battery levels which are only available over a connection are not seen.
