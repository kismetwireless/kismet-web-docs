---
title: "Overview and map"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-18T09:00:00-05:00
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

The Overview tab is a grid of cards from `kismet.ui.dashboardCards`.  Users arrange, resize, hide, and add back cards with *Edit layout*; the layout is kept per browser.  After 2026-10-R1 the user can keep several dashboards, each with its own layout and card settings; a card is made again for each dashboard it's on.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The card |
| `description` | Optional: shown as a tooltip on the card's entry in the *Add a card* list (after 2026-10-R1) |
| `w`, `h` | Its starting size on the 12-column grid, in columns and rows (3 × 5 if not given) |
| `place` | Optional: `'top'` puts the card at the top left when it's first shown, even in a layout the user has already arranged; otherwise it takes the first free spot |
| `defaultHidden` | Optional: `true` leaves the card off a dashboard until the user adds it |
| `fill` | Optional: `true` for a card whose content fills whatever height it has, such as a map; stacked on a phone, it's given a height of its own |
| `needs` | The shared data it reads (below) |
| `loading` | The outline shown until that data arrives: one or a list of `'stat'`, `'tabs'`, `'graph'`, `'histogram'`, `'bars'`, `'list'`, `'table'`, `'donut'`, `'text'` (the default), stacked top to bottom |
| `settings` | Optional: the card's own settings (below), as a list or a function returning one |
| `create(body, { actions, settings, dashboard })` | Builds the card; returns `{ update(data), show(), hide(), destroy() }`, all optional |
| `forget(dashboard)` | Optional: called when the user deletes a dashboard, so the card can drop what it kept for that one (after 2026-10-R1) |
| `onClick(actions)` | Optional: called when the card is clicked (anywhere but its own buttons and links) |

`actions.showTab(id)` switches to a tab (a pane id, or the id given to `addTable`), and `actions.showDevices(viewId)` to the device list on a view.  `dashboard` is the id of the dashboard the card is on, for a card that keeps state of its own in each one: the map card keeps its view in the setting `overview.map.view.<dashboard>`, and removes it in `forget(dashboard)`.  `show()` and `hide()` are called as the card comes on and off screen: when the Overview tab is shown or hidden, the user switches dashboards, or the card is added or hidden; a card that refreshes on its own timer can stop while it's hidden.

### Card settings

A card's settings are kept for each dashboard.  While arranging, a card with settings has a gear button; the card is made again when one changes, and `settings.get(id)` in `create()` gives the value on this dashboard, or the default.

| Field | |
| ----- | - |
| `id`, `title` | The setting |
| `type` | `'bool'` (a checkbox) or `'choice'` (a list) |
| `options` | For a choice: `[{ id, title }]` |
| `default` | The value until the user picks one |
| `group` | Optional: a heading the setting is listed under |

Give `settings` as a function when the choices come and go, as the map card does with the kinds of device and overlays plugins add.  The Devices, Active devices, and New devices cards have one setting, whether to draw the graph:

```javascript
const graphSetting = [{ id: 'graph', title: 'Show the graph', type: 'bool', default: true }];

ui.dashboardCards.add({
    id: 'active', title: 'Active devices', priority: 10, w: 3, h: 6, needs: ['channels'],
    settings: graphSetting,
    create(body, { settings }) {
        const now = stat('heard in the last 30 seconds');
        const graph = settings.get('graph') ? historyGraph({ type: 'line', unit: 'devices', height: null }) : null;
        body.append(...[now.node, graph?.node].filter(Boolean));
        // ...
    },
});
```

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
    id: 'devices', title: 'Devices', loading: ['stat', 'tabs', 'graph'], priority: 0, w: 3, h: 6,
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
    id: 'phys', title: 'Devices by type of radio', loading: 'bars', priority: 30, w: 4, h: 6, needs: ['phys'],
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

The map tab draws the devices which have a place on it, in layers from `kismet.ui.mapSources`; each layer has a checkbox in the map's list.  The Overview's *Map* card draws the same layers and overlays, each with a switch in the card's settings instead.  A layer reads a device view every couple of seconds while the map is showing (and every 15 seconds while it's hidden, to keep paths going).

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

### Map overlays

Added: `after 2026-10-R1`

A plugin can draw shapes of its own over the map, such as a survey area or a route, from `kismet.ui.mapOverlays`.  Overlays are drawn above the map background and under the devices, and each one has a checkbox in the map's list, with a button which zooms the map to it.

| Option | |
| ------ | - |
| `id`, `title`, `priority`, `defaultVisible` | The overlay |
| `icon` | The icon for the checkbox (default `'target'`) |
| `shapes()` | Returns the shapes to draw; called whenever the overlay is drawn |
| `watch(redraw)` | Optional: call `redraw()` when the shapes change; returns a function which stops watching |
| `legend()` | Optional: a node shown on the map while the overlay is visible |

Points are `[lon, lat]`, as in device locations.  A shape is one of:

| Shape | |
| ----- | - |
| `{ type: 'polygon', points: [[lon, lat], ...] }` | A closed area, at least 3 points |
| `{ type: 'line', points: [[lon, lat], ...] }` | A line, at least 2 points |
| `{ type: 'rect', bounds: [[lon, lat], [lon, lat]] }` | A rectangle, from opposite corners |
| `{ type: 'circle', center: [lon, lat], radius }` | A circle, with the radius in meters |
| `{ type: 'marker', center: [lon, lat], icon }` | An icon |

Any shape may also have `color` and `fillColor` (CSS colors, including the theme's, such as `var(--ok)`), `weight` (the line width in pixels), `dash` (such as `'4 4'`), `fill` (polygons, rectangles and circles are filled unless it's `false`), `fillOpacity`, `label` (text shown when the pointer is over it), and `className` (extra classes, of letters, digits, `-` and `_`).  Shapes which aren't valid, such as points out of range, are skipped; an overlay draws at most 1000 shapes, of up to 10000 points each.

`kismet.widgets.map.zoomToOverlay(id)` zooms the map to an overlay; show the map tab with it, and a map which isn't drawn yet zooms there when it is:

```javascript
kismet.widgets.panes.showPane('map');
kismet.widgets.map.zoomToOverlay('quad');
```

A box which turns red when Kismet is outside it:

```javascript
let quad = { s: 10, n: 11, w: -21, e: -20 };
let inside = null;
const redraws = new Set();

ui.mapOverlays.add({
    id: 'quad', title: 'Survey quad',
    shapes: () => [{
        type: 'rect', bounds: [[quad.w, quad.s], [quad.e, quad.n]],
        color: inside === false ? 'var(--error)' : 'var(--ok)', weight: 3, fillOpacity: 0.05,
        label: 'Survey quad',
    }],
    watch(redraw) {
        redraws.add(redraw);
        return () => redraws.delete(redraw);
    },
});

kismet.eventbus.subscribe('GPS_LOCATION', ['kismet.common.location.geopoint'], (e) => {
    const [lon, lat] = e['kismet.common.location.geopoint'] ?? [];
    const now = lat >= quad.s && lat <= quad.n && lon >= quad.w && lon <= quad.e;
    if (now !== inside) {
        inside = now;
        redraws.forEach((fn) => fn());
    }
});
```
