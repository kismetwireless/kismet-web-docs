---
title: "Tabs, menus, and settings"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "uiplugins_page-d69252d8757188f9130f44b0c1f3a574"
weight: 40
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

The parts of the page around the device list, the tabs, the main menu, the stats across the top, and the settings dialog, are registries too.

## Tabs

`kismet.ui.panes` holds the tabs in the page's two tabbed areas: `'main'` (Overview, Devices, SSIDs, Alerts, Map, and so on) and `'bottom'` (Messages).

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The tab |
| `area` | `'main'` or `'bottom'` (the default) |
| `create(el, area)` | Builds the tab's content in `el`; may return `{ show(), hide(), destroy() }` |

`show()` and `hide()` are called as the user switches tabs, so a tab which isn't showing can stop its updates.  The map tab (`js/base/map.js`):

```javascript
ui.panes.add({
    id: 'map', title: 'Map', area: 'main', priority: 40,
    create(body, area) {
        // A map shows where its devices are, so censoring locations hides it
        if (kismet.censor.hidesMaps()) {
            body.append(el('p', { class: 'muted map-censored' },
                'The map is hidden while censor mode hides locations.'));
            return null;
        }
        return map.createMap(body, area);
    },
});
```

A tab of a plugin's own, which only listens for messages while it's showing:

```javascript
ui.panes.add({
    id: 'myplugin', title: 'My plugin', area: 'bottom', priority: 50,
    create(body) {
        const list = el('ul');
        body.append(list);
        let stop = null;
        return {
            show() {
                stop = kismet.eventbus.subscribe('MESSAGE', ['kismet.messagebus.message_string'], (e) =>
                    list.prepend(el('li', {}, e['kismet.messagebus.message_string'])));
            },
            hide() {
                stop?.();
                stop = null;
            },
            destroy() {
                stop?.();
            },
        };
    },
});
```

## Tables

`kismet.ui.addTable()` makes a tab with a live, scrolling table over any Kismet endpoint which pages like the [device views](/docs/api/device_views/).  It gets everything the device list has: scrolling with preloading, search, sorting, and the editor for columns, widths, and highlights.  The Wi-Fi module's SSIDs tab:

```javascript
const sg = 'dot11.ssidgroup';
ui.addTable({
    id: 'ssids', title: 'SSIDs', area: 'main', priority: 20,
    endpoint: 'phy/phy80211/ssids/views/ssids.json',
    noun: 'SSIDs',
    rowKey: (r) => r[`${sg}.hash`],
    onRowClick: (r) => openSsid(r[`${sg}.hash`]),
    alwaysFields: [`${sg}.hash`],
    defaultSort: { column: 'last_time', dir: 'desc' },
    columns: [
        { id: 'ssid', title: 'SSID', priority: 0, defaultVisible: true,
            fields: [`${sg}.ssid`, `${sg}.ssid_len`], sortField: `${sg}.ssid`,
            render: (r) => ssidText(r[`${sg}.ssid`]) },
        { id: 'crypt', title: 'Encryption', priority: 10, defaultVisible: true, width: '12em',
            fields: [`${sg}.crypt_string`], sortField: `${sg}.crypt_string`,
            render: (r) => r[`${sg}.crypt_string`] || muted('n/a') },
        // ...
    ],
});
```

