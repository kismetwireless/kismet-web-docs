---
title: "Tuning"
description: ""
lead: ""
date: 2022-09-30T11:59:56-04:00
lastmod: 2022-09-30T11:59:56-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "tuning-c88670ce2d9fec1f2250904300eec070"
weight: 10
toc: true
---

## Kismet Memory and Processor Tuning

Kismet has several options which control how much memory and processing it uses.  These are found in `kismet_memory.conf`.  

Generally it is not necessary to tune these values unless you are running on extremely limited hardware or have a very large number of devices.

After 2026-10-R1, the web UI's [memory window](/docs/readme/webui/webui_intro/#memory-window) shows how much memory Kismet uses, how much each device costs, whether memory is growing, and the settings below which are in effect.

Modern Kismet can typically support tens to hundreds of thousands of tracked devices on most platforms, however running Kismet on a system with 1 gig or less of RAM will certainly benefit from tuning some of these options.


{{<configopt tracker_device_timeout seconds >}}
Kismet will forget devices which have been idle for more than the specified time, in seconds.

Kismet will also forget links between devices (such as access points and clients) when the device has been idle for more than the specified time.

This is primarily useful on long-running fixed Kismet installs.
{{</configopt>}}


{{<configopt tracker_max_devices devices >}}
Kismet will start forgetting the oldest devices when more than the specified number of devices are seen.

There is no terribly efficient way to handle this, so typically, leaving this option unset is the right idea.  Memory use can be tuned over time using the `tracker_device_timeout` option.
{{</configopt>}}


{{<configopt tcp_buffer_kb kb>}}
Kismet allocates a 512Kb buffer for incoming remote datasources, for each datasource.  On very RAM-limited devices, this may be a significant percentage of the available resources; The size of the buffer can be tuned.  Tuning this value too small may cause "buffer full" errors if the buffer cannot be serviced quickly enough.
{{</configopt>}}


{{<configopt ipc_buffer_kb kb>}}
Kismet allocates a 512Kb buffer for datasource IPC, for each datasource.  On very RAM-limited devices, this may be a significant percentage of the available resources; The size of the buffer can be tuned.  

Tuning this value too small may cause "buffer full" errors if the buffer cannot be serviced quickly enough.
{{</configopt>}}


{{<configopt keep_location_cloud_history true false>}}
Kismet normally tracks location history as a 'cloud' of locations where a device was seen, similar to a RRD (round robin database).  This data can be used to display device location with historic records and movement data.

This location cloud can be useful for plotting devices on a map, but also takes more memory per device.  

Disabling this will *not* disable tracking device locations, but *will* disable historic location tracking.
{{</configopt>}}


{{<configopt keep_per_datasource_stats true false>}}
Kismet can track the signal and packets of each device as seen by each datasource, in addition to the totals for the device.

This is used for comparing signal levels across many sensors, such as remote capture sources spread over an area, and for the per-datasource signal graph in the web UI, but uses more RAM for each device and each datasource.  It is disabled by default.
{{</configopt>}}


{{<configopt track_device_rrds true false>}}
Kismet keeps a short history of each device: packets, data, and packets sent and received over the past minute, hour, and day, and its signal.  Since Kismet 2026-10-R1 this includes the range of signal (the weakest and strongest reading) over the past minute, hour, and day, which adds roughly 2.5KB per device.  After 2026-10-R1 only the strongest reading is kept, which adds roughly 1.2KB per device.

These histories drive the graphs in the device details.  Disabling them saves RAM on very large captures, at the cost of those graphs; the device totals are still kept.
{{</configopt>}}


{{<configopt track_device_seenby_view true false>}}
Kismet provides device views automatically for each datasource.  This is used by the UI and may be used by scripts.

On a stand-alone system used for logging only, this can be turned off to save some RAM.
{{</configopt>}}


{{<configopt track_device_phy_view true false>}}
Kismet provides device views for each PHY type; this is used by the UI and may be used by scripts. 

On a stand-alone system used for logging only, this can be turned off to save some RAM.
{{</configopt>}}


{{<configopt manuf_lookup true false>}}
Kismet uses an OUI database to look up IEEE manufacturer information.

Indexing this database uses RAM, and each unique manufacturer found uses additional RAM. 

Disabling manufacturer lookup will save this RAM but will result in all devices having an unknown manufacturer in the UI and in logs.

Manufacturer data can be looked up post-capture by processing scripts.
{{</configopt>}}


{{<configopt alertbacklog number>}}
Kismet typically saves a backlog of the past 50 alerts, so that new clients connecting to the UI or scripts using polling-mode can obtain the backlog of alerts.

