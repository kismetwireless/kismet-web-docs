---
title: "The new web UI"
description: ""
lead: ""
date: 2026-11-01T01:00:00-04:00
lastmod: 2026-11-18T09:00:00-05:00
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

* *Overview*, *Devices*, *SSIDs*, *Alerts*, *Map*, and *Insights* tabs, and an *Ethernet flows* tab once the server has [Ethernet](#ethernet) devices.
* Windows for data sources, channel coverage and the channel heat map, [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), packet rates, [memory](#memory-window), [environment](#environment-window) (temperatures, fans, and batteries), [CPU](#cpu-window), GPS, and [Ethernet VLANs](#ethernet), from the menu and the top bar.
* The *Messages* panel along the bottom.  Drag the bar above it to resize it, or minimize it to its tab bar with the `_` button at its right; it stays minimized in every tab and after a reload, until you click the button again, click one of its tabs, or drag the bar.
* A top bar of stats, including the CPU load of the system and of Kismet (after 2026-10-R1), and the [temperatures](#environment-window) of the system Kismet runs on and its data sources.  Choose the stats it shows under *Settings*, *Ribbon*; stats Kismet can't read show `---`.
* The device list's *Search or filter* box, which takes [device filters](/docs/readme/webui/webui_filters/) as well as plain searches.
* A *Tags* column and row highlights from the server's [device rules](/docs/readme/configuring/device_rules/#rules-in-the-web-ui), set under *Settings*, *Device Highlights*.
* Display units for speeds, lengths and temperatures, under *Settings*, *Units*.
* Names too long for their column are shortened, in the middle (`too l...ame`) or at the end (`too long n...`), set under *Settings*, *Appearance*, *Shorten long names*; point at a name to see it in full (after 2026-10-R1).  Censor mode censors shortened names too.
* Wi-Fi device details with a *Multiple BSSID* section: for a network an access point hosts in its multiple BSSID element (after 2026-10-R1), the access point that advertises it and its index; for that access point, the networks it hosts.  The *Insights* views show the hosted networks as part of their access point.
* Suspected karma and mana access points (after 2026-10-R1), from the server's [DOT11KARMA](/docs/readme/alerts/alerts/#dot11karma) detection: a *Karma detection* section in the device details, with the networks it answered for without advertising them, those nearby clients probed for, the networks it beaconed and answered, and any beacon flood; a *Wi-Fi suspected karma APs* device view; and a *Suspected karma AP* finding in *Insights*.  Against an older server, the UI keeps a stricter guess of its own.
* Alert severities named as the server names them: *Info*, *Low*, *Medium*, *High*, and *Critical*, each with its own highlight color (after 2026-10-R1).  Medium and up are highlighted by default.
* Bluetooth and BTLE device details with service names, battery, distance, beacon, and connection sections, the [advertised data](/docs/readme/datasources/bluetooth-trackers/#advertised-data) decoded, and the address type, linked addresses, class of device, and controller version and features.
* [Censor mode](/docs/readme/configuring/webserver/#runtime-censorship), for screenshots and demos.
* The [receiver range](/docs/readme/configuring/receiver_range/) on the map.
* [Installing the UI as an app](/docs/readme/configuring/webserver/#installing-the-web-ui-as-an-app) on a phone or desktop.

## A tour

The screenshots here show made-up devices, networks, and locations.  Each is shown in the light or dark theme to match these pages; the button under it switches theme, and *Zoom*, or clicking the screenshot, shows it full size.

The *Overview* tab sums up what Kismet sees in cards; the pencil at the top right moves, resizes, hides, and adds them back.  Every tab has the top bar of stats above it and the *Messages* panel below it.

{{< screenshot name="webui-overview" alt="The Overview tab" >}}

After 2026-10-R1, the *Overview* tab can hold several dashboards, picked from the *Dashboard* list at its top.  Each dashboard has its own cards, layout, and card settings, and can hide the top bar of stats and the *Messages* panel while it's showing; the pencil also names a dashboard, sets those two, and adds or deletes dashboards.  While arranging, a card with settings of its own has a gear button: the *Devices*, *Active devices*, and *New devices* cards can leave out their graphs, and the *Map* card picks which kinds of device and map overlays it draws, whether it shows paths and the receiver range, and whether it keeps Kismet's GPS location in view.  The *Map* card is the map tab without its list, and isn't on the Overview until it's added.

The *Wardriving* dashboard is made for a phone: the *Active devices* and *New devices* counts above a map that follows Kismet's location, without the stats bar or the messages.  *Reset layout* puts the *Overview* and *Wardriving* dashboards back as they started; dashboards you make can be deleted.

{{< screenshot name="webui-topbar" alt="The top bar" >}}

The *Devices* tab lists every device, with the *Tags* column and the row highlights from the device rules.  The *Search or filter* box takes [device filters](/docs/readme/webui/webui_filters/).  Searching in a smaller view also shows how many devices match in all devices; clicking that count shows them.  It can be turned off under *Settings*, *Device list*.

{{< screenshot name="webui-devices" alt="The Devices tab" >}}

The *SSIDs* tab lists the Wi-Fi networks, and the *Alerts* tab the alerts:

{{< screenshot name="webui-ssids" alt="The SSIDs tab" >}}

{{< screenshot name="webui-alerts" alt="The Alerts tab" >}}

The *Map* tab places devices by where they report themselves or where Kismet heard them, with a checkbox for each kind of device.  Without a map server, it draws them on a blank map:

{{< screenshot name="webui-map" alt="The Map tab" >}}

The *Insights* tab shows how devices relate: here, Wi-Fi clients and the access points they use.

{{< screenshot name="webui-insights" alt="The Insights tab" >}}

After 2026-10-R1, the flow graph stays readable in a busy area.  Each column shows its busiest entries, and every entry with a finding: up to 15 access points, 20 networks and 20 groups of connected devices, or about half that on a phone.  The rest are merged into one *more* entry.  Clicking a *more* access point or network entry pages through that column, busiest first, with the page shown in the bar; clicking a *more* group of devices lists them.  *Back* returns to the view before, and *Show all* switches between everything and the busiest.  Clicking a network, or *Show only what links through this* on an access point or a group of devices, shows only that entry and what links through it, and the search box does the same for a network, access point, or device name or MAC address; these views are trimmed the same way.  The flow table shows up to 80 columns and 120 access point addresses.

After 2026-10-R1, the Insights views also group 802.11s mesh networks and multiple BSSID sets.  Each mesh ID is listed with the networks, outlined in the mesh color, and linked to every mesh point heard; mesh points are no longer shown as hidden networks.  An access point which sends further networks in its multiple BSSID element is named for the address sending them and tagged *MBSSID*, with the number of networks in the set; its card in the *Access points* view lists the networks in the set.

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

## Environment window

After 2026-10-R1, Kismet reads the environmental sensors of the system it runs on every second: temperatures and fans (from lm-sensors, when Kismet is built with it, or hwmon, and the Linux thermal zones) and batteries.  Data sources which can report their own sensors too, such as a [Radiacode](/docs/readme/datasources/radiacode/)'s temperature and battery, or the temperature of a [Linux Wi-Fi](/docs/readme/datasources/wifi-linux/) radio which has a sensor.  Kismet keeps a history of each, for the last minute, hour, and day.

The *Environment* window (the *Thermal* window in earlier builds), opened from the menu or by clicking the *Sensors* or battery stat in the top bar, has *Thermal*, *Fans*, and *Battery* tabs.  Each shows:

* A summary: the hottest sensor, the average, and how many are read; the fastest fan, and how many are stopped; or the lowest battery.
* A graph over the last minute, hour, or day.  Check sensors in the list to graph them; with none checked, the four hottest temperatures, or the first fans or batteries, are graphed.  The CPU load of the system and of Kismet is graphed with them, against the right axis.
* Every sensor's value now, and its lowest, highest, and average over the time shown, grouped by *This server* and by data source.  A data source's group is marked *Closed* or *Removed* when the source stops; its sensors are removed once they haven't reported for a while.

{{< screenshot name="webui-thermal" alt="The Environment window" >}}

The *Sensors* stat in the top bar (*Thermal* in earlier builds; a saved choice carries over) shows the hottest sensor, or the sensors checked under *Settings*, *Ribbon*, *Sensors*.  The battery stat shows the server's battery and those of data sources with one, and no longer always says it is charging.  Temperatures are shown in Celsius or Fahrenheit, set under *Settings*, *Units*.

The window reads the [`/system/environment`](/docs/api/system/) endpoint.  Against an older Kismet server without it, or with no sensors Kismet can read, the window says so and the top bar shows `---`.

{{<configopt environment_history true false>}}
Keep a history of each sensor (after 2026-10-R1).  Defaults to `true`; set to `false` to keep only the current values.  The older name `system_thermal_history` is still read when this is unset.
{{</configopt>}}

{{<configopt environment_max_sensors count>}}
The most host sensors of each kind (temperature, fan, battery) tracked (after 2026-10-R1); any past it are left out.  Defaults to `32`, and can be 1 to 1024.  The older name `system_thermal_max_sensors` is still read when this is unset.
{{</configopt>}}

{{<configopt environment_source_max_sensors count>}}
The most sensors kept from each data source, `0` to `32` (after 2026-10-R1); defaults to `8`.  `0` turns data source sensor reports off.
{{</configopt>}}

{{<configopt environment_source_report_sec seconds>}}
Data sources report their sensors at most once per this many seconds, `1` to `3600` (after 2026-10-R1); defaults to `5`.  At most 256 data source sensors are kept in all.
{{</configopt>}}

## CPU window

After 2026-10-R1, the *CPU* window, opened from the menu or by clicking the CPU stat in the top bar, shows the CPU load of the system Kismet runs on, and of Kismet itself, as a percent of all the CPUs:

* The load now, the number of CPUs, and the highest load over the time shown (its tooltip has the average).  The tooltip of Kismet's load also gives it as a share of one CPU, which shows a single busy thread.
* A graph of both over the last minute, hour, or day.

{{< screenshot name="webui-cpu" alt="The CPU window" >}}

The window reads the [`/system/cpu`](/docs/api/system/) endpoint.  The CPU load is only read on Linux; elsewhere, and against an older Kismet server without it, the window says so.

After 2026-10-R1, the *Overview* tab also has *CPU*, *Memory*, and *Environment* (formerly *Temperatures*) cards: each shows the reading now and a graph over the last minute, hour, or day, and opens its window when clicked.  The *Environment* card graphs the same temperatures as the *Environment* window, and its settings can add lists of fans and batteries; without temperature history it lists the hottest sensors now instead.  Against an older Kismet server without the CPU or environment endpoints, the cards say so.

{{< screenshot name="webui-overview-system" alt="The CPU, Memory, and Temperatures cards" >}}

## Radiation window

After 2026-10-R1, the *Radiation* window, opened from the menu or by clicking a radiation stat in the top bar, shows the radiation sensors, such as the [Radiacode](/docs/readme/datasources/radiacode/).  With more than one sensor, pick which one to show.

* The count rate (counts per second) and dose rate, and for sensors which report them, the accumulated dose the sensor has counted, its temperature, and its battery.
* *History*: the count rate, and the dose rate against the right axis, over the last minute, hour, or day.
* *Spectrum*, for sensors which send one: the gamma energy spectrum since Kismet started (*Session*), over the past hour, or as the sensor has accumulated it (*Device*), on a log or linear scale.  *Gamma lines* marks the energies of common isotopes, and *Waterfall* adds the past hour minute by minute, newest at the top and brighter for more counts.  For a sensor without a spectrum, the section says so.
* *Peaks* finds the peaks in the spectrum and names the common gamma lines near them ("Peaks hint at: ..."); point at the hint for each peak's energy and significance.  These are hints from the energies of the peaks, never an identification.
* *CSV* saves the spectrum shown as channel, energy in keV, and counts; *N42* saves it as ANSI N42.42 XML, for spectrum tools such as InterSpec.

Both sections fold away, and the window fits its height to what it shows until you resize it.

The *Map* tab has a *Radiation dose* overlay while a sensor has readings at GPS locations: a track colored from green at background to red at 1 uSv/h and above (for a Radview, which reports no dose rate, by its count rate), with the range of readings when pointed at.  Readings within 10 meters and a minute of each other are merged, and a sensor's track keeps its last 4000 points.

The server raises the [RADIATIONDOSE](/docs/readme/alerts/alerts/#radiationdose) alert when a sensor's dose rate passes `radiation_alert_dose`, and [RADIATIONRISE](/docs/readme/alerts/alerts/#radiationrise) when its count rate rises well above its own background.

**Never** rely on radiation readings shown by Kismet for safety: they depend on the detector, its calibration, and how it is held.

The top bar has *Radiation counts* and *Radiation dose rate* stats, shown once the server has a radiation sensor, and hidden or shown again under *Settings*, *Ribbon*.  The *Overview* tab offers a *Radiation* card (the dose and count rates, with the last minute of counts) and a *Radiation spectrum* card, with its own window, scale, and gamma line settings; neither is on a dashboard until added with *Edit layout*.

The window reads the [radiation endpoints](/docs/api/radiation/).

## Ethernet

After 2026-10-R1, the UI shows the wired devices of the [Ethernet phy](/docs/readme/datasources/wired-linux/), from the wired data source or Ethernet pcap files:

* Ethernet devices have their own icons, *VLAN*, *IP*, and *Hostname* columns in the device list, and details with their addresses, names, DHCP details, and flows.
* The *Ethernet flows* tab, after *Map*, lists the IP flows: the two sides with their addresses, ports, and MACs, the protocol and VLAN, who started it, and the bytes and packets each way.  Opened from a device or a VLAN, it starts filtered to it.
* The *Ethernet VLANs* window, from the menu, lists the VLANs seen, with their frames, bytes, and devices.

The tab and the window are offered once the server has Ethernet devices.  Both say so when devices or flows weren't kept because of the server's [limits](/docs/readme/datasources/wired-linux/#ethernet-options).

They read the [Ethernet endpoints](/docs/api/ethernet/).

## API keys window

After 2026-10-R1, the *API keys* window, opened from the menu just above *Settings*, manages the API keys of the server in use.  Programs and [remote capture](/docs/readme/remotecap/remotecap/) use a key in place of a login.  Managing keys needs an admin login.

* Each key is listed with its name, role, and when it expires.  Keys are hidden until *Show* is pressed, and hidden again when the window closes; *Copy* copies a key without showing it.  Over plain HTTP the browser has no clipboard, so *Copy* shows and selects the key to copy by hand.
* *Revoke* removes a key, after asking.  Anything using the key loses access.  If the key is the one the app uses for another server, the app asks to log in again.
* *Create a key* takes a name, a role (*readonly*, *admin*, *datasource*, *scanreport*, *ADSB*, *datalog* for saving [tagged data](/docs/readme/logging/kismetdb/) to the kismetdb log, or another role a plugin defines), and how long until it expires.  The new key opens in a window with a *Copy* button.

When the server sets `httpd_allow_auth_view=false`, it never sends keys back, so a key can only be copied when it's made.  With `httpd_allow_auth_creation=false`, keys can't be made or revoked from the UI.

Serving the UI, HTTPS, and proxies are covered in [the webserver configuration](/docs/readme/configuring/webserver/).
