---
title: "API changes"
description: ""
lead: ""
date: 2022-10-17T09:24:51-04:00
lastmod: 2022-10-17T09:24:51-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "major_changes-74c7d9d7017c83f1c8ee89401cbc76b5"
weight: 10
toc: true
---

Over time, the Kismet endpoint API will change - while efforts are made to retain compatibility whenever possible, some changes will require breaking older implementations.  These significant changes will be documented here.

#### After 2026-10-R1

**New web UI.**  The web UI served at `/` is the new UI; the previous UI is served from `/legacy/`.  Requests under `/legacy/` that aren't one of the legacy UI's own files are answered as the same path from the root, so `/legacy/devices/...` is the same as `/devices/...`, and plugins written for the previous UI keep working there.  Clients that use the REST API directly aren't affected.

**Simple device type.**  `kismet.device.base.type` is what the device is, such as `Wi-Fi AP`, `Wi-Fi Client`, `Apple Watch`, `BTLE Tracker`, or `Airplane`, as before.  The new `kismet.device.base.simple_type` is the basic type of the device's phy, such as `Wi-Fi`, `BTLE`, `BR/EDR`, `ADSB`, or `ANT`, the same for every device of that phy; use it to tell devices apart by kind without listing every type.  Both are present on every device.  Devices with Apple Continuity types, such as `Apple Watch`, have the simple type `BTLE`.  Some phys make devices under a general type, such as `AMR Meter` or `Cellular`, until they learn more; a device the phy can't name more specifically then shows its simple type, such as `Meter` or `Cell`.

For about a week in November 2026, development builds put the phy's type in `kismet.device.base.type` and the specific type in `kismet.device.base.display_type`; that field is gone, and `kismetdb_to_wiglecsv` doesn't read logs from those builds.

**Probed interface options.**  In the interface lists from `/datasource/list_interfaces`, `kismet.datasource.probed.options_vec` now holds the flags the capture tool reported for the interface; it was always empty before.  No capture tool included with Kismet reports flags yet.

**Removed `kismet.common.signal.min_signal_rrd`.**  Devices no longer keep the weakest signal per second, minute, and hour.  `kismet.common.signal.max_signal_rrd` (the strongest) is still kept.

**Device rules.**  [Device rules](/docs/readme/configuring/device_rules/) tag, color, sort, and collect devices into views, and raise alerts.  Devices that match a rule carry `kismet.device.base.rules`, with the names of the matching rules, their tags, and color.  Rules can be read and set with the [device rules API](/docs/api/device_rules/), rules with a `view` make a `rule-<name>` device view, and the [device view](/docs/api/device_views/) endpoint takes a `rule_sort` option.

**Device baseline.**  [Baseline filters](/docs/readme/configuring/baseline/), off by default, add devices to the baseline (the user tag `baseline`) and take them out on their own schedule, keeping the tags `baseline-by`, `baseline-hold`, and `baseline-expired`; adding or removing `baseline` with `set_tag.cmd` and `delete_tag.cmd` keeps them too.  Baseline filters are listed in the device rules API with their schedule and counts.  `set_tag.cmd` takes `ephemeral` for tags which aren't saved, listed in `kismet.device.base.ephemeral_tags`, and now refuses tag names and values which aren't strings, names over 256 characters, and values over 64KB.

