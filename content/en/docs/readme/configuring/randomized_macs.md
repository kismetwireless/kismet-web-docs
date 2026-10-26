---
title: "Randomized MAC addresses"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "randomized-macs-4b7f2e91c06d3a58e1f9b2d7c4a8e630"
weight: 60
toc: true
---

Added: `2026-10`

Most phones, and many other devices, use randomized MAC addresses to make it harder to follow them over time.  A Wi-Fi client may use a new address each time it scans for networks, and BTLE devices change their random address every few minutes.  Each new address shows up in Kismet as a new device.

## Wi-Fi clients

Wi-Fi clients using a *locally administered* address (a unicast address whose second hex digit is 2, 6, A, or E, such as `02:00:00:00:00:01`) are flagged as randomized, since these addresses are not assigned from a vendor's OUI and almost always mean a privacy randomized address.

* The Wi-Fi device record gets `dot11.device.randomized_mac` set.  The field is only present on flagged devices.
* The manufacturer is shown as `Randomized`, unless the address matched a known manufacturer.
* Access points are not flagged.  A client which later acts as an access point, such as a phone running a hotspot, has the flag cleared and its manufacturer looked up again.

This is always on; there is no option to control it.

## Linking randomized addresses

Kismet can try to recognize when a new randomized address belongs to the same device as an address it saw before, and link them.  This is **off by default**: it undoes some of the privacy that address randomization gives, so only turn it on when it is appropriate for what you are monitoring.

Linking does *not* merge devices.  Each address stays a separate device, with its own record, packets, and signal history.  Linked devices:

* are related to each other in their related devices list, as `dot11_randomized_alias` or `btle_randomized_alias`
* share an alias group (`dot11.device.alias_group` or `btle.device.alias_group`), which is the key of the first device in the chain of linked addresses
* record how the address was linked to the previous one (`dot11.device.alias_method` or `btle.device.alias_method`)

Linking is a best guess: it can link two devices which are not the same, and miss addresses which are.  Kismet does not remember addresses between runs, so an address from a previous run is never linked to a new one.

### Wi-Fi

{{<configopt dot11_link_randomized true false>}}
Link the randomized addresses a Wi-Fi client cycles through while sending probe requests.  Only clients flagged as randomized are linked.

Kismet fingerprints the information elements of each probe request (supported rates, HT/VHT/HE capabilities, extended capabilities, vendor elements, and so on, but not the SSID or channel), which mostly identify the hardware and driver.  A new address is linked to an earlier one when it sends the same fingerprint within 60 seconds of the earlier address going quiet, and the earlier address then stays quiet for at least 30 seconds.

* **sequence**: the 802.11 sequence number of the new address picks up shortly after the last one from the earlier address.  This can tell apart several devices of the same model.
* **timing**: the sequence numbers didn't decide, so the link was made because only one device with that fingerprint was around.  If another device with the same fingerprint is active, no timing link is made.

Probe requests with too few elements to tell devices apart are not linked.

This option is set in `kismet_80211.conf` (or `kismet_site.conf`); the default is `false`:

```
dot11_link_randomized=true
```
{{</configopt>}}

### BTLE

{{<configopt btle_link_randomized true false>}}
Link the random addresses a BTLE device rotates through.  A device's advertising data and its address often change at different times, so when the first advertisement from a new address carries the same data (ignoring the flags and transmit power records) as the last one from an address which went quiet within the last 15 seconds, and the earlier address stays quiet for at least 30 seconds, the two are linked with the method **payload**.  If another device sending the same advertising data is active, no link is made.  Advertisements with too little data to be unique to one device are not linked.

This applies to BTLE sniffer sources; it does not apply to the Linux HCI scanning source.  BTLE devices with random addresses which are dropped by `btle_ignore_random` are never linked.

This option is set in `kismet.conf` (or `kismet_site.conf`); it is off by default:

```
btle_link_randomized=true
```
{{</configopt>}}

## Ignoring random BTLE devices

{{<configopt btle_ignore_random true false>}}
Drop BTLE devices which use random addresses.  This prevents a flood of short-lived devices in the UI and logs, at the cost of not seeing them at all.  Drones broadcasting Remote ID and known location trackers (see [Bluetooth trackers](/docs/readme/datasources/bluetooth-trackers/)) are always kept.

This option is set in `kismet_filter.conf` (or `kismet_site.conf`); it is off by default:

```
btle_ignore_random=true
```
{{</configopt>}}
