---
title: "Plugins Manifest"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "plugins_manifest-7c1d5e0b9f3a4e2d8b6a1c4f0e9d2b7a"
weight: 5
toc: true
---

Every plugin has a manifest, `manifest.conf`, in its directory.  The manifest says what the plugin is and what it loads: a shared object, an external helper, web UI modules, and device rules.  A plugin with no native code, such as one which only adds to the web UI or ships device rules, needs nothing but the manifest and its files.

## Plugin directory

A plugin is a directory in one of the [plugin locations](/docs/dev/plugins/plugins/#plugin-locations), named for the plugin:

```
myplugin/
    manifest.conf          the manifest
    myplugin.so            native code, if any (object=)
    myplugin.rules         device rules, if any (devicerules=)
    httpd/                 web content, served at /plugin/myplugin/
        js/myplugin.js     web UI modules (js=, ui2=)
        css/
```

Kismet serves the `httpd/` directory at `/plugin/[plugin-directory-name]/`, so a file at `httpd/js/myplugin.js` is at `/plugin/myplugin/js/myplugin.js` on the server.

Plugins are only loaded when `allowplugins=true` is set in the Kismet config (as it is by default), and not when Kismet is started with `--disable-plugins`.

## The manifest

The manifest is written like a Kismet config file, as `key=value` lines:

| Key | Content |
| --- | ------- |
| `name` | Plugin name (required) |
| `description` | Plugin description (required) |
| `author` | Plugin author (required) |
| `version` | Plugin version (required) |
| `object` | The plugin's shared object file, in the plugin directory; a file name only, not a path |
| `httpexternal` | An [external HTTP helper](/docs/dev/plugins/plugins/#plugin-external-http-helpers) Kismet launches for the plugin; a binary name only, found on the `helper_binary_path` |
| `js` | A module for the [legacy web UI](/docs/dev/webui/), as `module_name,web/path/to/module.js` |
| `ui2` | A module for the [new web UI](/docs/dev/plugins/uiplugins_intro/), as `module_name,web/path/to/module.js`; after 2026-10-R1 |
| `devicerules` | A [device rules](#device-rules) file, relative to the plugin directory; may be given more than once; after 2026-10-R1 |

A manifest missing one of the required keys, or with an invalid value, is skipped with an error, and the plugin isn't loaded.

### Web UI modules

The paths given to `js=` and `ui2=` are web paths, relative to the root of the Kismet server, so a module in the plugin's `httpd/js/` directory is at `plugin/[plugin-directory-name]/js/...`.  Write them without a leading `/`, so the UI works behind a reverse proxy or from a sub-directory; `ui2=` refuses one.

Each UI loads only its own module, so a plugin can have one for each:

```
js=myplugin,plugin/myplugin/js/myplugin_legacy.js
ui2=myplugin,plugin/myplugin/js/myplugin.js
```

Writing the module for the new UI is covered in [Writing UI plugins](/docs/dev/plugins/uiplugins_intro/).

### Device rules

After 2026-10-R1, a plugin can ship [device rules](/docs/readme/configuring/device_rules/): rules which tag, color, sort, and collect devices into views, and raise alerts, on the server.  Each `devicerules=` line names one rules file, relative to the plugin directory:

```
devicerules=myplugin.rules
devicerules=rules/more.rules
```

The path must be inside the plugin directory: an absolute path or one with `..` in it is refused with an error.  A rules file can `include` other files and directories, relative to itself, as any [rules file](/docs/readme/configuring/device_rules/#including-other-files) can.

Plugin rules are read when the plugin loads, and built in once every plugin has loaded, so they can use fields a plugin registers.  Each plugin's rules are checked on their own: a plugin whose rules file is missing, or doesn't parse or compile, has its rules left out with an error, and the other rules still load.

Plugin rules come after the configured rules files and before the `device_rule=` lines in the config and the rules set over the API (see [loading rules](/docs/readme/configuring/device_rules/#loading-rules)).  A rule with the same name as an earlier one replaces it, so a config line or the API can replace a plugin's rule, and `device_rule_disable=` and `device_sort_disable=` can leave one out by name.  Prefix a plugin's rule and sort names with the plugin's name, so they don't replace other rules by accident.

The demo web plugin in the Kismet source (`plugin-demo-webonly`) ships a rules file:

```
# Device rules from the demo plugin; see conf/kismet_device_rules.txt for the format

rule demoweb-busy {
    description "Devices with more than 10000 packets"
    when packets > 10000
    tag "busy"
}

sort demoweb-busiest {
    by packets desc
}
```

The new web UI's *Device rules* window lists each plugin's rules under *Plugin: [name]*, and [`/plugins/all_plugins.json`](/docs/api/plugins/) lists each plugin's rules files as `kismet.plugin.device_rules`.

## Examples

A plugin which only adds to the new web UI:

```
name=Webplugin
description=Trivial web-only plugin
author=Joe Random <joerandom@random.foo>
version=1.0.0

ui2=webplugin,plugin/webplugin/js/webplugin.js
```

A plugin with C++ code and a legacy web UI module:

```
name=Codeplugin
description=Standard code-based plugin
author=Joe Random <joerandom@random.foo>
version=1.0.0

object=kismet-codeplugin.so

js=code_web_module,plugin/codeplugin/js/code_web_module.js
```

A plugin with an external binary:

```
name=ProxyDemo
description=Demo of a plugin using the external API tool to create new endpoints
author=Joe Random <joerandom@random.foo>
version=1.0.0

httpexternal=kismet_proxydemo
js=proxied_web_module,plugin/proxydemo/js/proxied_web_module.js
```

A plugin which ships device rules and a UI module to show them:

```
name=Watchlist
description=Tags devices on a watch list
author=Joe Random <joerandom@random.foo>
version=1.0.0

devicerules=watchlist.rules
ui2=watchlist,plugin/watchlist/js/watchlist.js
```
