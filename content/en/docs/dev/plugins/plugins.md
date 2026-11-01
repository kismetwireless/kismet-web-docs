---
title: "Plugins"
description: ""
lead: ""
date: 2022-11-11T14:04:57-05:00
lastmod: 2022-11-11T14:04:57-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "plugins-6ad66a12075981cb07bdfc2fc3711346"
weight: 1
toc: true
---

Kismet can load additional code dynamically at runtime in the form of a plugin.

Plugins are a double-edged sword: In their current implementation, plugins are full first-class citizens in the Kismet ecosystem;  a plugin can perform any action Kismet native code can perform, and are given a direct reference to the internal Kismet module system.

## C++ plugin code

Kismet has long supported C++ plugins which load as `.so` shared object files.

While still supported, this functionality has rarely if ever been used for third party plugins throughout decades of Kismet development.

At this point, the C++ plugin API is likely not fully functional, and probably shouldn't be used for new plugins.

## UI plugins

UI plugins have seen much more community interest, and are being expanded.

After the `2026-10-R1` release, Kismet has been gaining a new UI, with new capabilities, as well as new dynamic server-side back-end options for defining views, new columns in the UI, and more.  The plugin registry and documentation will be updated to reflect the new capabilities, but until the UI stabilizes, consider some of the options to likely be in flux.  Please, come chat with us on the [Kismet Discord server](https://discord.gg/5N4ME9a) if you'd like insight and input into the new UI plugin process!

The new UI's plugin interface is described in [UI Plugins](/docs/dev/plugins/uiplugins_intro/).

## Plugin locations
Plugins can be installed into one of two locations:

* System-wide plugins are installed into `[datadir]/kismet/plugins/` where `[datadir]` is the parameter passed to `./configure --datadir=...`.  It defaults to `/usr/local/`.

* Per-user plugins are installed into the users home directory under `~/.kismet/plugins/`


## Plugin static web content
Plugins are mapped into the Kismet webserver under `/plugin/[plugin-directory-name]/` path.  Plugins can add arbitrary content in this directory, but it is strongly recommended that they follow the following convention:

* `[prefix]/plugins/[name]/httpd/js/` - Javascript files
* `[prefix]/plugins/[name]/httpd/css/` - CSS files

To register a JS module for automatic loading (for instance, to interact with the normal Kismet web UI and add new tabs, details, etc), a plugin must either:

* Register the module with the `kis_httpd_registry::register_js(...)` system
* Define a [plugin manifest](/docs/dev/plugins/plugins_manifest/) stored in `[prefix]/plugins/[name]/manifest.conf`

## Plugin external HTTP helpers
An external HTTP helper plugin communicates with Kismet over the external API IPC channel.  The binary is launched by Kismet.  External API plugins can add new endpoints to the Kismet server and communicate with Kismet via the IPC channel and the Kismet web API.

## Plugin manifests
Every plugin has a `manifest.conf` in its directory, which names the plugin and what it loads: native code, an external helper, web UI modules, and device rules.  The keys and examples are in [Plugins Manifest](/docs/dev/plugins/plugins_manifest/).
