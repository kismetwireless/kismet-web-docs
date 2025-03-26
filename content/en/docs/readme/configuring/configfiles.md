---
title: "Configuration Files"
description: ""
lead: ""
date: 2022-08-23T15:56:38-04:00
lastmod: 2022-08-23T15:56:38-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "configfiles-c9e050a466b05f6dbe3380e9e9c1a9b6"
weight: 30
toc: true
---

## Configuring Kismet

Kismet is primarily configured through a set of text files wth a simple `option=value` format.

By default these are installed into `/usr/local/etc/` when compiling from source, and `/etc/kismet/` when installing from the Kismet packages.

The config files are broken into several smaller files for readability:

| File | Description |
| ---- | ----------- |
| kismet.conf | The primary config file which loads all the other configuration files.  `kismet.conf` also contains the system-wide options. |
| kismet_alerts.conf | Alert / WIDS configuration, which includes rules for alert matching, rate limits on alerts, and other IDS/problem detection options |
| kismet_httpd.conf | Webserver configuration |
| kismet_memory.conf | Memory consumption and system tuning options.  Typically unneeded, but if you have a massive number of devices or an extremely resource-limited system, how Kismet uses memory can be tuned here. |
| kismet_storage.conf | Kismet persistent storage configuration |
| kismet_logging.conf | Log file options and filters |
| kismet_filter.conf | Packet and device filter configuration |
| kismet_uav.conf | Parsing rules for detecting UAV / Drones or similar devices; compiled from the `kismet_uav.yaml` file |
| kismet_80211.conf | Configuration settings for Wi-Fi (IEEE80211) specific options |
| kismet_site.conf | Optional configuration override; Kismet will load any options in the `kismet_site.conf` file last and they will take precedence over all other configs. |

### Configuration Format

Configuration files are plain text.

Any lines beginning with a `#` are comments, and are ignored.

Typically, example or default values are provided in comments; to enable or change that option, uncomment the line and set it accordingly - or better yet, put it in your `kismet_site.conf` file, details below.

Configuration options all take the form of:

   `option=value`

Some configuration options support repeated definitions, such as the
`source` option which defines a Kismet datasource:

   `source=wlan0`

   `source=wlan1`

Kismet supports importing config files.  This is used by Kismet itself to
split the config files into more readable versions, but can also be used
for including custom options.

{{<configopt include "/path/to/file">}}
Include a config file; this file is parsed immediately, and the file **must** exist or Kismet will exit with an error.
{{</configopt>}}


{{<configopt opt_include "/path/to/file">}}
Include an **optional** config file.  If this file does not exist, Kismet will generate a warning, but continue working.
{{</configopt>}}


{{<configopt opt_override "/path/to/file">}}
Include an **optional OVERRIDE** config file.  This is a special file which is loaded at the **end** of all other configuration.  Any configuration options found in an override file **replace all other instances of those configurations**.  This is a very powerful mechanism for provisioning multiple Kismet servers or making a config which survives an upgrade and update to the newest configuration files when running from git.
{{</configopt>}}

### Customizing configs with kismet_site.conf

If you often upgrade from source (or nightly packages) you may find replacing changes in your config files becomes tedious.  To simplify the upgrade process, or building a Kismet install for automatic placement on sensors, changes can be placed in the `kismet_site.conf` config file.

This file is specified as an OVERRIDE FILE.  Any options placed in kismet_site.conf will REPLACE ANY OPTIONS OF THE SAME NAME.  Options in this file take precedence over any other options.

Kismet will look for an optional override file in the default configuration directory (`/usr/local/etc` for source and `/etc/kismet/` for packages, by default) named `kismet_site.conf`.

This mechanism allows a site configuration to override any default config options, while not making changes to any configuration file installed by Kismet.  This allows new installations of Kismet to replace the config files with impunity while preserving a custom configuration.

Typical uses of this file might include changing the http data directory, defining sources and memory options, forcing or disabling logging, and so on; a `kismet_site.conf` file might look like:

```
server_name=Some server
server_description=Building 2 floor 3

gps=serial:device=/dev/ttyACM0,name=laptop

remote_capture_listen=0.0.0.0
remote_capture_port=3501

source=wlan1:name=SomeServerWlan1
source=wlan2:name=SomeServerWlan2
```

### Configuration override and flavors

Sometimes you may want to maintain multiple configurations for Kismet, for example with different sources, server names, or logging options.

This can be easily accomplished with override files and the `--override` option to Kismet.

Passing `--override {name}` to Kismet will automatically load `kismet_{name}.conf` from the Kismet configuration directory, as an override after all other files (by default the configuration directory is `/usr/local/etc` when compiling from source, or `/etc/kismet` when installing from packages).

For example, creating `/etc/kismet/kismet_rtl.conf`:

```
server_name=Kismet RTL

source=rtl433-0

log_title=KismetRtl433
```

and launching Kismet with:

```bash
kismet --override rtl
```

would capture only from the first RTL-SDR device as a RTL433 capture, and name the logs KismetRtl433-foo.

Alternately, a complete path to an override file can be given:

```bash
kismet --override=/home/foo/some_config.conf
```

Files loaded with the `--override` option will take precedence over all other configuration options, including any changes in `kismet_site.conf`.

#### Appending in an override

In certain, relatively rare, instances, it might be required to *append* a value in an override instead of completely replacing it - such as adding the `wiglecsv` log type in the wardrive overlay.  Using the `+=` assignment, this is easy!

```
log_types+=wiglecsv
```

This will add to the `log_types` configuration instead of replacing it.
