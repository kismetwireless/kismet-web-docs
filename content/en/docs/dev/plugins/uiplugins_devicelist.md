---
title: "The device list"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_devicelist/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_devicelist-b8850f887803a9468bed1c824eaef507"
weight: 20
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

The device list is built from the columns, icons, and row highlights modules register.  It asks the server only for the fields the visible columns, icon, and highlights list, so each of them says what it reads in `fields` (see [fields](/docs/dev/plugins/uiplugins_intro/#fields)).

## Columns

`kismet.ui.deviceColumns` holds the columns users can pick from.

| Option | |
| ------ | - |
| `id` | Unique id, also saved in the user's column settings |
| `title` | Header text |
| `description` | Longer text shown in the column picker |
| `fields` | The fields the column reads |
| `sortField` | The field path the server sorts on; leave it out for a column which can't be sorted |
| `render(row)` | Returns a string or a DOM node for the cell |
| `group` | Heading in the column picker, such as `'Wi-Fi'` (default `'General'`) |
| `width` | Starting CSS width, such as `'8em'`; users can resize it |
| `align` | `'left'`, `'right'`, or `'center'` |
| `defaultVisible` | Shown until the user changes their columns |

The 802.15.4 module (`js/phy/802154.js`) adds a column for the kind of network a device is on:

```javascript
const d = '802154.device';

ui.deviceColumns.add({
    id: '802154_network', title: '802.15.4 network', priority: 110, group: '802.15.4', width: '8em',
    description: 'Zigbee, Zigbee Green Power, Thread, or 6LoWPAN',
    fields: [[`${d}/${d}.network_type`, 'network_type']],
    sortField: `${d}/${d}.network_type`,
    render: (row) => row.network_type || '',
});
```

### Columns in the search box

The [search box](/docs/readme/webui/webui_filters/) knows every column by its `id` (also without its group as a prefix, so `wifi_ssid` in the `Wi-Fi` group is also `ssid`) and its title, and filters on its `sortField`.  These options say how:

| Option | |
| ------ | - |
| `filterKind` | What `sortField` holds: `'text'`, `'number'`, `'time'` (a timestamp), `'mac'`, or `'duration'` (a length of time) |
| `filterConvert` | For a duration, a function from seconds to the field's units, such as `kismet.ui.durationIn.us` (seconds if not given) |
| `filterWide` | Field paths the search box uses for the name with a `*`, such as `ssid*` |
| `filterEmpty` | The value, or list of values, the field holds when it has no data; filters on the column skip those devices |
| `filterPresent` | A field which is 0 or missing when the column has no data; filters on the column skip those devices |
| `filterNames` | More names for the column in the search box |

The kind decides which comparisons are allowed, and how a value is read: durations such as `1d` on a `'time'` field compare how long ago it was, and on a `'duration'` field are converted to the field's units.  Without `filterKind`, a field is a number or time when the server's short names say so (fields ending in `_time` are times), and text otherwise.

The Wi-Fi module's uptime column holds the beacon timestamp, in microseconds, which is 0 for devices which never sent one:

```javascript
ui.deviceColumns.add({
    id: 'wifi_uptime', title: 'Uptime', priority: 102, group: 'Wi-Fi', width: '7em', align: 'right',
    description: 'Access point uptime, from its beacon timestamp',
    fields: ['dot11.device/dot11.device.bss_timestamp'],
    sortField: 'dot11.device/dot11.device.bss_timestamp',
    // uptime > 1d; the beacon timestamp counts microseconds
    filterKind: 'duration',
    filterConvert: ui.durationIn.us,
    // Clients and APs that never sent a timestamp have 0
    filterEmpty: 0,
    render: (row) => (row['dot11.device.bss_timestamp'] ?
        format.duration(row['dot11.device.bss_timestamp'] / 1e6) : ''),
});
```

and its QBSS usage column is only meaningful for access points which send QBSS, so it names the flag which says they do, and gives it more names:

```javascript
ui.deviceColumns.add({
    id: 'wifi_qbss_usage', title: 'QBSS usage', priority: 42, group: 'Wi-Fi', width: '7em',
    fields: [[`${beacon}/dot11.advertisedssid.dot11e_qbss`, 'qbss'],
        [`${beacon}/dot11.advertisedssid.dot11e_channel_utilization_perc`, 'qbss_usage']],
    sortField: `${beacon}/dot11.advertisedssid.dot11e_channel_utilization_perc`,
    filterKind: 'number',
    filterNames: ['qbss', 'utilization', 'usage'],
    filterPresent: `${beacon}/dot11.advertisedssid.dot11e_qbss`,
    render: (row) => (row.qbss ? kismet.widgets.cellgraphs.fillBar(row.qbss_usage) : ''),
});
```

A filter on a field with `filterEmpty` or `filterPresent` never matches devices without data for it, negated or not.  A name given by several columns, search fields, or filter hints matches any of their fields; the server's short names (`name`, `type`, `mac`, and the others in the [device rules](/docs/readme/configuring/device_rules/#fields)) always keep their meaning.

## Row icons

`kismet.ui.deviceIcons` picks the icon at the start of each row.  The first icon, by priority, whose `match(row)` returns a node is used:

```javascript
ui.deviceIcons.add({
    id: '802154', priority: 0,
    fields: ['kismet.device.base.phyname'],
    match: (row) => (row['kismet.device.base.phyname'] === '802.15.4' ?
        icons.icon('zigbee', '802.15.4') : null),
});
```

Icons are from `kismet.icons`, which a module can add to (see [icons](/docs/dev/plugins/uiplugins_core/#icons)).

## Row highlights

`kismet.ui.rowHighlights` colors the rows which match.  Users turn each highlight on and off, and pick its color, under Settings > Device Highlights.

| Option | |
| ------ | - |
| `id`, `name`, `description` | The highlight, as listed in settings |
| `fields`, `match(row)` | Whether a row is highlighted |
| `defaultColor`, `defaultEnabled` | Its starting color and state |
| `category` | `'tag'`, `'phy'`, or `''`, to group it in settings |
| `color(row)` | Optional: color each row itself, instead of in one color the user picks |

The ADS-B module highlights government aircraft:

```javascript
ui.rowHighlights.add({
    id: 'adsb_government', name: 'ADS-B government', priority: 50,
    description: 'Government and related aircraft',
    defaultColor: '#ffb3b3', defaultEnabled: true,
    fields: ['kismet.device.base.phyname',
        [`${icao}/adsb.icao.owner`, 'adsb_owner'],
        [`${adsb}/${adsb}.icao`, 'adsb_icao']],
    match: (row) => isAdsb(row) && isGovernment(row.adsb_owner, row.adsb_icao),
});
```

Highlights which depend only on device data are often better written as [device rules](/docs/readme/configuring/device_rules/) with a `color`, which the server evaluates and the UI shows as tag highlights.

### Phy colors

`kismet.ui.phyColors` gives the default row color for every device of a phy, which users can turn on and change in settings:

```javascript
ui.phyColors.add({ id: 'BTLE', title: 'BTLE', color: '#99e9f2' });
```

The `id` is the phy name as the server reports it.

## Search fields

`kismet.ui.searchFields` lists fields the device list always fetches, whatever columns are showing, so that a plain search matches them.  The server only searches the fields a request asks for, so phys add the fields people search for here.  The `id` is also a name for all of the fields in [filters](/docs/readme/webui/webui_filters/).

```javascript
// Searches match a vessel's MMSI, name, and callsign
ui.searchFields.add({
    id: 'ais', description: 'AIS MMSI, name, and callsign',
    fields: [`${ais}/${ais}.mmsi`, `${ais}/${ais}.name`, `${ais}/${ais}.callsign`],
    filterKind: { [`${ais}/${ais}.mmsi`]: 'number' },
});
```

`filterKind`, `filterConvert`, `filterEmpty`, and `filterPresent` work as they do for columns, either one for all the fields or as `{ path: value }`; `filterNames` gives more names.

## Filter hints

`kismet.ui.filterHints` names fields for the search box's filters which aren't columns or search fields, such as the details a phy shows in the device panel.  Hints are only for filters: their fields are never fetched for the list.

| Option | |
| ------ | - |
| `id` | Unique id |
| `names` | What the search box calls the fields (default `[id]`) |
| `fields` | The fields |
| `phy` | The phy, as the server names it, whose fields these are; the hint is left out when the server doesn't have the phy |
| `filterKind`, `filterConvert`, `filterEmpty`, `filterPresent` | As for search fields |

The AIS module names the vessel details:

```javascript
const filterHint = (id, names, fields, more = {}) =>
    ui.filterHints.add({ id, phy: 'AIS', names, fields, ...more });

filterHint('ais_mmsi', ['mmsi'], [`${ais}/${ais}.mmsi`], { filterKind: 'number', filterEmpty: 0 });
filterHint('ais_ship_name', ['ship_name', 'vessel'], [`${ais}/${ais}.name`], { filterEmpty: '' });
filterHint('ais_callsign', ['callsign'], [`${ais}/${ais}.callsign`], { filterEmpty: '' });
// Speed over ground, in knots
filterHint('ais_sog', ['sog', 'knots'], [`${ais}/${ais}.sog`], { filterKind: 'number' });
```

The ADS-B module also names a `callsign`, so `callsign ~ N1` matches both aircraft and ships.  A name shared this way should mean the same thing for each phy.

## Device views

The server's [device views](/docs/api/device_views/) (all devices, each phy, each data source, Wi-Fi access points, device rule views, and so on) are found on their own and listed in the device list's view picker.  `kismet.ui.deviceViews` gives one a better title, or a group:

```javascript
ui.deviceViews.add({ id: 'phydot11_accesspoints', title: 'Wi-Fi access points', group: 'Wi-Fi', priority: -100 });
```

The `id` is the server's view id.
