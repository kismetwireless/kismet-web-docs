---
title: "Insights"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_insights/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_insights-4f1d7cc3b9099e2040963d7004325cfc"
weight: 70
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

The Insights tab draws a graph of how devices relate, their activity over time, and a list of unusual things.  The base code only knows devices; each phy module adds what it knows about how its devices relate (a Wi-Fi client and its access point, a network name and the devices which advertise or probe for it) and what it finds unusual.  The Wi-Fi insights are in `js/phy/dot11_insights.js`, and the location tracker ones in `js/phy/btle_trackers.js`.

## Relations

`kismet.ui.insightRelations` builds the graph.  `relate(rec, g)` is called for each device record read, with the fields each relation asks for in `fields`, and `after(g)` once after every record, for links which need them all.

| `g` | |
| --- | - |
| `g.device(key)` | The node for a device, by its key |
| `g.mac(mac)` | The node for a device by MAC, if it's in the window |
| `g.thing(id, { label, kind, title })` | A node which isn't a device, such as a network name; the same `id` gives the same node |
| `g.link(a, b, { kind, weight, title })` | A line between two nodes; `kind` is a `linkKinds` id |
| `g.flag(node, text)` | Marks a node as unusual, drawn with a ring |
| `g.role(node, role)` | `'ap'`, `'client'`, `'probe'`, `'bridge'`, or `'other'` |
| `g.same(a, b)` | Two device nodes are one device, such as an access point's addresses for each network and band |
| `g.drop(node)` | Takes a node and its links out again |

The tracker module labels location trackers, and flags the ones which say they're away from their owner:

```javascript
ui.insightRelations.add({
    id: 'trackers', fields: insightFields,
    relate(rec, g) {
        const tr = trackerOf(rec, 'ins');
        if (!tr)
            return;
        const n = g.device(rec['kismet.device.base.key']);
        if (!n)
            return;
        n.tracker = tr;
        n.label = trackerName(tr);
        if (tr.separated)
            g.flag(n, 'separated tracker');
    },
});
```

## Link kinds

`kismet.ui.linkKinds` lets a phy draw its own kinds of line.

| Option | |
| ------ | - |
| `id`, `title` | The kind, and its name in the legend |
| `style` | `'solid'` (the default), `'dashed'`, or `'dotted'` |
| `color` | A theme variable, such as `'--accent'` |
| `length` | The spring length, in pixels |
| `live` | True to show packets moving along it |
| `names` | True when the node at its far end names the device, so the device needs no label of its own |
| `groupTitle` | What several devices at one end are called (`'clients'`), for the Flow and Access points views |

```javascript
ui.linkKinds.add({
    id: 'myplugin_paired', title: 'Paired with', style: 'dashed', color: '--accent', length: 80,
});
```

## Findings

`kismet.ui.insightFindings` adds to the list of unusual things, and to the rings in the graph.  `find(model)` returns a list of findings:

| Finding | |
| ------- | - |
| `id` | Unique, and stable from one read to the next |
| `severity` | `'high'`, `'medium'`, or `'info'` |
| `title`, `text` | What was found, and an explanation |
| `devices`, `things` | The device keys, and thing ids, it's about |

`model` has the device records read (`model.records`), the graph built from them (`model.graph`), the server time (`model.now`), and Kismet's alerts in the window (`model.alerts`).  `alerts` names the Kismet alerts a finding explains, so they aren't also listed as plain alerts.

The tracker module, shortened:

```javascript
ui.insightFindings.add({
    id: 'trackers',
    fields: insightFields,
    alerts: ['TRACKERFOLLOW'],
    find({ records }) {
        const out = [];
        for (const rec of records) {
            const tr = trackerOf(rec, 'ins');
            if (!tr?.separated)
                continue;
            const key = rec['kismet.device.base.key'];
            if (tr.followTime >= 1800 && tr.followLocations >= 3)
                out.push({
                    id: `tracker-follow:${key}`, severity: 'high',
                    title: `A ${trackerName(tr)} away from its owner is moving with you`,
                    text: `It has been seen for ${format.duration(tr.followTime)} at ` +
                        `${tr.followLocations} places at least 100 m apart.`,
                    devices: [key],
                });
        }
        return out;
    },
});
```

## Views

`kismet.ui.insightViews` adds whole views of their own, shown as more tabs after the built-in ones.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The view |
| `create(el, ctx)` | Builds the view; returns `{ update(model), show(), hide(), destroy() }` |

`update()` gets the same model as findings after each read, every few seconds while the view is showing; a view can also read what it needs itself.  `ctx.openDevice(key)` opens a device's details, `ctx.api` is `kismet.api`, and `ctx.showing()` says whether the view is showing.

The Wi-Fi module's *Airspace* view (`js/phy/dot11_airspace.js`) draws how busy each channel is on a canvas.  It reads the channel data itself while it's showing, rather than using the device model, and redraws when the window or theme changes:

```javascript
ui.insightViews.add({
    id: 'dot11-airspace', title: 'Airspace', priority: 10,
    create(node, ctx) {
        const canvas = el('canvas', { class: 'as-canvas' });
        const scroller = el('div', { class: 'as-scroll' }, canvas);
        node.append(scroller);

        const resize = new ResizeObserver(() => draw());
        resize.observe(scroller);
        const offTheme = theme.onChange(() => draw());
        // ...
        return {
            show() {
                read();
            },
            hide() {
                clearTimeout(timer);
            },
            destroy() {
                clearTimeout(timer);
                resize.disconnect();
                offTheme();
            },
        };
    },
});
```
