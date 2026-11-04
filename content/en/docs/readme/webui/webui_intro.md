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
* Windows for data sources, channel coverage and the channel heat map, [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), packet rates, [memory](#memory-window), and GPS, from the menu and the top bar.
* The device list's *Search or filter* box, which takes [device filters](/docs/readme/webui/webui_filters/) as well as plain searches.
* A *Tags* column and row highlights from the server's [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), set under *Settings*, *Device Highlights*.
* Display units for speeds and lengths, under *Settings*, *Units*.
* Bluetooth and BTLE device details with service names, battery, distance, beacon, and connection sections, the [advertised data](/docs/readme/datasources/bluetooth-trackers/#advertised-data) decoded, and the address type, linked addresses, class of device, and controller version and features.
* [Censor mode](/docs/readme/configuring/webserver/#runtime-censorship), for screenshots and demos.
* The [receiver range](/docs/readme/configuring/receiver_range/) on the map.
* [Installing the UI as an app](/docs/readme/configuring/webserver/#installing-the-web-ui-as-an-app) on a phone or desktop.

## Memory window

After 2026-10-R1, the *Memory* window, opened from the menu or by clicking the memory figure in the top bar, shows how much memory Kismet uses and why, over the last minute, hour, or day:

* Kismet's memory and its peak, the device count, the memory per device, the system memory free, and how long Kismet has run.
* A graph of Kismet's memory (the left axis) against the device count (the right axis), a graph of the tracked fields (every value Kismet keeps, in devices and everything else), and a graph of the system memory in use.
* What the memory is: the heap and stacks, the program and libraries, shared memory, and swap.
* The [memory settings](/docs/readme/tuning/tuning/) in effect, from `kismet_memory.conf` or `kismet_site.conf`.

*Insights* flag what the memory is doing:

* About how much memory each new device costs, once the device count has changed enough to tell.
* Memory growing, at what rate, and when the system's free memory would run out at that rate, with a pointer to `tracker_device_timeout` and `tracker_max_devices` when devices are never forgotten.
* Memory growing while the device count holds: when tracked fields grew too, data kept in the devices (clients, probed SSIDs, history); when they didn't, something outside device data, such as packet queues, web clients, or memory the allocator holds.
* Low system memory, Kismet's share of it, memory swapped out, a peak far above the present, and freed memory the allocator holds for reuse.
* Settings which cost memory (`keep_location_cloud_history` and `keep_per_datasource_stats`), and a phy type which holds most of the devices.

The window reads the [`/system/memory`](/docs/api/system/) endpoint.  Against an older Kismet server without it, only the memory and device graphs are shown.  The process and system memory figures are only available on Linux, and the heap figures with glibc 2.33 or newer.

Serving the UI, HTTPS, and proxies are covered in [the webserver configuration](/docs/readme/configuring/webserver/).