Setting this lower can save RAM at the cost of realtime display of alerts if the client does not refresh the alert list before they are lost. 

Alerts are still logged, and will not be lost from the log file.
{{</configopt>}}


{{<configopt packet_backlog_warning packets>}}
Kismet will start raising warnings when the number of packets waiting to be processed is over this number; no action will be taken, but an alert will be generated.

This can be set to zero to disable these warnings; Kismet defaults to zero.  Disabling these warnings will NOT disable the backlog limit warnings.

Through 2026-10-R1, Kismet only read this option by its old name, `packet_log_warning`, and ignored `packet_backlog_warning`.  After 2026-10-R1, `packet_backlog_warning` is read, and the old name still works.
{{</configopt>}}


{{<configopt packet_backlog_limit packets>}}
Kismet maintains input queues per processor core for handling incoming packets.  

This control is a *hard limit* on the number of packets in each queue.  If this is exceeded, packets will be dropped and not processed, logged, etc. 

Tuning this can reduce the total RAM used by Kismet, but if the processor cannot keep up with the packet load, will result in lost packets. 

If set to zero, Kismet will *never* drop packets, but this may lead to runaway RAM consumption if the processing power is also insufficient to clear the packet queue.
{{</configopt>}}


{{<configopt ulimit_mbytes megabytes>}}
Instruct Kismet to set an OS-level hard limit on the amount of RAM it is allowed to consume via the `ulimit` system in Linux.

This applies ONLY to Kismet on Linux-based hosts. 

If Kismet exceeds this value, it will *exit immediately* as if it had encountered an OS-wide out-of-memory condition.

This setting should ONLY be combined with a restart script that relaunches Kismet, and typically should only be used on long-running WIDS-style installs of Kismet.

If this value is set extremely low, Kismet may fail to start the webserver correctly or perform other startup tasks.  This value should typically only be used to control unbounded growth on long-running installs, and should be set above the high water mark of observed RAM use.

This is most useful to ensure that in a RAM starvation condition, Kismet is killed before the system-wide OOM handler kills other processes.

Some older kernels (such as those found on some Debian and Ubuntu versions still in LTS, such as Ubuntu 14.04) do not properly calculate memory used by modern allocation systems and will not count the memory consumed.  On these systems, it may be necessary to use externally-defined `cgroup` controls.
{{</configopt>}}


{{<configopt dot11_view_accesspoints true false>}}
Kismet provides a device view for Access Points; this is used by the UI and may be used by scripts. 

Turning this off may break some scripts, and will definitely break the "Access Points Only" view in the UI.  It will also disable any features which rely on processing the list of access points.

On a stand-alone system used for logging only, this can be turned off to save some RAM, but may remove other features as well.
{{</configopt>}}


{{<configopt dot11_view_ssids true false>}}
Kismet provides a SSID view to explore observed Wi-Fi networks. 

Turning this off may break some scripts, and will definitely break the "SSIDs" tab of the UI.

Turning this off will not affect associating SSIDs with access points or displaying them inside the device details.
{{</configopt>}}


{{<configopt dot11_max_ssid_groups ssids>}}
The most SSIDs the SSID view keeps (default 10000).  Probe requests can name any SSID, so in a busy area, or with someone sending random probes, the list can grow without limit.

When there are more than this, Kismet drops the oldest-seen tenth of them.  Each SSID also tracks at most 4096 devices advertising, probing for, or answering for it.

Set to `0` for no limit.
{{</configopt>}}


{{<configopt dot11_fingerprint_devices true false>}}
Kismet does advanced fingerprinting of 802.11 devices. 

Turning this off will disable some alerts and fingerprint based checks.

This will save some CPU.
{{</configopt>}}


{{<configopt dot11_keep_ietags true false>}}
Off by default, Kismet can store and display the IE tag component of beacons at the cost of RAM and CPU per network. 

As of `after 2026-10-R1`, the stored tags are refreshed when the beacon tags change, but not when only the contents of the TIM (tag 5) or the QBSS load (tag 11) change.  Those two change with almost every beacon, so the stored copies of them may be older than the last beacon seen; the QBSS station count and channel load in the SSID record are still updated from every beacon.
{{</configopt>}}


{{<configopt dot11_keep_eapol true false>}}
Kismet caches the last 16 EAPOL messages (WPA handshakes) per client per BSSID.  

This is used for WIDS detection of EAPOL replay attacks like KRACK, and for generating handshake capture files.

