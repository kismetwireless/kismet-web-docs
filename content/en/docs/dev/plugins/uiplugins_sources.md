---
title: "Data sources and channels"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_sources/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_sources-cb0525f693a10be8caab5530a9443610"
weight: 60
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

The Data sources window shows a card for each source, built from sections like the device panel.  The standard sections (`js/base/sources.js`) work for every source; a phy module adds its own for the capture drivers it knows, such as the Wi-Fi channel layout or a cell modem's DIAG capture (`js/phy/cell.js`).

## Picking sources

The data source registries pick the sources each entry applies to with either:

* `drivers: ['linuxwifi', ...]`: the capture driver types, from the `kismet.datasource.driver.type` field, or
* `match(source)`: any test of the source record.

With both, a source must have one of the drivers and pass the test.  `kismet.ui.driverOf(record)` reads the driver type from a source or an interface record.

## Source sections

`kismet.ui.sourceSections` holds the sections of a source's card.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The section |
| `drivers` or `match` | The sources it's for |
| `fields` | Rows, as [field entries](/docs/dev/plugins/uiplugins_details/#field-entries) |
| `render(source, el, ctx)` | Or draw the section yourself; called again about once a second with fresh data, so update in place |
| `open` | Start expanded (default `true`) |
| `running` | Only show it while the source is open and running |
| `when(source, type)` | A further test, given the source's `sourceTypes` entry |

A field entry's `draw(cell, value, source, state, ctx)` gets the window's `ctx` last, for controls:

| `ctx` | |
| ----- | - |
| `ctx.sources` | Every source, as last read |
| `ctx.busy(promise, text)` | Covers the card with `text` until `promise` settles |
| `ctx.refresh()` | Reads the sources again now |
| `ctx.message(text, kind)` | A note under the card's title (`'error'`, `'ok'`, or plain) |

The cell module's section for DIAG capture, shortened:

```javascript
const diagField = (s, k) => s[`${diag}.${k}`];
const isDisabled = (s) => diagField(s, 'mask_preset') === 'disabled';

ui.sourceSections.add({
    id: 'celldiag', title: 'DIAG capture', priority: 5, drivers: ['celldiag'],
    fields: [
        { title: 'Bring-up', value: (s) => (isDisabled(s) ? null : bringupText(s)),
            help: 'Opening a modem takes several steps; this says how far it got, and why it failed.' },
        { title: 'Last observation', value: (s) => (isDisabled(s) ? null :
            (diagField(s, 'last_obs_epoch') ? ago(diagField(s, 'last_obs_epoch')) : muted('None yet'))) },
        { title: 'DIAG read', value: (s) => (isDisabled(s) ? null : format.size(diagField(s, 'bytes_read') ?? 0)) },
        // ...
    ],
});
```

`kismet.ui.sourceFields` adds rows to a section someone else owns, the same way `deviceDetailFields` does for the device panel: an `id`, the `section`, a `priority`, and the field entry.

## Source types

`kismet.ui.sourceTypes` says what a kind of source is, for the window's titles and lists of interfaces.  The first match, by priority, is used.

| Option | |
| ------ | - |
| `id`, `priority`, `drivers` or `match` | The entry |
| `icon` | The icon for the card |
| `subtitle(source, ctx)` | Short text after the source's name, such as a modem's model |
| `channels: false` | Hides the standard channel section, for sources whose channels aren't radio channels |
| `interfaceTitle(intf)`, `interfaceSubtitle(intf)` | The title, and text after it, for an available interface of this driver |
| `enableForm(intf, ctx)` | Returns a node with the options asked for before enabling an interface, in place of a plain Enable button |
| `interfaces(list, ctx)` | Adds to or changes the listed interfaces, for drivers whose lister can't see a busy device |
| `sortKey(intf)` | Orders the interfaces (default: by interface name) |

The cell module's entry, shortened:

```javascript
ui.sourceTypes.add({
    id: 'cell', drivers: cellDrivers, icon: 'tower', channels: false,
    subtitle: (s) => {
        const parsed = parseLabel(sourceLabel(s));
        return parsed && (parsed.name || parsed.firmware) ? rowTitle(parsed, driverOf(s)) : captureLabel[driverOf(s)];
    },
    interfaceTitle: (intf) => rowTitle(parseLabel(intf['kismet.datasource.probed.hardware']), driverOf(intf)),
    interfaces: (list, ctx) => augmentInterfaces(list, ctx.sources),
    sortKey: (intf) => sortKey(intf['kismet.datasource.probed.interface']),
    enableForm: (intf, ctx) => enableForm(intf, ctx),
});
```

## Channel pickers

`kismet.ui.channelPickers` decides how a source's channels are shown and chosen in the standard channel section.  The first match, by priority, is used; the generic picker, a button for each channel, matches every source.  The Wi-Fi module's picker lays channels out by band (`js/phy/dot11_channels.js`).

| Option | |
| ------ | - |
| `id`, `priority`, `drivers` or `match` | The entry |
| `create(el, ctx)` | Builds the picker in `el`; returns `{ update(source, state), destroy() }` |

`state` is the section's shared hop and lock state:

| `state` | |
| ------- | - |
| `state.mode` | `'hop'` or `'lock'` |
| `state.channels` | The source's channels |
| `state.current` | The channel a locked source is on |
| `state.selected` | A `Set` of the channels to hop on |
| `state.pending` | True while a change is waiting to be sent |
| `state.toggle(channel)`, `state.lock(channel)`, `state.setSelected(list)` | Change them |

The generic picker, shortened:

```javascript
ui.channelPickers.add({
    id: 'generic', priority: 1000,
    create(node) {
        const buttons = new Map();
        const grid = el('div', { class: 'ds-chan-grid' });
        node.append(grid);
        let st = null;
        return {
            update(s, state) {
                st = state;
                if (state.channels.join('\n') !== grid._key) {
                    grid._key = state.channels.join('\n');
                    buttons.clear();
                    grid.replaceChildren(...state.channels.map((c) => {
                        const b = el('button', { type: 'button', class: 'ds-chan', onclick: () => st.toggle(c) }, c);
                        buttons.set(c, b);
                        return b;
                    }));
                }
                for (const [c, b] of buttons) {
                    b.classList.toggle('on', state.mode === 'hop' ? state.selected.has(c) : c === state.current);
                    b.classList.toggle('pending', state.pending);
                }
            },
        };
    },
});
```

## Channel names

Frequencies are shown by channel name wherever the UI can, such as in the channel coverage window, from `kismet.ui.channelNames`: one entry for each phy which names its channels.

| Option | |
| ------ | - |
| `id` | The phy name, such as `'IEEE802.11'` |
| `title` | A short name, such as `'Wi-Fi'` |
| `name(khz)` | The channel at a frequency, or null when it isn't one of this phy's |
| `frequency(channel)` | Optional: the frequency of a channel, in kHz, or null |

Where channel plans overlap, as Wi-Fi and Bluetooth LE do at 2.4 GHz, the lowest priority names the frequency and the others are listed with it.  The Bluetooth LE module names its 40 channels:

```javascript
// BLE channels: 37, 38, and 39 advertise; 0-36 carry connections
const bleFrequency = (channel) => {
    const n = Number(channel);
    if (!Number.isInteger(n) || n < 0 || n > 39)
        return null;
    const mhz = n === 37 ? 2402 : n === 38 ? 2426 : n === 39 ? 2480 :
        (n <= 10 ? 2404 + n * 2 : 2428 + (n - 11) * 2);
    return mhz * 1000;
};

ui.channelNames.add({ id: 'BTLE', title: 'BLE', priority: 10, name: bleChannel, frequency: bleFrequency });
```

### Source channels

Data sources report their channels in their own terms (`6`, `36HT40+`, `5W6e`, `37`), so `kismet.ui.sourceChannels` says how to turn a source's channels into frequencies.

| Option | |
| ------ | - |
| `id`, `priority` | The entry |
| `match(source)` | Whether it applies to a source record |
| `frequency(channel)` | The channel's frequency, in kHz, or null |
| `span(channel)` | Optional: `{ low, high }` in kHz, for a wide channel |

```javascript
ui.sourceChannels.add({
    id: 'btle',
    match: (src) => /nrf|cc2540|sniffle|ble|wch/i.test(src['kismet.datasource.driver.type'] ?? ''),
    frequency: bleFrequency,
});
```

Channels which are plain frequencies (`2412`, `433.92MHz`) work without an entry.
