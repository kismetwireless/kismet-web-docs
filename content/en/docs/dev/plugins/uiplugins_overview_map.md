---
title: "Overview and map"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_overview_map/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_overview_map-3db7cb6e0ec8311a73482289b0df483e"
weight: 50
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

## Overview cards

The Overview tab is a grid of cards from `kismet.ui.dashboardCards`.  Users arrange, resize, hide, and add back cards with *Edit layout*; the layout is kept per browser.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The card |
| `w`, `h` | Its starting size on the 12-column grid, in columns and rows (3 × 5 if not given) |
| `needs` | The shared data it reads (below) |
| `loading` | The outline shown until that data arrives: one or a list of `'stat'`, `'tabs'`, `'graph'`, `'histogram'`, `'bars'`, `'list'`, `'table'`, `'donut'`, `'text'` (the default), stacked top to bottom |
| `create(body, { actions })` | Builds the card; returns `{ update(data), destroy() }` |
| `onClick(actions)` | Optional: called when the card is clicked (anywhere but its own buttons and links) |

`actions.showTab(id)` switches to a tab (a pane id, or the id given to `addTable`), and `actions.showDevices(viewId)` to the device list on a view.

### Shared data

The cards share their data: each refresh asks the server once for each kind of data any card needs, and hands every card the same results, so a plugin's card costs the server nothing extra when it reads what the built-in cards already do.  Nothing is fetched while the tab is hidden.

| In `needs` | `data.<name>` holds |
| ---------- | ------------------- |
| `status` | `/system/status`: the device count and memory, with their RRDs |
| `packets` | `/packetchain/packet_stats`: packet rates |
| `phys` | `/phy/all_phys`: devices and packets for each phy |
| `channels` | `/channels/channels`: the frequency map, with its RRDs |
| `alerts` | The last hour of alerts |
| `sources` | The data sources |
| `talkers` | Devices heard in the last 15 seconds, with their packets per second over the last minute |
| `devices` | Every device heard in the chosen time window, with a short set of fields, for counting |

`data.now` is the server's time, and `data.window` the time window the user picked (in seconds, or 0 for all devices).  `update()` is first called once all of a card's `needs` have arrived.

The Devices card, from `js/base/overview.js`:

```javascript
ui.dashboardCards.add({
    id: 'devices', title: 'Devices', loading: ['stat', 'tabs', 'graph'], priority: 0, w: 2, h: 5,
    needs: ['status'],
    create(body) {
        const total = stat('devices tracked');
        const tabs = spanTabs('devices', () => draw());
        const graph = historyGraph({ type: 'line', unit: 'devices', height: null });
        body.append(total.node, tabs.node, graph.node);
        let last = null;
        function draw() {
            if (!last?.status)
                return;
            const r = last.status['kismet.system.devices.rrd'];
            graph.draw(rrd.history(r, last.now, tabs.span), spanLabels[tabs.span]);
        }
        return {
            update(data) {
                last = data;
                total.update(format.count(data.status?.['kismet.system.devices.count'] ?? 0));
                draw();
            },
        };
    },
});
```

The *Devices by type of radio* card shows a bar for each phy, and opens the device list on a phy's view when one is clicked:

```javascript
const { barList, series } = kismet.widgets.charts;

ui.dashboardCards.add({
    id: 'phys', title: 'Devices by type of radio', loading: 'bars', priority: 30, w: 3, h: 5, needs: ['phys'],
    create(body, { actions }) {
        const bars = barList({ onPick: (item) => actions.showDevices(`phy-${item.id}`) });
        body.append(bars.node);
        return {
            update(data) {
                bars.update((data.phys ?? []).filter((p) => p['kismet.phy.device_count'] > 0).map((p, i) => ({
                    id: p['kismet.phy.phy_name'], label: p['kismet.phy.phy_name'],
                    value: p['kismet.phy.device_count'],
                    title: `${format.count(p['kismet.phy.packet_count'])} packets`, color: series(i),
                })));
            },
        };
    },
});
```

