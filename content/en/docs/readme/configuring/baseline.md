---
title: "Device baseline"
description: ""
lead: ""
date: 2026-11-14T12:00:00-05:00
lastmod: 2026-11-14T12:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "baseline-6d2a9f41c8e35b70a4d1e8c2f9b6a053"
weight: 45
toc: true
---

Added: `after 2026-10-R1`

The baseline is the devices you know: your own access points and clients, the neighbors' networks, the sensors and meters in range.  Devices in the baseline are left out of the *Default* device view, so it shows what's new.

A device is in the baseline when it has the user tag `baseline`.  You can add devices by hand from the web UI, and Kismet can build the baseline for you with *baseline filters*: [device rules](/docs/readme/configuring/device_rules/) which run on their own schedule and add devices to the baseline, or take them out, by what Kismet has seen of them.  Baseline filters are written in the device rules language and run inside Kismet; they're off until you turn them on.

The baseline rules and filters are in `kismet_baseline_rules.txt`, and their options in `kismet_baseline_rules.conf`; as with other options, changes are best made in [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf).

## The baseline in the web UI

The device details have a *Baseline* row.  *Add to baseline* puts a device in the baseline, and *Remove from baseline* takes it out; the row says when the device was added, and whether you or a baseline filter added it.  A device taken out says who took it out, and baseline filters won't add it back until you add it again by hand.

Four rules in `kismet_baseline_rules.txt` make the baseline views:

| Rule | Matches | Does |
| ---- | ------- | ---- |
| `baseline` | Devices in the baseline | Collects them in the *Baseline devices* view |
| `unknown` | Devices not in the baseline | Collects them in the *Unknown devices* view |
| `baseline-hide` | Devices in the baseline | Leaves them out of the *Default* view |
| `baseline-highlight` | Devices in the baseline | Tags them `baseline`, with a light blue row color |

The device list opens on *Default*, which leaves the baseline out; *All devices* and *Baseline devices* still list it.  To keep the baseline in *Default*, switch `baseline-hide` off in the [device rules window](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), or leave it out with `device_rule_disable=baseline-hide`.  The row color can be changed or switched off under *Settings*, *Device Highlights*, or the rule left out with `device_rule_disable=baseline-highlight`.

The views change as soon as a device is added or removed.

The *Device rules* window has a *Baseline* tab listing the baseline filters, with what each one does, how often it runs, and how many devices it has added or removed.  Opening a filter shows when it last ran and what its runs changed.

## Baseline filters

A baseline filter is written like a rule, with `baseline` in place of `rule`:

```
baseline <name> {
    when <condition>
    add | remove
    description "<text>"
    every <time>
    ephemeral
    expire <time>
}
```