Turning this off will disable WPA handshake downloading in the UI and prevents EAPOL replay alerts from functioning.

Handshakes can still be extracted from the kismetdb and PCAP logs.
{{</configopt>}}


{{<configopt dot11_track_control true false>}}
On by default as of `after 2026-10-R1`.  Kismet counts the control frames (RTS, CTS, ACK, block ACK, NDP announcement, and PS-Poll) that name a device it already knows, in `dot11.device.ctrl_activity`.  Control frames are sent at a basic rate, so they can be heard when a device's own data is at a rate or stream count the capture can't decode, or when the device is out of range.  A device with control frames but no data frames is flagged as `dot11.ctrl.control_only`.

Each access point also counts the stations it exchanged control frames with that aren't known devices, in `dot11.device.ctrl_only_stations`: likely clients that the capture can't hear directly.  Only frames with a verified checksum count, so sources that don't report the frame checksum never fill this in; at most 64 stations are kept per access point, and the count covers the 5 minutes (by capture time) before the newest one, whose time is in `dot11.device.ctrl_only_stations_last`.

Control frames never create devices unless `dot11_infer_clients` is on.  Most capture drivers don't pass control frames at all, so these fields only appear with sources that do.

The web UI shows these in a "Control frames" section of the Wi-Fi device details, a "Hidden stations" device list column, and an optional "Seen only in control frames" row highlight.

Turning this off saves a device lookup per control frame and the per-device record.
{{</configopt>}}

{{<configopt dot11_infer_clients false true>}}
Off by default; added `after 2026-10-R1`.  Needs `dot11_track_control`.  A station that is seen only in control frames with an access point, and never directly, becomes a "Wi-Fi Client (Inferred)" device linked to that access point.  To keep a corrupted address from becoming a device, the station has to appear in at least `dot11_infer_min_frames` frames (default 10) with a verified checksum, over at least `dot11_infer_min_seconds` seconds (default 10) of capture time.

An inferred client takes its signal level only from frames it sent.  If it is later seen in a management or data frame, it becomes a normal "Wi-Fi Client".  Inferred clients aren't written to WiGLE logs.

Stations waiting to reach the threshold are kept in a table of up to 4096 addresses; the least recently seen is dropped when it's full.  `/phy/phy80211/inferred_clients` reports whether inference is on, how many stations are waiting, and how many have been inferred or dropped.
{{</configopt>}}

{{<configopt dot11_infer_min_frames 10 20>}}
Frames with a verified checksum a station needs before `dot11_infer_clients` makes it a device.  At least 2.
{{</configopt>}}

{{<configopt dot11_infer_min_seconds 10 30>}}
Capture time, in seconds, between a station's first and last counted frame before `dot11_infer_clients` makes it a device.
{{</configopt>}}


{{<configopt dot11_channel_noise true false>}}
On by default; added `after 2026-10-R1`.  Kismet counts retried Wi-Fi data and management frames per channel (`kismet.channelrec.retry_*` in [/channels/channels](/docs/api/channels/)), and flags channels that look noisy:  many retries, from several transmitters, can mean interference Kismet can't decode.

Every `dot11_channel_noise_window` seconds, each frequency's retry percentage is worked out with its worst transmitter left out, so one station retrying to a far-away peer doesn't mark the channel.  The score is that percentage, scaled down while fewer than `dot11_channel_noise_min_frames` frames, or fewer than `dot11_channel_noise_min_transmitters` transmitters with 2 or more retries, are heard.  The channel is flagged, and the `CHANNOISE` alert raised, when the score reaches `dot11_channel_noise_retry_pct`; the flag clears when the score falls below `dot11_channel_noise_clear_pct`.  Windows with too few frames leave the flag as it is, and it clears after `dot11_channel_noise_hold` seconds without a full window.  The usual retry level (`noise_baseline_pct`) is learned only from windows that aren't flagged.

The web UI shows the retry percentage and the flag in the Wi-Fi airspace view and the channel picker.

A hopping source hears each channel only part of the time, so it needs a longer window.  Missed frames raise the retry percentage, so a busy channel or a weak capture radio can look noisier than it is.
{{</configopt>}}

{{<configopt dot11_channel_noise_window 10 30>}}
Seconds per window, from 1 to 600.
{{</configopt>}}

{{<configopt dot11_channel_noise_min_frames 50 100>}}
Frames in a window before the score counts in full; windows with fewer leave the flag as it is.
{{</configopt>}}

{{<configopt dot11_channel_noise_min_transmitters 3 5>}}
Transmitters with 2 or more retries in a window before the score counts in full, from 1 to 32.
{{</configopt>}}