**Alerts on devices.**  Devices named by alerts carry `kismet.device.base.alerts`, with the alerts the device sent (`kismet.device.alerts.sent`, `.sent_severity`, `.sent_headers`, `.sent_classes`, `.sent_last_time`, `.own_sent`, `.own_severity`), the alerts which only name it (`.named`), all of their names (`.headers`), and the time of the last one (`.last_time`).  `kismet.device.base.num_alerts`, always 0 before, now counts them.  See [alerts on devices](/docs/readme/alerts/alerts/#alerts-on-devices).

**Device rule timing.**  `device_rules_interval` and `device_rules_full_interval` take times such as `1s` and `10s`; a bare number is seconds.  Rules gain `recheck`, and the rules API lists it as `kismet.devicerules.rule.recheck`.

**Receiver range.**  Kismet records how far away devices which report their own position are heard in each direction, by kind of device and data source, over all time, the last day, and by altitude; see the [receiver range](/docs/readme/configuring/receiver_range/) and the [receiver range API](/docs/api/receiver_range/).

**Device locations.**  The last location of a device (`kismet.common.location.last`) now has the time of the position in `kismet.common.location.time_sec` and `kismet.common.location.time_usec`.  Device locations no longer carry fields from Kismet's own GPS, such as `kismet.common.location.gps_uuid` or the GPS quality report, which could appear in them before.

**ADS-B decoding.**  Aircraft speeds were converted as if they were mph and read 13% low; they're now correct km/h.  Altitude is no longer taken from velocity messages, which made it alternate with 0 or very large values.  Eastbound aircraft now have a heading.  An aircraft's reported location keeps the time its position was decoded, rather than the time of the last message heard from it.

**Cell device names.**  A cell known only by its PCI is named with its RAT's channel number: `NR PCI <pci> NR-ARFCN <n>` for NR and `UARFCN` for WCDMA, instead of `EARFCN` for every RAT.  LTE names are unchanged.

**celldiag status lines.**  The periodic `celldiag stats:` and `celldiag inventory:` messages start with the source's label, as other per-source messages do; the text after the label is unchanged.

**Marked messages and alerts.**  New endpoints under `/messagebus/marked/` and `/alerts/marked/`, and the `/eventbus/marked/events` websocket, add `kismet.messagebus.message_marked` and `kismet.alert.text_marked`:  the text with the parts which identify a device, network, person, or place marked by kind, which the web UI uses to censor them.  See [messages](/docs/api/messages/) and [alerts](/docs/api/alerts/).  The existing endpoints and the logs are unchanged.

**kismetdb log UUID.**  [kismetdb](/docs/dev/kismetdb/) logs are now version 12, with a per-file UUID in `KISMET.db_uuid`.  For the kismetdb log, `kismet.logfile.uuid` in the logging API is that UUID, made when the file is opened, rather than one made when Kismet started.

**Channel retries.**  [/channels/channels](/docs/api/channels/) records add Wi-Fi retry counts (`kismet.channelrec.retry_*`) and, on frequency records, a noise flag and score (`kismet.channelrec.noise*`).

**Cell bands and input checks.**  `cellular.cell.band` only treats bands of the same duplex mode as names for one carrier, and an LTE report without a frequency keeps the band shown; see [cell devices](/docs/readme/datasources/cell-at/#cell-devices).  Numeric fields from the cell sources that are the wrong type or out of range are now ignored instead of wrapped or truncated, so a malformed field no longer changes a cell's key, band, or WiGLE row.

**Apple Continuity.**  `bluetooth.adv.continuity` now also counts AirPods proximity pairing (`proximity_pairing`) and Find My (`findmy`) messages.

**Ethernet phy.**  The new `IEEE802.3` phy tracks wired devices, with `ethernet.device` records and the `phy-IEEE802.3` device view; flows, VLANs, devices by IP, and status are under `/phy/ethernet/`.  See the [Ethernet API](/docs/api/ethernet/) and the [wired data source](/docs/readme/datasources/wired-linux/), whose sources carry `kismet.datasource.wired.*` status fields.

**Environmental sensors.**  [`/system/environment`](/docs/api/system/) lists the temperatures, fans, and batteries of the host and of data sources, in `kismet.system.environment.*` records, and the `ENVIRONMENT` eventbus topic and kismetdb snapshots carry their current values.  `/system/thermal` now returns the same records for the temperature sensors only, instead of the `kismet.system.thermal.*` records of earlier development builds.  The options `system_thermal_history` and `system_thermal_max_sensors` are now `environment_history` and `environment_max_sensors`; the old names are still read.

**SSID hashes with embedded NULs.**  SSIDs are hashed and shown in full, embedded NUL bytes included (escaped when shown), so SSIDs which differ only after a NUL are no longer merged into one record.  The hash of such an SSID changes, in the API, in kismetdb logs, and in `/phy/phy80211/ssids/by-hash/`.

**Per-device SSID limits.**  The advertised, responded, and probed SSID lists of a Wi-Fi device keep at most [`dot11_max_device_ssids`](/docs/readme/tuning/tuning/) (128) entries each.

**Karma detection.**  Wi-Fi access points carry `dot11.device.karma` once they answer for networks they don't beacon, or beacon a pool of networks, and suspected ones are listed in the `phydot11_karma` view; see [DOT11KARMA](/docs/readme/alerts/alerts/#dot11karma) and the [Wi-Fi API](/docs/api/wifi_dot11/).

**Radiation track.**  [`/radiation/sensors/by-uuid/{UUID}/track`](/docs/api/radiation/) returns a sensor's readings at GPS locations.

**Bad requests are 400.**  A malformed JSON request body is answered with `400` instead of `500`; see [command parameters](/docs/api/command_param/).  The web and meta GPS `update` POST endpoints refuse out-of-range positions with `400`, as their websockets already did.

**Cell DIAG replays.**  A cell DIAG `replay=` source which has read its file stays open and idle instead of being re-opened and replaying the file again; `kismet.datasource.celldiag.replay_state` says `reading`, `complete`, or `incomplete`.

#### 2026-10-R1

**Major change to device location data.**  Devices that report their own position (ADS-B aircraft, AIS vessels, Remote ID drones, MeshCore and Meshtastic nodes) previously had that position written into the device location.  The device location now always means where Kismet was when it heard the device, and the position the device reports is kept separately:

* `kismet.device.base.location` and `kismet.device.base.location_cloud` hold Kismet's own GPS position for *all* devices.  Signal peak locations, seen-by locations, alerts, and PPI / pcap-ng GPS records also use Kismet's GPS.
* New `kismet.device.base.reported_location` (the same min, max, average, and last structure as `kismet.device.base.location`) and `kismet.device.base.reported_location_cloud` (the location history) hold the position the device reports.  These fields are only present on devices which report their own location.
* The [ADSB](/docs/api/adsb/) and [AIS](/docs/api/ais/) map endpoints compute their bounding boxes from the reported location.
* The `rtladsb` and `rtlais` datasources now record Kismet's GPS position on their packets.
* Updated to [version 11 of kismetdb](/docs/dev/kismetdb/#version-11), which adds reported location columns to the devices, packets, and data tables.

Clients which read the device location to place an aircraft, vessel, or drone must read `kismet.device.base.reported_location` instead.

**Channel history fixed.**  The per-channel RRDs in [/channels/channels](/docs/api/channels/) now add up packets and bytes per second instead of averaging them, and device counts no longer drop when the channels are read.  Field renames in a `fields` request are now applied to channel records.

#### Git

* Added `crypt_bitfield` fields for modern Wi-Fi encryption options.  Added `crypt_string` for printable versions of the crypt bitfield.  Older crypset options remain, but are deprecated, and can not accurately represent the full modern encryption options.

* Added common string cache for crypt string and Wi-Fi SSIDs, invisible to the API consumption but optimizing in the background.

* Expanded the system status API to included additional string cache records.

#### 2023-07-R1

* Changed to JWT internally for generating session tokens

#### 2022-01-R3

Changes to the REST API:

* Added `WEBGPS` role to the [webgps POST API](/docs/api/gps/#web-gps)
* Soft-launched the [metagps API](/docs/api/gps/#meta-gps) for remote capture GPS

#### 2022-01-R2

Changes to the REST API:

* Added regex to [device view by time](/docs/api/device_views/#devices-by-view-and-time)

#### 2022-01-R1

Changes to the REST API:

* Added the option to [filter pcap-ng streams](/docs/api/kismetdb/#tags) by packet tag
* Added [additional events](/docs/api/eventbus/#dot11_advertised_ssid) to the eventbus, including the first packet for advertised SSIDs, responding SSIDs, and probed SSIDs.

Changes to the kismetdb database:

* Updated to version 8 of kismetdb, which [adds additional packet metadata](/docs/dev/kismetdb/#version-8)

Changes to pcapng logging:

* Added pcapng style CRC32 hashes and packet identifier numbers for multi-interface captures

Changes to ipc/remote:

* Added v2 ipc protocol to optimize for fast construction / zero memcpy

#### 2021-05-R1

Changes to the REST API:

* Added a [view-specific device subscription API](/docs/api/device_views/#realtime-device-monitoring-by-view) under `/device/views/[VIEWID]/monitor.ws`
* Added a [datasource-specific ADSB hex API](/docs/api/adsb/#adsb-raw-websocket) under `/datasource/by-uuid/[uuid]/adsb_raw.ws`
* Added `class` and `severity` to [alert definitions](/docs/api/alerts/#alert-severities) and returned alerts

#### 2020-12-R1

This version introduces a complete rewrite of the internal webserver implementation, changing the core webserver library to Boost::Beast and rewriting how endpoints are processed and parsed.

Changes to the REST API:

* 802.11 handshake pcaps are now found on `/phy/phy80211/by-key/[key]/pcap/handshake.pcap` and `/phy/phy80211/by-key/[key]/pcap/handshake-pmkid.pcap`.  The original MAC-based filenames are passed with the `attachment; filename=...` header.
* Per-uuid pcapng streams are now found at `/datasource/pcap/by-uuid/[uuid]/packets.pcapng`
* Per-device pcapng streams are now found at `/devices/pcap/by-key/[key]/packets.pcapng`
* Phy80211 per-bssid pcap streams are now found at `/phy/phy80211/pcap/by-bssid/[mac]/packets.pcapng`
* All REST endpoints in the API now use `cmd` as the file extension for all commands, deprecating and removing the `jcmd` extension fully (which has not been a documented command extension for several releases already).
* Websockets are now implemented in the Kismet webserver, with the Eventbus websocket being the largest user.
* `wget` is now supported by detection of the user-agent field; a full HTTP 401 and WWW-Authenticate header is sent to accommodate `wget` not sending basic-auth until it fails an auth check.
* HTTP GET variables are now properly supported
* [API keys and roles](/docs/api/login/#api-tokens-and-roles) are now supported
* JSON data accepted as application/json as well as application/x-form-urlencoded
* Authentication may be passed as `user`, `password`, or `KISMET` GET URL variables

New endpoints:

* Realtime message, alert, GPS, system status, and more via the [eventbus](/docs/api/eventbus/) websocket at `/eventbus/events.ws`
* [API auth token manipulation](/docs/api/login/#api-tokens-and-roles) endpoints on `/auth/apikey/generate.cmd`, `/auth/apikey/revoke.cmd`, and `/auth/apikey/list.json`.
* Runtime [changing of the devicefound/deviceleft alert list](/docs/api/devices/#device-presence-alerts-view) via `/devices/alerts/mac/[type]/add.cmd`, `/devices/alerts/mac/[type]/remove.cmd` and `/devices/alerts/mac/[type]/macs.json`
* Live [ADSB data](/docs/api/adsb/#adsb-raw-websocket) in text/hex mode via `ws://.../phy/RTLADSB/raw.ws`, streams a text-based hex output of the ADSB data
* Live [ADSB data](/docs/api/adsb/#adsb-beast-websocket) in binary/beast mode via `ws://.../phy/RTLADSB/beast.ws`, streams a binary beast-protocol ADSB dump
* Subscription-style [live device monitoring](/docs/api/devices/#realtime-device-monitoring) websocket endpoint at `ws://.../devices/monitor.ws`


Changes to data:

* Locational data no longer includes the `avg_lat`, `avg_lon`, or `avg_alt` and related fields that held the *raw* averages of location.  The average location *is still present* in average location object, this removal affects only the internal raw values which were exposed to serialization.
* Locational data no longer includes the `kismet.common.location.valid` field, as it was redundant - this data is contained in `kismet.common.location.fix` when the fix is >= 2.
* Location data no longer includes the 'history cloud', an attempt to provide a RRD-like history log; it used way too much RAM and was not used anywhere.
* Some locations (such as min/max/average) no longer track speed and heading, saving more ram
* Server UUID in device records is now a common shared field under the name `kismet.server.uuid`
* Non-json command endpoints (mostly) now return text/plain
* RRDs no longer include the aggregator string name

#### 2020-08

To save RAM, several maps and vectors are now flagged as optional; if there is no content in those fields, they will not be present in the generated JSON.  Consumers should always check for presence of the map in the returned data before trying to use it.

Fields made dynamic:

* `kismet.device.base.tags`
* `dot11.device/dot11.device.client_map`
* `dot11.device/dot11.device.advertised_ssid_map`
* `dot11.device/dot11.device.probed_ssid_map`
* `dot11.device/dot11.device.associated_client_map`
* `dot11.device/dot11.device.wpa_nonce_list`
* `dot11.device/dot11.device.wpa_anonce_list`

To save RAM, the `kismet.device.base.tags` sub-map is now optional; if there are no tags in a device, this field will not exist in the serialized JSON data.  Consumers of this data should check that `kismet.device.base.tags` is present in the device map.

#### 2019-10

To more cleanly support ELK, all location records now use `geopoint` formats.  A geopoint is an array containing `[lon, lat]`.  `kismet.common.location.lat` and `kismet.common.location.lon` are now `kismet.common.location.geopoint`.

#### 2019-10

To more cleanly support ELK the advertised ssid and probed ssid components of dot11 devices are now serialized as vectors instead of maps.  Previously these were serialized as maps with a key of the hash of the SSID and attributes (an essentially meaningless number in the export).  Now these are sent as an array of advertised or probed SSID objects.


#### 2019-10

To more cleanly support ELK EKJSON format, the `ekjson` serialization now permutes the field names to transform all `.` to `_`.  This brings it in line with the ELK interpretation that a `.` is a field separator.  To access the old implementation, where the field names are unmodified, use the new `itjson` (or 'iterative json') format; it will return results which are a vector of objects as an object per line, suitable for serialized parsing and processing.

#### 2019-04

Kismet now requires authentication on *ALL* endpoints, with the exclusion of `/system/user_status`, `/session/check_login`, `/session/check_session`, and `/session/check_setup_ok`.