| Statement | |
| --------- | - |
| `when` | The condition, in the [device rules language](/docs/readme/configuring/device_rules/#writing-rules). |
| `add` or `remove` | Put the devices which match in the baseline, or take them out.  One of the two is required. |
| `description` | What the filter is for, shown in the web UI. |
| `every <time>` | How often the filter runs, from 10 seconds to 7 days; by default every minute.  Each run reads every device, so use the longest time that works (see [cost](#cost)). |
| `ephemeral` | The tags the filter sets last until Kismet restarts, and are never saved. |
| `expire <time>` | For `add` filters, how long a device stays in the baseline, from a minute to 365 days.  When it's up, the device leaves the baseline, and this filter doesn't add it back until Kismet restarts. |

Baseline filters only run with `device_rules_baseline=true`.  They can be put in any rules file, or written on one line in the config with `device_baseline=`; one with the name of a shipped filter replaces it.  A filter can be switched off in the device rules window like any rule, or left out with `device_rule_disable=<name>`.

A filter first runs one `every` after the rules load, and then every `every`.  Filters only change the baseline: they don't tag devices, make views, or raise alerts of their own.  In each run, devices are removed first and then added, and each filter changes at most `device_rules_baseline_max_changes` devices; the rest wait for its next run.  Each filter's changes are written to the database together.  The console reports what each run changed.

### Tags

Baseline filters, and adding and removing devices by hand, keep these user tags:

| Tag | Value |
| --- | ----- |
| `baseline` | The time the device was added; present while it's in the baseline |
| `baseline-by` | The filter which added the device, or `user` when it was added by hand |
| `baseline-hold` | The filter which took the device out, or `user` when it was taken out by hand |
| `baseline-expired` | The `add` filter whose `expire` ran out; kept until Kismet restarts |

A device with `baseline-hold` is held out: `add` filters leave it alone until it's added by hand, which clears the hold.  Taking a device out by hand holds it too, so a filter doesn't add it straight back.

`remove` filters take out devices added by hand as well.  The console names each one, up to 10 a run, so a device you added which starts raising alerts doesn't leave quietly.

The tags can be used in rules of your own, with `has_tag()` and `tag_time()`.  For example, to watch the devices a filter took out:

```
rule taken-out {
    description "Devices the alerts filter took out of the baseline"
    when has_tag("baseline-hold") and not has_tag("baseline")
    view "Taken out of the baseline"
}
```

### Ephemeral tags

A filter marked `ephemeral` sets tags that are kept in memory only.  They count the same in rules, views, and the web UI, but they're never written to the database, so they're gone when Kismet restarts.  This keeps a filter which adds passing devices, such as `one-off-random`, from filling the database with addresses which never come back.

An ephemeral tag never replaces a saved one: a filter can't make a device you added by hand ephemeral.  Adding a device by hand which a filter added ephemerally saves it.

### Shipped filters

`kismet_baseline_rules.txt` ships six filters.  They all run once `device_rules_baseline=true` is set; leave out any you don't want with `device_rule_disable=<name>`.

| Filter | Does | Every |
| ------ | ---- | ----- |
| `one-off-random` | Adds random addresses seen briefly once, until restart, for a day | 5m |
| `startup` | Adds fixed addresses here since Kismet started | 10m |
| `alerts` | Takes out devices which sent an alert | 10s |
| `steady` | Adds fixed addresses heard most of the day or most days | 15m |
| `clients-of-baseline` | Adds fixed clients of access points in the baseline | 15m |
| `fixed-sensors` | Adds sensors, meters, and home automation heard on two days | 1h |

**one-off-random** adds random addresses which came and went within a couple of minutes, sent fewer than 50 packets, and aren't [linked](/docs/readme/configuring/randomized_macs/) to another address: a phone scanning for networks, or a passing device.  It waits 15 minutes after the address was last heard.  Its tags are ephemeral and expire after a day, so these addresses leave *Unknown devices* without filling the database.

```
baseline one-off-random {
    when random_address and not linked and age(last_time) > 15m and
        last_time - first_time < 2m and packets < 50
    every 5m
    add
    ephemeral
    expire 1d
}
```

**startup** adds devices with fixed addresses which were heard within 5 minutes of Kismet starting and are still being heard an hour later.  Waiting the hour keeps the rush of devices heard at startup, some only passing, from all going in.

```
baseline startup {
    when uptime > 1h and first_time < start_time + 5m and age(last_time) < 10m and
        not random_address
    every 10m
    add
}
```

**alerts** takes out devices which sent an alert of low severity or above.  Denial of service alerts don't count: they name the address they claim to come from, and a spoofed deauthentication flood claims to come from the access point it attacks, which would take the victim out of the baseline.  System alerts aren't about a device.  The classes left out are set with `device_rules_alert_ignore_classes`.

```
baseline alerts {
    when own_alerts > 0 and own_alert_severity >= 5
    every 10s
    remove
}
```

**steady** adds devices with fixed addresses heard in 18 or more of the last 24 hours, or on 4 or more of the last 7 days.

```
baseline steady {
    when not random_address and (hours_active >= 18 or days_active >= 4)
    every 15m
    add
}
```

**clients-of-baseline** adds Wi-Fi clients with fixed addresses whose access point is in the baseline, once they've been heard in two hours of the last day.  An access point is its own last BSSID, so this also adds nothing new for access points already in the baseline.

```
baseline clients-of-baseline {
    when in_baseline(dot11.device/dot11.device.last_bssid) and not random_address and
        hours_active >= 2
    every 15m
    add
}
```

**fixed-sensors** adds weather and other sensors, utility meters, and Zigbee and Z-Wave devices heard on two days or more.

```
baseline fixed-sensors {
    when phy in ["RFSENSOR", "METER", "802.15.4", "Z-Wave"] and days_active >= 2
    every 1h
    add
}
```

`hours_active` and `days_active` only count the time Kismet has been running, so `steady`, `clients-of-baseline`, and `fixed-sensors` start adding devices after Kismet has been up for a few hours or days.  `days_active` is only recorded while `device_rules_baseline=true`.

### Writing your own

Baseline filters use the whole [device rules language](/docs/readme/configuring/device_rules/#values-and-operators), including the terms made for them:

| Term | |
| ---- | - |
| `start_time`, `uptime` | When Kismet started, and how long it has been running |
| `hours_active` | Hours of the last 24 the device was heard, 0 to 24 |
| `days_active` | Days of the last 7 the device was heard, 0 to 7 |
| `tag_time("<tag>")` | The number in a user tag, such as the time in `baseline` |
| `in_baseline(<field>)` | The device whose MAC address is in the field is in the baseline |
| `random_address`, `linked` | The device's address is random; it's linked to another address of the same device |
| `own_alerts`, `own_alert_severity` | Alerts the device sent, outside the ignored classes, and the highest severity among them |

Some examples:

```
# Your own network, by name, as soon as it's seen
baseline home-network {
    description "Access points of the home network"
    when display_type == "Wi-Fi AP" and
        dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid == "home-network"
    every 1m
    add
}

# Devices in the baseline which haven't been heard for a week
baseline gone {
    description "Devices not heard for a week"
    when has_tag("baseline") and age(last_time) > 7d
    every 1h
    remove
}

# BTLE devices with fixed addresses heard every day for a week, kept for 30 days
baseline btle-regulars {
    description "BTLE devices heard every day"
    when phy == "BTLE" and not random_address and days_active >= 7
    every 1h
    add
    expire 30d
}
```

A `remove` filter which matches devices you added by hand takes them out each time it runs, even after you add them again; to keep one in, make the filter's condition leave it out, for instance with a tag of your own.

On one line in the config, a filter is written without its leading `baseline`:

```
device_baseline=quiet-sensors { when phy == "RFSENSOR" and days_active >= 3 every 1h add }
```

Filters can be checked before loading them with the [device rules API](/docs/api/device_rules/)'s `check.cmd`.

### Cost

Each run of a filter reads every device.  The filters due at the same time share one pass over the devices, and an idle filter costs nothing between runs.  As a guide, a pass over 100,000 devices with six filters due takes about 80 ms on a fast desktop, and roughly half a second on a Raspberry Pi 4.  On large or slow systems, keep `every` long: most filters don't need to run more often than every few minutes.

## Options

{{<configopt device_rules_baseline true false>}}
Run the baseline filters, and record the days each device is heard for `days_active`.  Off by default: the filters change which devices are in the baseline on their own.  Recording days adds a small record to each device.
{{</configopt>}}

{{<configopt device_rules_baseline_max_changes count>}}
The most devices one baseline filter adds or removes in one run, from 1 to 100000; by default 1000.  The rest wait for its next run.  This keeps a filter written too broadly from changing the whole baseline at once, and bounds the database writes of a run.
{{</configopt>}}

{{<configopt device_rules_alert_ignore_classes classes>}}
Alert classes, comma separated, which don't count toward a device's `own_alerts` and `own_alert_severity`; by default `DENIAL,SYSTEM`.  Classes match in any case.
{{</configopt>}}

{{<configopt device_baseline filter>}}
A baseline filter on one line, written without its leading `baseline`.  A filter with the name of one from a rules file replaces it.
{{</configopt>}}

`kismet_baseline_rules.txt` is read after `kismet_device_rules.txt` when `device_rules_file` isn't set.  Setting [`device_rules_file`](/docs/readme/configuring/device_rules/#loading-rules) replaces the default files, so list `%E/kismet_baseline_rules.txt` in it to keep the baseline views and filters.

## In the REST API

The baseline is the user tag `baseline`, set and removed with the [device tag endpoints](/docs/api/devices/); adding and removing devices this way keeps `baseline-by` and `baseline-hold` as the web UI does.

Baseline filters are listed with the rules in the [device rules API](/docs/api/device_rules/), with what they do, their schedule, and what their runs have changed.