`kismet.widgets.charts` has `barList()`, `donut()`, `stat()`, `presenceStrip()`, `timeline()`, and `eventTimeline()`; `kismet.widgets.historyGraph()` draws RRD history, and `kismet.widgets.sparkline()` a small line.  All of them draw in the theme's colors.

## The map

The map tab draws the devices which have a place on it, in layers from `kismet.ui.mapSources`; each layer has a checkbox in the map's list.  A layer reads a device view every couple of seconds while the map is showing (and every 15 seconds while it's hidden, to keep paths going).

What to read:

| Option | |
| ------ | - |
| `view` | The device view (default `'all'`) |
| `regex` | Optional `[[field, regex], ...]` to narrow the view |
| `fields` | Extra `[path, name]` pairs the functions below read |
| `maxAge` | Seconds a device stays on the map after it's last heard (default 600) |
| `interval` | Optional milliseconds between reads, for layers which are slow to query |

Where to draw a device:

| Option | |
| ------ | - |
| `position` | `'reported'` (the default): where the device says it is; `'heard'`: where Kismet last heard it; `'average'`: the middle of where Kismet has heard it, the best guess for a device which doesn't move; `'reported-or-heard'`; or `fn(dev)` returning `[lon, lat]` or null |
| `paths` | Draw the path a reported position leaves (default `true`) |

How it looks:

| Option | |
| ------ | - |
| `id`, `title`, `priority`, `defaultVisible` | The layer; a device in more than one layer is drawn by the one with the lowest priority |
| `icon` | An icon name, or `fn(dev)` returning one |
| `layerIcon` | The icon for the checkbox, when `icon` is a function |
| `label(dev)`, `detail(dev)` | The device's label, and short text about it |
| `color(dev)` | A CSS color |
| `heading(dev)` | Degrees to point the icon, or null |
| `legend()` | Optional: a node shown on the map while the layer is visible |

`dev` has `key`, `name`, `phy`, `type`, `last_time`, the positions `rep`, `heard`, and `avg` (each `[lon, lat]` or null), `rep_alt`, `rep_speed`, and `rep_heading`, and the layer's own `fields`.

Bluetooth LE devices don't report where they are, so they're drawn where Kismet heard them, and are off until asked for:

```javascript
ui.mapSources.add({
    id: 'btle', title: 'Bluetooth LE', priority: 61, icon: 'bluetooth', view: 'phy-BTLE',
    position: 'average', defaultVisible: false,
    color: () => 'hsl(185 65% 50%)',
});
```

Ships report their position, and the icon depends on the kind of station and points where a moving ship is heading:

```javascript
const underway = (d) => (d.sog ?? 0) > 0.5 && !['Base Station', 'AtoN'].includes(d.ais_class);

ui.mapSources.add({
    id: 'ais', title: 'Vessels (AIS)', priority: 10, view: 'phy-AIS', maxAge: 1800, legacy: true,
    layerIcon: 'ship',
    fields: [[`${ais}/${ais}.name`, 'shipname'], [`${ais}/${ais}.class`, 'ais_class'],
        [`${ais}/${ais}.sog`, 'sog']],
    icon: (d) => {
        if (d.ais_class === 'Base Station')
            return 'tower';
        if (d.ais_class === 'AtoN')
            return 'anchor';
        if (emergency.includes(d.ais_class))
            return 'lifebuoy';
        return underway(d) ? 'vessel' : 'ship';
    },
    label: (d) => String(d.shipname ?? '').trim() || d.name,
    detail: (d) => [d.ais_class, underway(d) ? `${d.sog.toFixed(1)} kn` : null].filter(Boolean).join(', '),
    color: (d) => (emergency.includes(d.ais_class) ? 'var(--error)' : 'var(--ok)'),
    heading: (d) => (underway(d) ? d.rep_heading || 0 : null),
});
```

`legacy: true` is for servers older than 2026-10, where the device location is the position the device reported (ADS-B and AIS).
