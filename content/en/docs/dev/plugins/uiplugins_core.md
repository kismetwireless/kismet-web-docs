---
title: "The kismet object"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
aliases: ["/docs/dev/uiplugins/uiplugins_core/"]
menu:
  docs:
    parent: ""
    identifier: "uiplugins_core-ba0a19d29455e524eb2cc147a44a20c9"
weight: 80
toc: true
---

Added: `after 2026-10-R1`

{{< alert icon="⚠️" context="warning" >}}
The UI plugin interface is changing quickly in the nightly builds, and may change before it is in a Kismet release.
{{< /alert >}}

Besides the registries in `kismet.ui`, the `kismet` object a module's `register()` gets holds what modules use to talk to the server and draw their own UI.  Each part is a module in `http_data/js/core/` or `http_data/js/widgets/`, and the comments at the top of each file describe it in full.

## The server

`kismet.api` talks to the Kismet server over HTTP.  Paths are relative to the server root, so the UI works behind a reverse proxy, from a sub-directory, or (in the installed app) with another server; the login, or the app's API key, is added for you.

```javascript
// GET a JSON endpoint
const status = await kismet.api.get('system/status.json');

// POST a command body, and form variables such as paging options
const page = await kismet.api.post('devices/views/all/devices.json',
    { fields: ['kismet.device.base.macaddr', 'kismet.device.base.name'] },
    { page: 0, length: 50 });

// A .cmd endpoint, which answers in plain text
await kismet.api.command('datasource/by-uuid/<uuid>/set_channel.cmd', { channel: '6' });

// Read a value out of a record by path
const signal = kismet.api.field(device, 'kismet.device.base.signal/kismet.common.signal.last_signal');
```

Requests which fail throw a `kismet.api.ApiError`, with the HTTP status and the server's message.  `kismet.api.url(path)` makes the full URL of a path on the server, for links and images.

## Live events

`kismet.eventbus` is one websocket to the server's [event bus](/docs/api/eventbus/), shared by every part of the UI.  `subscribe(topic, fields, fn)` asks for only the fields given (or `null` for the whole event), and returns a function to unsubscribe:

```javascript
const stop = kismet.eventbus.subscribe('TIMESTAMP', ['kismet.system.timestamp.sec'],
    (event) => console.log(event['kismet.system.timestamp.sec']));

// later
stop();
```

Many parts of the UI can subscribe to the same topic: the server gets one subscription for each topic, with the fields everyone wants, and the UI reconnects and subscribes again on its own when the connection drops.  The UI itself uses `TIMESTAMP`, `STATISTICS`, `PACKETCHAIN_STATS`, `MESSAGE`, `ALERT`, `GPS_LOCATION`, and `BATTERY`; the server's [event bus documentation](/docs/api/eventbus/) lists the rest.

`kismet.eventbus.onState(fn)` calls `fn(connected)` when the connection goes up or down.

## Time and history

`kismet.clock.now()` is the server's time in seconds, which may not match the browser's clock (or, replaying a capture file, today's date).  Graphs of per-second data should use it.

Kismet keeps rolling history of many values (packets, devices, signal) as RRDs.  `kismet.rrd` reads them:

```javascript
// Oldest first, ending now: 60 one-second values, 60 one-minute, or 24 one-hour
const lastMinute = kismet.rrd.history(rrd, kismet.clock.now(), 'minute');
const lastDay = kismet.rrd.history(rrd, kismet.clock.now(), 'day');

// The latest value
const perSecond = kismet.rrd.latest(rrd, kismet.clock.now());
```

## Settings

`kismet.settings` keeps settings in the browser, as JSON:

```javascript
const mode = kismet.settings.get('myplugin.mode', 'simple');
kismet.settings.set('myplugin.mode', 'detailed');
const stop = kismet.settings.watch('myplugin.mode', (value) => redraw(value));
```

Prefix a plugin's settings with its name.  When the browser can't store them (in a private window, say), settings are kept for the session only.

## Drawing

`kismet.dom.el(tag, props, ...children)` builds DOM elements.  Strings become text, never HTML, so data from the server can't inject markup:

```javascript
const { el } = kismet.dom;

const row = el('div', { class: ['card', active && 'active'], onclick: () => open(key) },
    'Name: ', el('b', {}, name));
```

`class` takes a string or a list (false values are skipped), `on...` props add event listeners, and `null` children are skipped.  `kismet.dom.append(node, ...children)` and `kismet.dom.replace(node, ...children)` work the same way on an existing node.

`kismet.format` turns values into text the way the rest of the UI does, following the user's units:

| | |
| - | - |
| `format.time(sec)`, `format.clock(sec)`, `format.ago(sec)` | A timestamp, a time of day, and how long ago |
| `format.duration(sec)` | A length of time |
| `format.count(n)`, `format.size(bytes)` | A count, and a size in bytes |
| `format.frequency(khz)`, `format.signal(dbm)` | A frequency, and a signal level |
| `format.speed(kmh)`, `format.height(m)`, `format.distance(m)` | In metric or imperial units, as the user chose |

### Shortening text

`kismet.shorten` shortens text to fit the space it's shown in, the way the user picks under *Settings*, *Appearance* (after 2026-10-R1):

```javascript
const { shorten } = kismet;
shorten.fitText(cell, name);          // shows name in cell, shortened if it doesn't fit; true when shortened
shorten.fitTexts(cells, names);       // the same for cells of one width and font, measured once
const whole = shorten.fullText(cell); // the text it was given, for a tooltip
const stop = shorten.watch((how) => redraw(how));
```

`shorten.shorten(text, fits)` gives the longest shortened text for which `fits(s)` is true, for drawing other than into an element; `shorten.mode()` is `'middle'` or `'end'`.  In censor mode, `fitText` and `fitTexts` censor the text before they shorten it, since the page's censoring only recognizes whole names; `fullText` returns the censored text.  A device list column only needs `shorten: true`.

### Themes

Colors come from CSS variables (`--bg`, `--surface`, `--text`, `--muted`, `--accent`, `--ok`, `--warn`, `--error`, and others), so plain DOM follows the theme on its own.  Code which draws on a canvas reads them with `kismet.theme.themeColor('--accent')`, and redraws on `kismet.theme.onChange(fn)`, which returns a function to stop.

### Icons

`kismet.icons.icon(name, title)` makes an icon; `title` is its tooltip and accessible name.  A module can add its own, as the inside of a 24 × 24 SVG drawn with strokes:

```javascript
icons.define('mesh', '<circle cx="12" cy="5" r="2.2"/><circle cx="5" cy="17" r="2.2"/>' +
    '<circle cx="19" cy="17" r="2.2"/><path d="M10.9 6.9L6.1 15M13.1 6.9l4.8 8.1M7.2 17h9.6"/>');
```

Icon markup is trusted, fixed text: never build it from server data.

### Widgets

`kismet.widgets` has the building blocks the rest of the UI is made of, for modules which draw their own UI: `dialog`, `sparkline`, `historyGraph`, `charts`, `listTable`, `datatable`, `devicetable`, `map`, `loading`, and others.  The built-in modules are the best examples of using them.

## Censor mode

Censor mode hides MAC addresses, names, and locations on the page, for screenshots and streams.  Data read from the server is censored on the page without anything more from a module, since the page's text is rewritten as it's drawn.  Two things need a module's help:

* Text drawn on a canvas, which the page can't rewrite, should go through `kismet.censor.text(s)`.
* Text shortened by the module itself should be censored first, with `kismet.censor.text(s)`, or shortened with `kismet.shorten`, which does it.
* A view which shows locations should check `kismet.censor.hidesMaps()`, as the map tab does.
