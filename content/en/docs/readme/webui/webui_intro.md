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
* Windows for data sources, channel coverage and the channel heat map, [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), packet rates, [memory](#memory-window), [thermal](#thermal-window), [CPU](#cpu-window), and GPS, from the menu and the top bar.
* The *Messages* panel along the bottom.  Drag the bar above it to resize it, or minimize it to its tab bar with the `_` button at its right; it stays minimized in every tab and after a reload, until you click the button again, click one of its tabs, or drag the bar.
* A top bar of stats, including the CPU load of the system and of Kismet (after 2026-10-R1), and the [temperatures](#thermal-window) of the system Kismet runs on.  Choose the stats it shows under *Settings*, *Ribbon*; stats Kismet can't read show `---`.
* The device list's *Search or filter* box, which takes [device filters](/docs/readme/webui/webui_filters/) as well as plain searches.
* A *Tags* column and row highlights from the server's [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), set under *Settings*, *Device Highlights*.
* Display units for speeds, lengths and temperatures, under *Settings*, *Units*.
* Bluetooth and BTLE device details with service names, battery, distance, beacon, and connection sections, the [advertised data](/docs/readme/datasources/bluetooth-trackers/#advertised-data) decoded, and the address type, linked addresses, class of device, and controller version and features.
* [Censor mode](/docs/readme/configuring/webserver/#runtime-censorship), for screenshots and demos.
* The [receiver range](/docs/readme/configuring/receiver_range/) on the map.
* [Installing the UI as an app](/docs/readme/configuring/webserver/#installing-the-web-ui-as-an-app) on a phone or desktop.

## A tour

The screenshots here show made-up devices, networks, and locations.  Each is shown in the light or dark theme to match these pages; the button under it switches theme, and *Zoom*, or clicking the screenshot, shows it full size.

The *Overview* tab sums up what Kismet sees in cards; the pencil at the top right moves, resizes, hides, and adds them back.  Every tab has the top bar of stats above it and the *Messages* panel below it.

{{< screenshot name="webui-overview" alt="The Overview tab" >}}

{{< screenshot name="webui-topbar" alt="The top bar" >}}

The *Devices* tab lists every device, with the *Tags* column and the row highlights from the device rules.  The *Search or filter* box takes [device filters](/docs/readme/webui/webui_filters/).

{{< screenshot name="webui-devices" alt="The Devices tab" >}}

The *SSIDs* tab lists the Wi-Fi networks, and the *Alerts* tab the alerts:

{{< screenshot name="webui-ssids" alt="The SSIDs tab" >}}

{{< screenshot name="webui-alerts" alt="The Alerts tab" >}}

The *Map* tab places devices by where they report themselves or where Kismet heard them, with a checkbox for each kind of device.  Without a map server, it draws them on a blank map:

{{< screenshot name="webui-map" alt="The Map tab" >}}

The *Insights* tab shows how devices relate: here, Wi-Fi clients and the access points they use.

{{< screenshot name="webui-insights" alt="The Insights tab" >}}

Clicking a device opens its details, in sections for each kind of device; this is a Bluetooth LE tag reporting its battery:

{{< screenshot name="webui-btle-device" alt="Bluetooth LE device details" >}}

### Windows

Windows open as panels which stay open while you use the rest of the UI; drag a title bar to move one and its corner to resize it.  After 2026-10-R1, the *Data sources*, *Channel coverage*, and *Packet rates* windows have a button in their title bar which makes them fill the browser window, and takes them back to their size when clicked again.

The data sources, opened from the menu or the *Sources* stat in the top bar:

{{< screenshot name="webui-sources" alt="The Data sources window" >}}

Channel coverage, live, and as a heat map over time:

{{< screenshot name="webui-coverage" alt="The Channel coverage window" >}}

{{< screenshot name="webui-heatmap" alt="The channel heat map" >}}

The server's [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), by rules file:

{{< screenshot name="webui-devicerules" alt="The Device rules window" >}}

Packet rates, from the menu or the *Packets* stat:

{{< screenshot name="webui-packets" alt="The Packet rates window" >}}

The GPS, from the menu or the *GPS* stat: the fix, the satellites in view and their signal, and their history:

{{< screenshot name="webui-gps" alt="The GPS window" >}}

### Settings

*Settings*, *Units*:

{{< screenshot name="webui-settings-units" alt="Settings, Units" >}}

*Settings*, *Device Highlights*:

{{< screenshot name="webui-settings-highlights" alt="Settings, Device Highlights" >}}

*Settings*, *Ribbon*:

{{< screenshot name="webui-settings-ribbon" alt="Settings, Ribbon" >}}

*Settings*, *Censor mode*:

{{< screenshot name="webui-settings-censor" alt="Settings, Censor mode" >}}

## Memory window

After 2026-10-R1, the *Memory* window, opened from the menu or by clicking the memory figure in the top bar, shows how much memory Kismet uses and why, over the last minute, hour, or day:

{{< screenshot name="webui-memory" alt="The Memory window" >}}

* Kismet's memory and its peak, the device count, the memory per device, the system memory free, and how long Kismet has run.
* A graph of Kismet's memory (the left axis) against the device count (the right axis), a graph of the tracked fields (every value Kismet keeps, in devices and everything else), and a graph of the system memory in use.
* What the memory is: the heap and stacks, the program and libraries, shared memory, and swap.
* What the heap holds: what Kismet needed once it had loaded (before opening data sources), its data sources, recent packets kept to spot duplicates, freed packets kept for reuse, and devices.
* The [memory settings](/docs/readme/tuning/tuning/) in effect, from `kismet_memory.conf`, `kismet_site.conf` and the other config files.

The memory per device counts only the memory devices use: Kismet's memory once it had loaded, an estimate for each data source, and the packets it keeps are taken out first.  Dividing all of Kismet's memory by the device count overstates it, often several times over with few devices.

*Insights* flag what the memory is doing:

* About how much memory each new device costs, once the device count has changed enough to tell.
* Memory growing, at what rate, and when the system's free memory would run out at that rate, with a pointer to `tracker_device_timeout` and `tracker_max_devices` when devices are never forgotten.
* Memory growing while the device count holds: when tracked fields grew too, data kept in the devices (clients, probed SSIDs, history); when they didn't, something outside device data, such as packet queues, web clients, or memory the allocator holds.
* Low system memory, Kismet's share of it, memory swapped out, a peak far above the present, and freed memory the allocator holds for reuse.
* Settings which cost memory (`keep_location_cloud_history` and `keep_per_datasource_stats`), and a phy type which holds most of the devices.

Close an insight with its *×*; it stays closed until it becomes more serious (a note turning into a warning), and *Show closed insights* below the list brings them all back.

The memory per device, and the cost of a new device, are estimates and can be well off, most of all soon after Kismet starts: the packet buffers are still filling, and with few devices the one-time costs are spread over too few of them.

The window reads the [`/system/memory`](/docs/api/system/) endpoint.  Against an older Kismet server without it, only the memory and device graphs are shown.  The process and system memory figures are only available on Linux, and the heap figures with glibc 2.33 or newer.

## Thermal window

After 2026-10-R1, Kismet reads the temperature sensors of the system it runs on every second: the lm-sensors sensors, when Kismet is built with lm-sensors, and the Linux thermal zones.  It keeps a history of each, for the last minute, hour, and day.

The *Thermal* window, opened from the menu or by clicking the temperature in the top bar, shows:

* The hottest sensor, the average of the sensors, and how many are read.
* A graph of the sensors over the last minute, hour, or day.  Check sensors in the list to graph them; with none checked, the four hottest are graphed.  The CPU load of the system and of Kismet is graphed with them, against the right axis.
* Every sensor's temperature now, and its lowest, highest, and average over the time shown.

{{< screenshot name="webui-thermal" alt="The Thermal window" >}}

The *Thermal* stat in the top bar shows the hottest sensor, or the sensors checked under *Settings*, *Ribbon*, *Thermal*.  Temperatures are shown in Celsius or Fahrenheit, set under *Settings*, *Units*.

The window reads the [`/system/thermal`](/docs/api/system/) endpoint.  Against an older Kismet server without it, or a system with no sensors Kismet can read, the window says so and the top bar shows `---`.

{{<configopt system_thermal_history true false>}}
Keep a history of each temperature sensor (after 2026-10-R1).  Defaults to `true`; set to `false` to keep only the current temperatures.
{{</configopt>}}

{{<configopt system_thermal_max_sensors count>}}
The most temperature sensors tracked (after 2026-10-R1); any past it are left out.  Defaults to `32`, and can be 1 to 1024.
{{</configopt>}}

## CPU window

After 2026-10-R1, the *CPU* window, opened from the menu or by clicking the CPU stat in the top bar, shows the CPU load of the system Kismet runs on, and of Kismet itself, as a percent of all the CPUs:

* The load now, the number of CPUs, and the highest load over the time shown (its tooltip has the average).  The tooltip of Kismet's load also gives it as a share of one CPU, which shows a single busy thread.
* A graph of both over the last minute, hour, or day.

{{< screenshot name="webui-cpu" alt="The CPU window" >}}

The window reads the [`/system/cpu`](/docs/api/system/) endpoint.  The CPU load is only read on Linux; elsewhere, and against an older Kismet server without it, the window says so.

After 2026-10-R1, the *Overview* tab also has *CPU*, *Memory*, and *Temperatures* cards: each shows the reading now and a graph over the last minute, hour, or day, and opens its window when clicked.  The *Temperatures* card graphs the same sensors as the *Thermal* window; without temperature history it lists the hottest sensors now instead.  Against an older Kismet server without the CPU or thermal endpoints, the cards say so.

{{< screenshot name="webui-overview-system" alt="The CPU, Memory, and Temperatures cards" >}}

Serving the UI, HTTPS, and proxies are covered in [the webserver configuration](/docs/readme/configuring/webserver/).
