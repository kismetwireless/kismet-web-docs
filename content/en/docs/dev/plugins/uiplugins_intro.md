---
title: "Writing UI plugins"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_intro/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_intro-a57cdafb601b414cea8f4481e30eecc0"
weight: 10
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The new Kismet UI, and its plugin interface, are changing quickly in the nightly builds.  The registries and options described here may change before they are in a Kismet release.  Come talk to us on the [Kismet Discord server](https://discord.gg/5N4ME9a) if you're writing a UI plugin!
{{< /alert >}}

The [new Kismet web UI](/docs/readme/webui/webui_intro/) is built from plain JavaScript modules, with no build step.  Everything in it, from the device list columns to the Wi-Fi details, is added by a module through the same interface a plugin uses: the built-in parts of the UI (in `http_data/js/base/`) and each phy's module (in `http_data/js/phy/`) are the best examples of how to write one.

## A UI module

A UI module is an ES module which exports a `register()` function.  The UI calls it once, as the page loads, with the `kismet` object, which holds everything a module uses:

```javascript
export function register(kismet) {
    kismet.ui.deviceColumns.add({
        id: 'myplugin_channel', title: 'Channel', priority: 40,
        fields: ['kismet.device.base.channel'],
        sortField: 'kismet.device.base.channel',
        render: (row) => row['kismet.device.base.channel'],
    });
}
```

`register()` may be `async`.  Modules load in parallel, and one which fails to load (or throws from `register()`) is logged in the browser console and skipped without stopping the others.  The About entry in the main menu lists the modules which loaded.

A module can `import` its own other files with relative paths, as the Wi-Fi module does with `dot11_channels.js`, but should reach the rest of the UI only through the `kismet` object.

## Installing a UI plugin

A UI plugin is a [web-only plugin](/docs/dev/plugins/plugins/#plugin-static-web-content): a directory in one of the [plugin locations](/docs/dev/plugins/plugins/#plugin-locations), with a `manifest.conf` and its files under `httpd/`, which Kismet serves at `/plugin/[plugin-directory-name]/`.

The new UI loads the module named by the `ui2=` key in the manifest, as `module_name,path`, where the path is relative to the Kismet server root (no leading `/`):

```
name=Myplugin
description=Adds a channel column to the new web UI
author=Joe Random <joerandom@random.foo>
version=1.0.0

ui2=myplugin,plugin/myplugin/js/myplugin.js
```

with the module in `httpd/js/myplugin.js` in the plugin directory.  The other manifest keys, such as `devicerules=` for device rules the plugin ships, are in [Plugins Manifest](/docs/dev/plugins/plugins_manifest/).  A plugin can have both a `js=` module for the [legacy UI](/docs/dev/webui/) and a `ui2=` module for the new one; each UI loads only its own.

The server lists the modules to load at `/dynamic.json`.  Entries with a `ui2` path are loaded by the new UI; legacy entries for the phys the new UI already has a module for load that module instead, and any others are skipped and shown in About.

When the UI is connected to a different Kismet server than the one it was loaded from (as an installed app can be), that server's plugin modules only load once *Run its UI plugins* is checked for it in the Servers window, since a plugin's code runs with the app's access to every server.

## Registries

Almost everything a module adds goes into a **registry**: a named list, such as `kismet.ui.deviceColumns` or `kismet.ui.menuItems`.  Every registry works the same way:

| Call | Does |
| ---- | ---- |
| `add({ id, priority, ... })` | Adds an entry, or replaces the entry with the same `id` |
| `remove(id)` | Removes an entry |
| `get(id)` | Returns an entry |
| `list()` | Returns the entries sorted by `priority`, lowest first |
| `watch(fn)` | Calls `fn()` when entries are added or removed; returns a function to stop |

Every entry needs an `id`, and each registry lists the other options it needs; an entry missing one is logged to the console and not added.  Because the lists are sorted by priority and watched by the parts of the page that show them, it doesn't matter which order modules load in, or whether a plugin's module loads after the page is built.

Replacing an entry by its `id` is how a plugin changes something built in: adding a device column with the `id` of a built-in column replaces it.

The comments at the top of each file in `http_data/js/registry/` are the full reference for each registry's options.

| Registry | Page |
| -------- | ---- |
| `deviceColumns`, `deviceIcons`, `rowHighlights`, `phyColors`, `searchFields`, `filterHints`, `deviceViews` | [The device list](/docs/dev/plugins/uiplugins_devicelist/) |
| `deviceDetails`, `deviceDetailFields` | [Device details](/docs/dev/plugins/uiplugins_details/) |
| `panes`, `menuItems`, `ribbonStats`, `settingsPanes`, `colorSchemes`, and `addTable` | [Tabs, menus, and settings](/docs/dev/plugins/uiplugins_page/) |
| `dashboardCards`, `mapSources` | [Overview and map](/docs/dev/plugins/uiplugins_overview_map/) |
| `sourceSections`, `sourceFields`, `sourceTypes`, `channelPickers`, `channelNames`, `sourceChannels` | [Data sources and channels](/docs/dev/plugins/uiplugins_sources/) |
| `insightRelations`, `linkKinds`, `insightFindings`, `insightViews` | [Insights](/docs/dev/plugins/uiplugins_insights/) |

Talking to the server, live events, settings, themes, and the drawing helpers are on [the kismet object](/docs/dev/plugins/uiplugins_core/).

## Fields

The UI asks the server only for the fields it needs, so anything which reads device data says which fields it reads, as a `fields` list.  A field is a path into the Kismet record, or a `[path, name]` pair to give it a shorter name:

| In `fields` | In the row |
| ----------- | ---------- |
| `'kismet.device.base.channel'` | `row['kismet.device.base.channel']` |
| `'dot11.device/dot11.device.last_bssid'` | `row['dot11.device.last_bssid']` (a path is named by its last part) |
| `['kismet.device.base.signal/kismet.common.signal.last_signal', 'signal']` | `row.signal` |

Every row also has `row.key`, the device key.  Code given a whole device record (the device details, for instance) can read any path with `kismet.api.field(device, path)`.

## Trying a module

`tools/webui_devserver.mjs`, in the Kismet source, serves the UI from a source tree and passes everything else to a running Kismet server:

```bash
node tools/webui_devserver.mjs --target http://localhost:2501 --port 2600
```

Open `http://127.0.0.1:2600/` and the UI loads from `http_data/` in the tree; a module edited there shows up on reload.  The UI object is also available in the browser console as `window.kismet2`, for trying out registry calls.
