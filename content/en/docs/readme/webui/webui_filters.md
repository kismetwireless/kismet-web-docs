---
title: "Device filters"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "webui_filters-4db43b408778830c0f49a8b4b5d4c6b0"
weight: 20
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The filter language is a very new feature, and may change before it is in a Kismet release.  Filters written for one nightly build may need to be changed for a later one.
{{< /alert >}}

The *Search or filter* box above the device list in the [new web UI](/docs/readme/webui/webui_intro/) does two things:

* Plain words, such as `Huawei` or `Bed Bath and Beyond`, search the device list the same way as before.
* Anything with an operator, quotes, a MAC address, or a sort becomes a **filter**: a condition on device fields, checked by the Kismet server, which only lists the devices that match.

Filters are written in a short form in the box, and the web UI turns them into a condition in the [device rules](/docs/readme/configuring/device_rules/) language.  Hovering over the box shows the condition sent to the server.  When a filter has an error, it's shown next to the box, with where in the filter it is.

## Examples

| In the search box | Lists |
| ----------------- | ----- |
| `Huawei \|\| Dell` | Devices with either word in any shown field |
| `manuf ~ apple` | Devices whose manufacturer contains `apple`, in any case |
| `packets > 1000 && signal > -60` | Busy devices which are close by |
| `type == "Wi-Fi AP" && crypt == Open` | Open Wi-Fi access points |
| `ssid == ONE \|\| ssid == TWO` | Networks advertising either SSID |
| `ssid* ~ guest` | Devices advertising, responding with, or probing for an SSID containing `guest` |
| `name =~ /^corp-/` | Devices whose name matches a regular expression |
| `last_time < 5m` | Devices seen in the last 5 minutes |
| `first_time < 1h && phy == BTLE` | Bluetooth LE devices first seen in the last hour |
| `00:11:22` | Devices with `00:11:22` anywhere in any MAC address field |
| `^00:11:22 \|\| 33:44$` | MAC addresses starting with `00:11:22`, or ending in `33:44` |
| `!(phy == IEEE802.11)` | Everything but Wi-Fi |
| `phy == ADSB sort: signal desc, packets` | Aircraft, strongest first |
| `sort: last_time desc` | Every device, most recently seen first |

## Writing filters

### Combining conditions

| Operator | Means |
| -------- | ----- |
| `&&` or `and` | Both conditions |
| `\|\|` or `or` | Either condition |
| `!` or `not` | Not the condition |
| `( )` | Grouping |

Conditions next to each other without an operator are combined with `and`.  `and`, `or`, and `not` written as words only count as operators in a filter; a box with only words in it, such as `Bed Bath and Beyond`, is still a plain search.

### Comparisons

| Operator | Means |
| -------- | ----- |
| `==` (or `=`), `!=` | Equal, not equal |
| `<`, `<=`, `>`, `>=` | Less than, greater than, for numbers and times |
| `~` | Contains, in any case, for text; for MAC addresses, contains the octets anywhere |
| `=~ /regex/` | Matches a regular expression, for text; a `/` in the expression is written `\/` |

Text with spaces or operator characters goes in double quotes, as in `type == "Wi-Fi AP"`.  A word on its own, without a field, matches devices with that word in any of the fields the device list asks for.

### Times

Comparing a time field with a duration (`30s`, `5m`, `2h`, `1d`) compares how long ago it was: `last_time < 5m` lists devices seen in the last 5 minutes, and `first_time > 1d` devices first seen more than a day ago.

### MAC addresses

A MAC address, or a part of one from 1 to 6 octets (such as `00:11:22`, `aa:bb`, or `aa:`), separated by `:` or `-`, matches anywhere in the address, in every MAC address field the device list knows (the device MAC, BSSIDs, and others).  Starting it with `^` only matches the start of the address, and ending it with `$` only the end.

With a field, `mac == 00:11:22:33:44:55` matches the whole address, and `bssid ~ 22:33` part of it.

## Field names

A field can be named in several ways:

* The short names from the device rules language: `mac`, `name`, `phy`, `type`, `manuf`, `crypt`, `channel`, `frequency`, `packets`, `datasize`, `first_time`, `last_time`, `mod_time`, `num_alerts`, `signal`, `min_signal`, and `max_signal`.
* Device list columns, by their name or title, in lowercase with spaces as `_`, and without a group name: `ssid`, `bssid`, `clients`, `encryption`, `last_seen`, and so on.
* Search groups, such as `adsb`, `ais`, `uav`, `cell`, `base`, or `rule_tags`, which match when any of their fields do.
* Full Kismet field paths, such as `kismet.device.base.manuf` or `dot11.device/dot11.device.last_bssid`.

Some names have a wider form, written with `*`:

| Name | Fields |
| ---- | ------ |
| `ssid*` | Advertised, responded, and probed SSIDs |
| `bssid*` | The last BSSID and the BSSIDs probed for |
| `mac*` | Every MAC address field |

Numbers and times can only be compared with `==`, `!=`, `<`, `<=`, `>`, and `>=`; text and MAC addresses with `==`, `!=`, `~`, and (for text) `=~`.

## Sorting

`sort:` followed by fields orders the list, each with `asc` or `desc`; later fields break ties in earlier ones.  A sort can follow a filter or be used on its own:

```
phy == BTLE sort: signal desc, packets desc
```

A sort in the box replaces sorting by a column header.

## Filters in the REST API

{{< alert icon="⚠️" context="warning" >}}
The `filter` and `filter_sort` parameters are very new, and their syntax may change before they are in a Kismet release.
{{< /alert >}}

The web UI sends filters to the server as the `filter` and `filter_sort` parameters of [device views](/docs/api/device_views/#view-based-device-lists), and other tools can do the same.  These take a condition, and sort keys, in the full [device rules language](/docs/readme/configuring/device_rules/#device-view-filters), rather than the short form of the search box; for instance:

```
filter=packets > 100 and manuf icontains "apple"
filter_sort=kismet.device.base.signal/kismet.common.signal.last_signal desc
```

In a filter, `text("<s>")` matches devices where any text field the request asks for contains `s`, in any case.