{{<configopt dot11_channel_noise_retry_pct 30 40>}}
Score at which a channel is flagged.
{{</configopt>}}

{{<configopt dot11_channel_noise_clear_pct 15 20>}}
Score below which the flag clears; no higher than `dot11_channel_noise_retry_pct`.
{{</configopt>}}

{{<configopt dot11_channel_noise_hold 60 300>}}
Seconds without a full window before the flag clears; at least one window.
{{</configopt>}}

## Runtime type checking

Kismet uses a dynamic type system to store data in a way that can be serialized into JSON for logging, the web UI, etc.

As of `2022-08`, run-time type checking on this system is disabled by default in the configuration scripts; much of the type control is now implemented at compile time, and type errors are exposed during the development and debug process.

Runtime type checking must be controlled at compile time:

```bash
$ ./configure --enable-element-typesafety
```

## Extremely large numbers of data sources

Using large numbers of *local* datasources (large being a difficult to define quantity, but often over 12 on an Intel system or 6 on a system like a Raspberry Pi 4) can introduce new instabilities and concerns; depending highly on the device types used, the Linux kernel version, and driver versions.

Modern kernels (Linux 5.10 and newer) include mitigations for some of the most disruptive aspects of running many sources at once, however many systems begin to show problems with the USB bus and even the PCI-E system depending on the drivers used.

Generally speaking, for extremely large numbers of datasources, the best success has been found with:

* Using PCI-E based devices 

    The USB subsystem and drivers appear to be most negatively impacted by large numbers of capture devices. 

    Using a PCI-E expander, Thunderbolt expansion, and similar, has been used with general success with 12 or more capture interfaces.

* Splitting capture over multiple physical hosts 

    Kismet remote capture allows the capture devices themselves to be split across multiple hosts. 

    While the most expensive option, this has been the most successful; by splitting the load of driving the interfaces across multiple hosts, most of the problems encountered can be mitigated.

    Multiple capture hosts should be linked via wired Ethernet to a single, very capable processing and logging host. 

* Maximize CPU and storage speed 

    Capturing from a large number of sources will be extremely costly in terms of RAM, processing, and importantly, storage speed. 

    Typically when copying full streams from a large number of sources, you will need a SSD based storage system, and as much RAM and CPU as possible, with the highest per-core performance possible.

### Staggering startup

Some drivers and kernels seem especially impacted when first setting a very large number of interfaces to monitor mode; this can lead to timeouts or even kernel crashes on some drivers.  

More modern changes in Kismet mitigate the need for tuning these options *most* of the time, but they remain in case specific situations require them:

{{<configopt source_stagger_threshold number>}}
This determines when Kismet will start staggering local source bring-up - if you have more than this number of sources defined, Kismet will slow down the startup process.
{{</configopt>}}


{{<configopt source_launch_group number>}}
This determines how many sources will be brought up at a time.
{{</configopt>}}

{{<configopt source_launch_delay seconds>}}
The number of seconds between launching each group of sources.
{{</configopt>}}

After 2026-10-R1, a configured source that no driver claims when it's first probed (often because the system is busy bringing up many sources at once) is probed twice more, 5 seconds apart, before Kismet gives up on it.  When it does give up, the error includes what the driver that found the interface said, such as why Kismet couldn't read its channels.


While the default values may be sane for your application, adding this many local sources to Kismet implies an advanced configuration - you may find benefit to tuning these options for your specific configuration.

You may also find it necessary to decrease the channel hopping speed to alleviate contention in the kernel.  This can be especially true with some drivers, such as the rtl8812au/rtl88xx drivers, which have severe contention when setting channels.

When running an extremely large number of sources, remember also that Kismet will likely require a significant amount of CPU and RAM for the additional data being gathered.

## Disabling auto-probe and auto-list of source types

Some systems (specifically embedded systems running OpenWRT, but also others) may have sufficient CPU and RAM to run remote capture (or even local capture) of complex datasources, like rtladsb, but take so long to bring up the environment that it causes disruption to Kismet autodetecting devices or listing available interfaces.

If this is the case, those datasource types can be masked from discovery, using the `mask_datasource_type` configuration option:

```
mask_datasource_type=rtladsb
mask_datasource_type=rtlais
mask_datasource_type=rtl433
```

and so on.

Masked types will NOT be able to autodetect the interface, and MUST have a `type=...` in the source definition, such as:
`source=rtladsb-0:type=rtladsb,name=foo,...`.

Masked types will NOT show up in the data sources UI.

