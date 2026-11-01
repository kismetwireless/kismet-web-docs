---
title: "Device details"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_details/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_details-4cec2880fe9b1de8bdf79d8c1538fbea"
weight: 30
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

Clicking a device opens its details panel, which is made of sections registered by modules: the common details from `js/base/details.js`, and a section from each phy for its own devices.

## Sections

`kismet.ui.deviceDetails` holds the sections.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The section |
| `match(device)` | Whether the section applies to a device |
| `fields` | The section's rows, as a list of field entries (below) |
| `render(device, el)` | Or draw the section yourself; called again with fresh data each time the device changes |
| `open` | Start expanded (default `true`); the user's choice is remembered |

A section has `fields`, `render`, or both; `render` draws into its own space below the fields.  The device is the full device record from the server, so a section can read any field with `kismet.api.field(device, path)`.

The 802.15.4 section, from `js/phy/802154.js`:

```javascript
const d = '802154.device';
const hex = (digits) => (v) => `0x${v.toString(16).padStart(digits, '0')}`;
// PAN IDs and short addresses of 0xffff mean "not known"
const hexOrUnknown = (digits) => (v) => (v === 0xffff ? ui.muted('Unknown') : hex(digits)(v));

ui.deviceDetails.add({
    id: '802154', title: '802.15.4', priority: 5,
    match: (device) => device['kismet.device.base.phyname'] === '802.15.4' && d in device,
    fields: [
        { title: 'Network', field: `${d}/${d}.network_type`, hideEmpty: true, empty: ui.muted('Unknown'),
            help: 'What the frames carry: a Zigbee network header or beacon, Zigbee Green Power, ' +
                'Thread (its beacon, or MLE over 6LoWPAN), or other 6LoWPAN traffic.' },
        { title: 'PAN ID', field: `${d}/${d}.pan_id`, format: hexOrUnknown(4) },
        { title: 'Short address', field: `${d}/${d}.short_addr`, format: hexOrUnknown(4) },
        { title: 'Zigbee stack profile', field: `${d}/${d}.stack_profile`, hideZero: true,
            format: (v) => ({ 1: 'Zigbee', 2: 'Zigbee PRO' }[v] ?? `Profile ${v}`) },
    ],
});
```

## Field entries

The rows of a section are drawn by `kismet.ui.detailFields(el, record, entries)`, which modules can also use to show any record as a labelled list (the About dialog does).  Calling it again with fresh data updates the rows in place, so graphs, open groups, and half-typed edits are kept.

A field entry:

| Option | |
| ------ | - |
| `title` | The label |
| `field` | A path into the record |
| `value(rec, device)` | Work out the value instead of reading a field |
| `format(value, rec, device)` | Turn the value into text or a DOM node (default: as it is) |
| `show(value, rec, device)` | Return false to leave the row out |
| `hideEmpty`, `hideZero` | Leave the row out when the value is `''`, or 0 (or missing) |
| `empty` | What to show for a missing value; without it, a missing value leaves the row out |
| `help` | A longer explanation, shown from the (i) next to the label |
| `wide` | Use the whole width, without a label column, for graphs and tables |
| `draw(cell, value, rec, state, device)` | Draw into the cell yourself; the cell and `state` object are kept between updates |
| `id` | A stable name for the row (default: its title or field) |

`kismet.ui.muted(text)` makes the quieter text used for "Unknown" and similar.

A value can be worked out from several fields, as the AIS section does for a ship's size:

```javascript
{
    title: 'Dimensions',
    help: 'Overall length and beam, from the distances the ship reports between its AIS antenna ' +
        'and the bow, stern, port, and starboard sides.',
    value: (dev) => {
        const d = dev[ais] ?? {};
        const length = (d[`${ais}.dim_bow`] ?? 0) + (d[`${ais}.dim_stern`] ?? 0);
        const beam = (d[`${ais}.dim_port`] ?? 0) + (d[`${ais}.dim_starboard`] ?? 0);
        return length > 0 ? `${format.distance(length)} × ${format.distance(beam)}` : null;
    },
},
```

and `format` can return DOM, such as a link:

```javascript
{
    title: 'MMSI', field: `${ais}/${ais}.mmsi`,
    format: (v) => el('span', {}, `${v} `,
        link(`https://www.marinetraffic.com/en/ais/details/ships/mmsi:${encodeURIComponent(v)}`,
            'View on MarineTraffic')),
},
```

A row with `draw` keeps what it builds in `state`, so a graph is made once and only redrawn; this one is from the data sources window, whose sections use the same field entries:

```javascript
{ id: 'graph', title: 'Packets', wide: true, field: 'kismet.datasource.packets_rrd',
    draw: (cell, v, s, state) => {
        if (!state.graph) {
            state.graph = historyGraph({ type: 'bar', unit: 'packets/s',
                title: 'Packets per second, last minute', height: '5.5rem', minBar: true });
            cell.replaceChildren(state.graph.node);
        }
        state.graph.draw(rrd.history(v, clock.now()).slice(0, -1), ['-60s', 'now']);
    } },
```

### Groups and lists

Entries can also be groups of rows, or one set of rows for each item in a list or map in the record:

```javascript
// A group, with a title and its own rows
{ group: 'Location', show: (dev) => hasFix(dev), fields: [ ... ] },

// The rows for each advertised SSID; the fields are read from each item
{ list: 'dot11.device/dot11.device.advertised_ssid_map',
  itemTitle: (ssid) => ssid['dot11.advertisedssid.ssid'],
  fields: [ { title: 'Channel', field: 'dot11.advertisedssid.channel' }, ... ] },
```

A list can use `items(rec)` instead of a path, and `empty` for the text to show when there are no items.  Inside a list, functions get the list item as `rec` and the whole device after it.

## Adding to another section

`kismet.ui.deviceDetailFields` adds rows to a section another module owns, such as a line in the Wi-Fi section:

```javascript
ui.deviceDetailFields.add({
    id: 'myplugin_wps_note', section: 'dot11', priority: 15,
    title: 'Notes', field: 'myplugin.device/myplugin.note', hideEmpty: true,
});
```

A section's own rows have priorities 0, 10, 20, and so on, in the order it lists them, so priority 15 lands between its second and third rows.
