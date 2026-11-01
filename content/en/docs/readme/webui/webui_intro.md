---
title: "The new web UI"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-01T01:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "webui_intro-a99ff4528cac1595a772f7695a1d57e5"
weight: 10
toc: true
---

Added: `after 2026-10-R1`

## A new UI, still changing

After 2026-10-R1, Kismet has a new web UI, served at `/` (for instance `http://localhost:2501/`).  The previous UI is still available at `/legacy/` (`http://localhost:2501/legacy/`), and the *Legacy UI* item in the new UI's top bar opens it.

The new UI is evolving rapidly in the [nightly (git) packages](/packages/#release-or-git) and in Kismet git: windows, settings, and features are added and changed from one nightly to the next, and the documentation here may lag behind what a nightly build shows.  If something is missing or behaves differently than described, check that you're running a recent nightly, and report problems as [Kismet GitHub issues](https://github.com/kismetwireless/kismet/issues).

Plugins which add pages to the previous UI keep working in it from `/legacy/`; the new UI lists plugins which don't have a page for it yet.  Both UIs use the same login, and settings in one don't change the other.

## What's in it

* *Overview*, *Devices*, *SSIDs*, *Alerts*, *Map*, and *Insights* tabs.
* Windows for data sources, channel coverage and the channel heat map, packet rates, and GPS, from the menu and the top bar.
* The device list's *Search or filter* box, which takes [device filters](/docs/readme/webui/webui_filters/) as well as plain searches.
* A *Tags* column and row highlights from the server's [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), set under *Settings*, *Appearance*, *Device Highlights*.
* Display units for speeds and lengths, under *Settings*, *Units*.
* [Censor mode](/docs/readme/configuring/webserver/#runtime-censorship), for screenshots and demos.
* The [receiver range](/docs/readme/configuring/receiver_range/) on the map.
* [Installing the UI as an app](/docs/readme/configuring/webserver/#installing-the-web-ui-as-an-app) on a phone or desktop.

Serving the UI, HTTPS, and proxies are covered in [the webserver configuration](/docs/readme/configuring/webserver/).
