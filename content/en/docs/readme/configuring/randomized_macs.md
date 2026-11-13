---
title: "Randomized MAC addresses"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-11-13T15:30:00-05:00
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
Link the random addresses a BTLE device rotates through.  A device's advertising data and its address often change at different times, so when the first advertisement from a new address carries the same data (ignoring the flags and transmit power records) as the last one from an address which went quiet within the last 15 seconds, and the earlier address stays quiet for at least 30 seconds, the two are linked with the method **payload**.  Advertisements with too little data to be unique to one device are not linked.

When another device sending the same advertising data is active, such as a second tag of the same model, after 2026-10-R1 the signal decides: the new address is linked with the method **signal** to the earlier address whose last signal on the same data source is within 8 dB of the new address's first, and at least 4 dB closer than any other earlier address that could be the one.  If an earlier address that could be the one was last heard on another data source, or no address is clearly closest, no link is made.  Before then, no link was made when another device sending the same data was active.

This applies to BTLE sniffer sources, and after 2026-10-R1 to the LE devices the Linux HCI scanning source reports; before then it did not apply to the HCI source.  BTLE devices with rotating random addresses which are dropped by `btle_random=ignore` (or `btle_ignore_random`) are never linked.

This option is set in `kismet.conf` (or `kismet_site.conf`).  It is off by default, unless [`btle_related`](#btle-related-devices) is on; set it to `false` to keep linking off then:

```
btle_link_randomized=true
```
{{</configopt>}}

Apple devices, and others which change their whole payload with the address, never send the same data from two addresses, so after 2026-10-R1 Kismet has two more ways to link them.  Both need `btle_link_randomized` on.

{{<configopt btle_link_handoff true false>}}
Link Apple devices by the counter in their Continuity *Handoff* advertisements.  The rest of a Handoff message is encrypted and changes with the address, but the counter carries on across the change:

* **handoff**: the first counter from a new address is 1 to 4 past the last one from an address which went quiet.  When addresses from more than one device match, the counter links nothing.
* **concurrent**: two addresses send the same counter at the same time, on the same data source within 8 dB, and still do 5 seconds later.  A device sending two advertising sets at once does this; the two addresses are linked to each other.

The counter itself is not stored or shown.  A device copying another's counter can join its group, so treat these links as a best guess too.

This option is set in `kismet.conf` (or `kismet_site.conf`); it is on by default, and does nothing unless `btle_link_randomized` is on:

```
btle_link_handoff=false
```
{{</configopt>}}

{{<configopt btle_link_corotation true false>}}
A device sending several advertising sets, such as a phone sending Handoff, Nearby, and AirPlay advertisements, changes all of their addresses at the same moment.  When one of the device's addresses is linked to its next (by any method), its other addresses which went quiet within 1 second of it, and the new addresses which started within 1 second of the new one, on the same data source within 8 dB of its signal, are its other advertising sets; they are linked with the method **corotation**.

* A set's old and new addresses are paired by the [structure](#btle-related-devices) of their advertisements, so each kind of advertisement must show up exactly once among the old addresses and once among the new.  Otherwise, nothing is linked at that rotation.
* Another device can change its address at the same moment by chance, so a set is only linked once it has rotated with the device at two rotations in a row.  The address it had before the first of those is not linked.

This option is set in `kismet.conf` (or `kismet_site.conf`); it is on by default, and does nothing unless `btle_link_randomized` is on:

```
btle_link_corotation=false
```
{{</configopt>}}

The **handoff**, **concurrent**, and **corotation** methods, and the **signal** method, compare when packets arrived.  When replaying a capture file, use `realtime=true` on the [pcapfile source](/docs/readme/datasources/pcapfile/); replayed as fast as possible, packets are processed slightly out of order, and these links are missed or wrong.

## BTLE related devices

After 2026-10-R1, Kismet can group the rotating random addresses of BTLE devices by their advertising payload.  The addresses a device moves through advertise the same payload, and so do identical devices, such as several of the same model of tag or headphones; addresses with the same payload are *related*.  This is **off by default**, for the same reason linking is.

Related devices differ from [linking](#btle): linking only joins an address to the one it directly replaced, and makes no link when two devices sending the same payload are active at once.  Related devices put every address with the same payload in one group, whether it came from one device or several, and mark the addresses which have gone quiet since a newer one appeared, so they can be hidden.  Each address is still a separate device.

{{<configopt btle_related true false>}}
Group rotating random BTLE addresses which advertise the same payload.  Each address in a group gets:

| Field | Content |
| ----- | ------- |
| `btle.device.related_group` | The group, shared by the related addresses |
| `btle.device.related_count` | How many addresses are in the group, this one included |
| `btle.device.related_newest` | The device key of the most recent address in the group |
| `btle.device.old_address` | Set once the address has gone quiet and a newer address with the same payload has appeared |
| `btle.device.related_truncated` | Older addresses were left out of the group to save memory |
| `btle.device.related_active` | How many addresses in the group were heard within `btle_related_quiet`: about how many devices with this payload are around now |
| `btle.device.unmatched_random` | With `btle_random=hide_unmatched`, a rotating random address whose payload no other address has shared |

The addresses in a device's group are listed by `/phy/btle/related-of/<device key>/devices.json`.  The web UI shows them in the *BTLE Related Devices* section of the device details, with a timeline of when each address was seen, and the device list search can find them with `related > 1`.

Some devices change their whole payload each time they change address, as Apple Continuity, Google Fast Pair, and Microsoft Swift Pair advertisements do, so their addresses never share a payload.  Kismet also groups addresses whose advertisements have the same *structure*: the same kinds of records, with the same lengths, company ID, Apple Continuity message types, service UUIDs, and name, whatever the changing bytes are.  These are *similar* addresses.  Many devices of the same model look alike this way, so a similar group is a weaker match than a related group, and addresses are never marked old from it.  Each address in a similar group gets:

| Field | Content |
| ----- | ------- |
| `btle.device.similar_group` | The similar group, shared by the similar addresses |
| `btle.device.similar_count` | How many addresses are in the similar group, this one included |
| `btle.device.similar_active` | How many of them were heard within `btle_related_quiet` |

Similar groups have the same limits as related groups.  The addresses in one are listed by `/phy/btle/similar-of/<device key>/devices.json`; the web UI shows them in the *BTLE Similar Devices* section of the device details, and the search can find them with `similar > 1`.

With `btle_related` on, Kismet also [links](#btle) each address to the one it replaced, unless `btle_link_randomized=false`.

The `btle-related-old-address` and `btle-related-unmatched` rules shipped in `kismet_device_rules_highlights.txt` tag old addresses and leave old and unmatched addresses out of the [default view](/docs/readme/configuring/device_rules/#the-default-view).

Related devices are not tracked when random addresses are ignored (`btle_random=ignore`).

This option is set in `kismet_filter.conf` (or `kismet_site.conf`); it is off by default:

```
btle_related=true
```
{{</configopt>}}

{{<configopt btle_related_quiet seconds>}}
An address is old after this many seconds without being heard, if a newer address with the same payload has appeared; the default is 60, between 1 and 3600.
{{</configopt>}}

{{<configopt btle_related_max_groups count>}}
Groups are kept until a limit is reached, not by time.  At most this many groups are tracked, by default 128, between 1 and 65536; past that, the group heard least recently is forgotten.  Addresses in a forgotten group keep their last group fields.
{{</configopt>}}

{{<configopt btle_related_max_addresses count>}}
Each group holds at most this many addresses, by default 64, between 2 and 1024; past that, the address quiet the longest is dropped from the group, which is marked with `btle.device.related_truncated`.  A dropped address keeps its last group fields.
{{</configopt>}}

{{<configopt btle_related_steady seconds>}}
After 2026-10-R1: some devices change their payload every few seconds while keeping their address, as many Apple devices do.  No payload of theirs lasts, so they would hop from group to group.  Once an address's payload changes, it is left out of related and similar groups (its group is 0) until it has sent one payload for this many seconds, then it joins that payload's group again.  An address quiet for this long starts over.  The default is 60, up to 3600; 0 groups an address with its new payload at once, as before.

Scan responses, which a device sends only to a scanner and which differ from its advertising, and payloads too short to fingerprint never move an address between groups.

This applies to related and similar groups separately: a device whose payload changes but whose structure doesn't stays in its similar group.  Addresses left out of groups are still [linked](#btle).
{{</configopt>}}

## Ignoring random BTLE devices

{{<configopt btle_random track hide_unmatched ignore>}}
What happens to BTLE devices with rotating random addresses, after 2026-10-R1:

* `track` tracks every one; this is the default.
* `hide_unmatched` tracks every one, and marks those whose advertising payload no other address shares with `btle.device.unmatched_random`, which the shipped `btle-related-unmatched` device rule leaves out of the web UI's *Default* device view.  This turns on [`btle_related`](#btle-related-devices).  An address stays matched once another address has shared its payload.
* `ignore` drops them, as `btle_ignore_random=true` does.

When `btle_random` is set, `btle_ignore_random` is not used.

This option is set in `kismet_filter.conf` (or `kismet_site.conf`):

```
btle_random=hide_unmatched
```
{{</configopt>}}

{{<configopt btle_ignore_random true false>}}
Drop BTLE devices which use rotating random addresses (resolvable and non-resolvable private addresses, which change every few minutes).  This prevents a flood of short-lived devices in the UI and logs, at the cost of not seeing them at all.  Their packets are still logged.  Drones broadcasting Remote ID and known location trackers (see [Bluetooth trackers](/docs/readme/datasources/bluetooth-trackers/)) are always kept.

After 2026-10-R1, devices with a static random address are kept: they keep the address until they are reset, and fixed devices such as smoke alarms, sensors, and beacons often use one.  Before then, every device with a random address was dropped.

After 2026-10-R1 this also drops random address devices reported by the Linux HCI source, whose LE devices are BTLE devices.

After 2026-10-R1, `btle_random=ignore` is the same option under its newer name.

This option is set in `kismet_filter.conf` (or `kismet_site.conf`); it is off by default:

```
btle_ignore_random=true
```
{{</configopt>}}
