---
title: "Device rules"
description: ""
lead: ""
date: 2026-10-29T12:00:00-04:00
lastmod: 2026-11-08T21:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "device-rules-8c1d4e7a2b9f305d6e1a4c8b7f2d9e03"
weight: 45
toc: true
---

Added: `after 2026-10-R1`

Device rules match devices on the server, as they're seen, and act on the devices which match: they can tag devices, give them a highlight color, collect them into a [device view](/docs/api/device_views/), raise an alert when a device starts matching, and send matching devices to a [webhook](/docs/readme/configuring/webhooks/).  Sorts, written in the same language, order the devices in a device view.

Rules are written in a small language, and are compiled to native code where the platform allows it, so a large number of rules can be checked against a large number of devices.

Rules can be loaded from rules files, from the Kismet config, and from the [REST API](/docs/api/device_rules/).

## Writing rules

Each rule has a name, a condition, and what to do with devices which match it:

```
rule <name> {
    when <condition>
    description "<text>"
    tag "<text>"
    color "#rrggbb"
    view "<description>"
    alert
    live
    webhook "<endpoint>" { ... }
}
```

* `when` is the condition a device must match.
* `description` says what the rule finds, in at most 1024 characters; the web UI shows it with the rule's tags.
* `tag` tags matching devices; a rule can have any number of tags.
* `color` gives matching devices a highlight color, which the web UI also uses for the rule's tags.  When a device matches several rules with colors, the first rule wins.
* `view` collects matching devices in the device view `rule-<name>`, with the description as the view name; without one, the view takes the rule's `description`, or `Devices matching rule <name>`.
* `alert` raises a `DEVICERULE` alert when a device starts matching the rule.
* `live` checks the rule on every packet which updates a device, as well as on the timer.
* `webhook` sends matching devices to a [webhook endpoint](/docs/readme/configuring/webhooks/#endpoints); see [webhooks](#webhooks) below.

### Fields

Conditions compare device fields to values.  Fields are Kismet field names, such as `kismet.device.base.manuf`, or a path through nested fields joined with `/` (with no spaces), such as `kismet.device.base.signal/kismet.common.signal.last_signal`.  A path through a list or a map of records matches when any of the records match, including the records in a map of lists, such as `dot11.device/dot11.device.wpa_handshake_list/dot11.eapol.message_num`.  Field names may start with digits, as in `802154.device/802154.device.key_state`, and paths can go through fields which point at another record, such as `dot11.device/dot11.device.last_beaconed_ssid_record/dot11.advertisedssid.ssid`.

The [devices API](/docs/api/devices/) shows which fields a device has.

The common fields have short names:

| Short name | Field |
| ---------- | ----- |
| `mac` | MAC address |
| `name` | Device name |
| `phy` | Phy name, such as `IEEE802.11` |
| `type` | Device type, such as `Wi-Fi AP` |
| `manuf` | Manufacturer |
| `crypt` | Encryption |
| `channel` | Channel |
| `frequency` | Frequency |
| `packets` | Total packets |
| `datasize` | Total data |
| `first_time` | Time first seen |
| `last_time` | Time last seen |
| `mod_time` | Time last changed |
| `num_alerts` | Number of alerts |
| `signal` | Last signal |
| `min_signal` | Weakest signal |
| `max_signal` | Strongest signal |
| `seenby` | Data sources which saw the device |
| `location` | Average location, as `[lon, lat]` (after 2026-10-R1) |
| `last_location` | Last location, as `[lon, lat]` (after 2026-10-R1) |

A comparison with a field the device doesn't have is false.

### Values and operators

* Numbers compare with `==`, `!=`, `<`, `<=`, `>`, and `>=`, and can be calculated with `+`, `-`, `*`, `/`, and `%`.  Put spaces around `/` for division, so it isn't read as a field path.
* Durations such as `30s`, `5m`, `2h`, and `1d` are numbers of seconds.  `now` is the current time, and `age(field)` is `now - field`.
* After 2026-10-R1, `lat(field)` and `lon(field)` are the latitude and longitude of a location, such as `lat(location)`.  A device without a location doesn't match.
* Strings compare with `==` and `!=`, or with `contains`, `icontains` (in any case), `startswith`, `endswith`, and `matches` (a PCRE regular expression), against a `"string"`.  After 2026-10-R1, `==`, `!=`, and `in` on the device type (`type`) ignore case, so `type == "wi-fi ap"` matches `Wi-Fi AP`; other strings match exactly.
* MAC addresses are written `aa:bb:cc:dd:ee:ff`, with an optional mask as `/24` or `/ff:ff:ff:00:00:00`; a short address such as `aa:bb:cc` matches the prefix.
* `x in [a, b, c]` and `x not in [a, b, c]` test against a list of values.
* `exists(field)` tests that a field is present, and `count(field)` counts the entries in a list or map.
* After 2026-10-R1, `has_tag("name")` tests that a device has the user tag `name`, as set from the device details or with `/devices/by-key/<key>/set_tag.cmd` (`tagname` and `tagvalue`).  Tags are saved with a device's name and notes, so they last across restarts.
* Conditions combine with `and`, `or`, `not`, and parentheses.

### Including other files

A rules file can read in other rules files, relative to itself:

```
include "<file>"
include "<dir>/*.rules"
```

A pattern reads every matching file in natural order, so `2_x.rules` comes before `10_x.rules`.

### Sorts

Sorts order the devices in a device view:

```
sort <name> {
    by <value> [asc|desc], <value> [asc|desc] ...
}
```

A value is a field or a calculation on fields, a true / false condition (false sorts first), or `rule`, the position of the first rule the device matches.  Later values break ties in earlier ones, and devices missing a value sort after the rest in either direction.

A device view is sorted by passing the sort name as [`rule_sort`](/docs/api/device_views/#view-based-device-lists), as in `/devices/views/all/devices.json?rule_sort=<name>`.

### Device view filters

{{< alert icon="⚠️" context="warning" >}}
Device view filters are a very new feature, and may change before they are in a Kismet release.
{{< /alert >}}

After 2026-10-R1, [device views](/docs/api/device_views/#view-based-device-lists) also take a condition and sort keys directly, without a named rule or sort, as `filter=<condition>` and `filter_sort=<value> [asc|desc], ...`.  The new web UI's device list search box sends these; see [device filters](/docs/readme/webui/webui_filters/) for the short form it takes.

In a filter, `text("<s>")` matches devices where any text field the request asks for (its `fields` list) contains `s`, in any case.  `text()` can only be used in view filters, not in rules.

### Examples

```
rule close-apple {
    when manuf contains "Apple" and signal > -60
    tag "close"
}

rule watchlist {
    when mac in [00:11:22:33:44:55, aa:bb:cc/24]
    tag "watchlist"
    view "Devices on the watch list"
    alert
    live
}

rule open-ap {
    when phy == "IEEE802.11" and type == "Wi-Fi AP" and crypt == "Open"
    tag "open"
}

rule free-ssid {
    when dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid icontains "free"
    tag "free wifi"
}

rule gone-quiet {
    when age(last_time) > 10m and packets > 1000
    tag "quiet"
}

rule quad {
    when lat(location) >= 10.0 and lat(location) <= 10.1 and lon(location) >= 20.0 and lon(location) <= 20.1
    tag "quad"
    view "Devices in the quad"
}

sort loudest {
    by signal desc, packets desc
}

sort by-rule {
    by rule, last_time desc
}
```

### Webhooks

A `webhook` statement sends devices which match the rule to an endpoint defined by a [`webhook_endpoint`](/docs/readme/configuring/webhooks/#endpoints) line in the config.  By itself, it sends a device when it starts matching; terms in braces change when it sends, and what:

```
webhook "<endpoint>" {
    trigger match | new | once | every <time> | change <field>, ... limit <time>
    for <time>
    stop
    rate <n>/<period> [burst <n>]
    batch <time> [max <n>]
    fields <field>, ...
    fire_existing
}
```

| Term | |
| ---- | - |
| `trigger match` | When a device starts matching; the default.  It's sent again only after it stops matching and matches again. |
| `trigger new` | When a device first seen after the rule loaded starts matching, once per device. |
| `trigger once` | The first device to match, once.  Loading the rules again keeps it used, as long as the rule keeps its name and the webhook keeps its trigger and its place in the rule. |
| `trigger every <time>` | While a device matches, each time it's updated, at most once per `<time>`, which must be 10 seconds or more. |
| `trigger change <field>, ... limit <time>` | When the fields change while a device matches, at most once per `<time>` per device, which must be 1 second or more; the limit is required.  Fields are single values, such as `signal` or `name`; a field which is a record or a list, such as `dot11.device` or `seenby`, is refused.  Changes within the limit are sent together when it's up, with the old and new values.  Up to 8 fields. |
| `for <time>` | A device must keep matching this long before it's sent. |
| `stop` | Also send when a device stops matching.  Not with `trigger once`. |
| `rate <n>/<period> [burst <n>]` | The most events from this webhook per period, such as `10/1m` or `100/1h`.  Default `10/1m`. |
| `batch <time> [max <n>]` | Hold events to send together: the first event opens a window, which is sent when `<time>` is up or `<n>` events are in it (default 100). |
| `fields <field>, ...` | The device fields to send, as the short [field names](#fields) rules use (`mac`, `name`, `signal`) or full field names and paths, as in the REST API's `fields`; up to 32.  The default is the device key, MAC, name, phy, type, manufacturer, channel, frequency, first and last time, and last signal. |
| `fire_existing` | Also send devices which already match when the rule loads; without it they're recorded and not sent. |

A rule can have up to 4 `webhook` statements.  The endpoint's own rate, queue, and retry limits apply on top of the rule's, along with `webhook_global_rate`; [`/webhooks/status.json`](/docs/api/webhooks/) shows what each webhook sent and held back.

`trigger new` goes by the time a device was first seen, so devices in an old pcap replayed into Kismet aren't new.

```
rule new-public-btle {
    description "New BTLE devices with public addresses"
    when phy == "BTLE" and not exists(btle.device.random_address_type)
    webhook "ha" {
        trigger new
        batch 30s max 100
        fields mac, name, signal
    }
}

rule watchlist-signal {
    when mac in [00:11:22:33:44:55]
    webhook "ha" {
        trigger change signal limit 30s
        stop
    }
}
```

### Limits

* An expression can have at most 256 operators, nested at most 64 deep.
* Rules set over the API can be at most 256KB of text.
* All of the rules together can make at most 256 views.

## Shipped rules

Kismet ships rules for notable devices in `kismet_device_rules_highlights.txt`, grouped by phy.  Each tags the devices it matches and collects them in a view:

| Rule | Matches | Tag | View |
| ---- | ------- | --- | ---- |
| `wpa-handshake` | Wi-Fi networks with WPA handshake messages 1 and 2, or 2 and 3 (possibly from different clients) | `handshake` | WPA Handshakes |
| `pmkid` | Wi-Fi networks with an RSN PMKID | `pmkid` | RSN PMKID |
| `zigbee-known-key` | 802.15.4 devices using a known or exposed key | `zigbee key` | Zigbee Known Keys |
| `adsb-government` | Aircraft owned by government agencies, police, and the military | `government` | ADS-B Government Aircraft |
| `ais-emergency` | AIS search and rescue transponders, man overboard devices, and emergency beacons | `ais emergency` | AIS Emergency |
| `uav` | Drones Kismet recognizes, on any phy | `uav` | UAV / Drones |
| `bodycam` | Body cameras, by address or name | `bodycam` | Bodycams |
| `apple-continuity` | Bluetooth devices sending Apple Continuity messages; the row highlight starts off in the web UI | `apple continuity` | Apple Continuity Devices |

A rule with the same name in a later file, such as `kismet_device_rules.txt`, replaces the shipped one; `device_rule_disable=<name>` leaves one out.

### Device baseline

After 2026-10-R1, the device details in the web UI have a *Baseline* row: *Add to baseline* marks a device as one you know, with the user tag `baseline` (its value is the time it was added), and *Remove from baseline* takes it out.  Two rules in `kismet_device_rules.txt` use it:

| Rule | Matches | View |
| ---- | ------- | ---- |
| `baseline` | Devices in the baseline | Baseline devices |
| `unknown` | Devices not in the baseline | Unknown devices |

The views change as soon as a device is added or removed, as do rules that test a device's name, when it's renamed.  To alert when a device outside the baseline appears, add a rule of your own to `kismet_device_rules.txt`, such as:

```
rule unknown-ap {
    description "Access points not in the baseline"
    when type == "Wi-Fi AP" and not has_tag("baseline")
    alert
}
```

## Loading rules

Rules are read from rules files, then from directories of rules files, then from plugins, then from `device_rule` and `device_sort` lines in the config, and then from the REST API, in that order.  The order sets which rule's color wins and how `by rule` sorts.

A rule or sort with the same name as one read earlier, from another file, replaces it in its place; the same name twice in one file is an error.  If any rule has an error, none of the rules are loaded, and the error is reported with its file and line.

After 2026-10-R1, [plugins can ship rules files](/docs/dev/plugins/plugins_manifest/#device-rules), in the order the plugins load, after the rules files and directories.  Plugin rules are built in once every plugin has loaded, so they can use the fields plugins add, and each plugin's rules are checked on their own: a plugin whose rules have an error is left out, with the error logged, and the other rules still load.  A `device_rule` line or a rule set over the API can replace a plugin's rule by name.

The device rules options are in `kismet_device_rules.conf`; as with other options, changes are best made in [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf).

{{<configopt device_rules_file path>}}
Rules files, in order.  Use `+=` in `kismet_site.conf` to add a file, or `=` to replace the list.  Without any, `%E/kismet_device_rules_highlights.txt` (the [shipped rules](#shipped-rules)) and then `%E/kismet_device_rules.txt` are read if they exist; `kismet_device_rules.txt` describes the rules language, and holds examples which are commented out.  Setting `device_rules_file` replaces both, so list them again to keep them:

```
device_rules_file=%E/kismet_device_rules_highlights.txt
device_rules_file+=%E/kismet_device_rules.txt
device_rules_file+=/etc/kismet/site.rules
```
{{</configopt>}}

{{<configopt device_rules_dir path>}}
A directory of rules files; every `*.rules` file in it is read, in natural order.

```
device_rules_dir=%E/device_rules.d
```
{{</configopt>}}

{{<configopt device_rule rule>}}
A rule on one line, written without its leading `rule`.  Long rules are better kept in a rules file; config lines can't be longer than 8190 characters.

```
device_rule=close-apple { when manuf contains "Apple" and signal > -60 tag "close" }
```
{{</configopt>}}

{{<configopt device_sort sort>}}
A sort on one line, written without its leading `sort`.

```
device_sort=loudest { by signal desc, packets desc }
```
{{</configopt>}}

{{<configopt device_rule_disable name>}}
Leave out a rule by name, such as one from a packaged rules file or a plugin.  A name which matches no rule is reported in the log once the plugins have loaded.
{{</configopt>}}

{{<configopt device_sort_disable name>}}
Leave out a sort by name, including a plugin's.
{{</configopt>}}

{{<configopt device_rules_api_save true false>}}
Rules set over the REST API are kept in memory unless saved.  When saved, they're written to `device_rules_api_file` and loaded again at startup.  By default, they aren't saved.
{{</configopt>}}

{{<configopt device_rules_api_file path>}}
Where rules set over the REST API are saved, by default `%h/.kismet/kismet_device_rules_api.txt`.
{{</configopt>}}

{{<configopt device_rules_interval seconds>}}
How often rules are checked against the devices which changed since the last check, by default every second.  Rules marked `live` are also checked on every packet which updates a device.
{{</configopt>}}

{{<configopt device_rules_full_interval checks>}}
Rules using `now` or `age()` can start or stop matching without the device changing, so every this many checks all devices are checked, by default 10.  `0` never checks unchanged devices.  After 2026-10-R1, devices which haven't changed are only checked against the rules using `now` or `age()`; the other rules keep their last result, and their webhooks with `every`, `change`, or `for` only repeat when the device changes.
{{</configopt>}}

{{<configopt device_rules_alert_backlog count>}}
The most `DEVICERULE` alerts held back by the alert rate limit at once, by default 64.  Held-back alerts are raised as the limit allows, and when the queue is full the oldest is dropped.  `0` drops held-back alerts.

The rate limit is set like other alerts, with `alert=DEVICERULE,...` in `kismet_alerts.conf`.
{{</configopt>}}

{{<configopt device_rules_jit true false>}}
Compile rules to native code where the platform allows it (64-bit x86, ARM, RISC-V, PowerPC, MIPS, s390x, and LoongArch).  Elsewhere, or when the system forbids generated code, rules run in the bytecode interpreter with the same results.  By default, rules are compiled.
{{</configopt>}}

## Rules in the web UI

The device list has a `Tags` column, which can be searched and sorted, and the device details list a device's tags first, with the rules that set them and their descriptions; rules which only make a view, with no tag, color, or alert, aren't listed there.  Views made by rules are listed with the other device views, with how many devices they hold.

Rows in the device list are highlighted by their tags, under `Settings`, `Device Highlights`.  Each tag takes the color of its rule, or a default color for the tags of the [shipped rules](#shipped-rules) and the examples, and the color can be changed there.  Tags can be dragged into priority order: a device with several tags takes the color of the highest one.

After 2026-10-R1, *Device rules* in the main menu lists the loaded rules and sorts, grouped by where they came from: each rules file, the config file, each plugin, and the rules set over the API.  Each rule shows the tags it sets and the view it makes; clicking the view opens the device list on it.  A rule can be opened to show its description, color, whether it is `live` or raises an `alert`, the file and line it came from, and its text.  *All*, *Tagging*, and *Views* list every rule, only the rules which tag devices, or only the rules which make views.  Rules which replaced an earlier rule of the same name are noted, and *Reload* reads the list again.

The legacy UI picks tag colors under `Settings`, `Rule tags`, with defaults for the tags of the shipped rules; if the colors were already changed there, the saved list is kept, and new tags need to be added to it.

## Rules in the REST API

The [device rules API](/docs/api/device_rules/) lists, checks, sets, and tests rules, and devices which match rules carry `kismet.device.base.rules`.