Columns and highlights take the same options as the [device list's](/docs/dev/uiplugins/uiplugins_devicelist/).  Each table keeps its own registries, so another module can add to someone else's table, before or after the table itself is added:

```javascript
kismet.ui.tableColumns('ssids').add({ id: 'myplugin_note', title: 'Note', ... });
kismet.ui.tableHighlights('ssids').add({ id: 'myplugin_open', name: 'Open networks', ... });
```

## The main menu

`kismet.ui.menuItems` holds the entries in the main menu.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The entry |
| `icon` | An icon name (see [icons](/docs/dev/uiplugins/uiplugins_core/#icons)) |
| `onClick()` | What it does |
| `section` | `'about'`, `'windows'` (the default), or `'settings'` |

The menu shows About, then the windows in alphabetical order, then Settings, with lines between them; a plugin's window belongs in `'windows'`.  The GPS window's entry:

```javascript
ui.menuItems.add({
    id: 'gps', title: 'GPS', icon: 'gps',
    onClick: () => kismet.widgets.gps.openGps(),
});
```

## Windows

`kismet.widgets.dialog.dialog()` makes a window.  A modal dialog blocks the page behind it; a panel (`modal: false`) can be left open while using the page, moved by its title, and resized from its corner.

```javascript
ui.menuItems.add({
    id: 'myplugin', title: 'My plugin', icon: 'info',
    onClick() {
        const body = el('div', {}, el('p', {}, 'Loading...'));
        kismet.widgets.dialog.dialog({ title: 'My plugin', body, modal: false });
        kismet.api.get('system/status.json').then((s) =>
            ui.detailFields(body, s, [
                { title: 'Server', field: 'kismet.system.server_name' },
                { title: 'Version', field: 'kismet.system.version' },
            ]));
    },
});
```

`dialog()` returns an object with `close()`; `onClose` is called when it closes.  `kismet.widgets.dialog.confirm({ title, text, ok, cancel, danger })` asks a question and resolves to true or false.

## Ribbon stats

`kismet.ui.ribbonStats` holds the stats along the top of the page.  Users pick which to show.

| Option | |
| ------ | - |
| `id`, `title`, `priority`, `description` | The stat |
| `create(el)` | Fills `el` and keeps it up to date; may return a cleanup function |
| `defaultVisible` | Shown until the user changes the ribbon (default `true`) |

Most stats subscribe to the [event bus](/docs/dev/uiplugins/uiplugins_core/#live-events).  The device count:

```javascript
ui.ribbonStats.add({
    id: 'devices', title: 'Devices', priority: 10,
    create(body) {
        const v = valueStat('device');
        body.append(v.node);
        return eventbus.subscribe('STATISTICS', ['kismet.system.devices.count'], (e) => {
            v.value.textContent = format.count(e['kismet.system.devices.count']);
        });
    },
});
```

## Settings

`kismet.ui.settingsPanes` holds the sections of the settings dialog.

| Option | |
| ------ | - |
| `id`, `title`, `priority` | The section |
| `create(el)` | Builds the section; may return a cleanup function |
| `parent` | The id of the section this one is listed under |

There is no save button: settings take effect as they change.  Settings kept in the browser use `kismet.settings` (see [settings](/docs/dev/uiplugins/uiplugins_core/#settings)):

```javascript
ui.settingsPanes.add({
    id: 'myplugin', title: 'My plugin', priority: 100,
    create(body) {
        const box = el('input', { type: 'checkbox', checked: kismet.settings.get('myplugin.enabled', true),
            onchange: () => kismet.settings.set('myplugin.enabled', box.checked) });
        body.append(el('label', { class: 'check-item' }, box, 'Show my plugin\'s column'));
    },
});
```

## Color schemes

`kismet.ui.colorSchemes` adds color schemes to Settings > Appearance, with colors for a dark version, a light version, or both:

```javascript
ui.colorSchemes.add({
    id: 'solarized', title: 'Solarized', priority: 200,
    dark: {
        bg: '#002b36', surface: '#073642', 'surface-2': '#0a4554', border: '#16505f',
        text: '#93a1a1', muted: '#657b83', accent: '#268bd2', 'accent-text': '#ffffff',
        ok: '#859900', warn: '#b58900', error: '#dc322f',
    },
    light: { bg: '#eee8d5', surface: '#fdf6e3', text: '#586e75', accent: '#268bd2' },
});
```

Only `bg`, `surface`, `text`, and `accent` are needed; the rest come from the default Kismet scheme.  The full list of colors is at `colorSchemes` in `js/registry/ui.js`, and the built-in schemes are in `js/base/schemes.js`.  Values must be plain colors (no `url()` or `var()`); anything else is skipped with a warning in the browser console.
