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


{{<configopt keep_datasource_signal_history true false>}}
Kismet tracks signal history for each device, as seen by each datasource.

This is used for tracking signal levels across many sensors, but uses more RAM.
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


{{<configopt packet_dedup_size packets>}}
When using multiple datasources, Kismet maintains a system to identify duplicate packets captured from multiple sources.

This system prevents multiple copies of the same packet triggering alerts incorrectly, and allows multiple datasources to contribute to the signal levels of the captured packet.

Tuning this value will save some RAM, but not a significant amount.
{{</configopt>}}


{{<configopt packet_backlog_warning packets>}}
Kismet will start raising warnings when the number of packets waiting to be processed is over this number; no action will be taken, but an alert will be generated.

This can be set to zero to disable these warnings; Kismet defaults to zero.  Disabling these warnings will NOT disable the backlog limit warnings.
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


{{<configopt dot11_fingerprint_devices true false>}}
Kismet does advanced fingerprinting of 802.11 devices.

Turning this off will disable some alerts and fingerprint based checks.

This will save some CPU.
{{</configopt>}}


{{<configopt dot11_keep_ietags true false>}}
Off by default, Kismet can store and display the IE tag component of beacons at the cost of RAM and CPU per network.
{{</configopt>}}


{{<configopt dot11_keep_eapol true false>}}
Kismet caches the last 16 EAPOL messages (WPA handshakes) per client per BSSID.

This is used for WIDS detection of EAPOL replay attacks like KRACK, and for generating handshake capture files.

Turning this off will disable WPA handshake downloading in the UI and prevents EAPOL replay alerts from functioning.

Handshakes can still be extracted from the kismetdb and PCAP logs.
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

More modern changes in Kismet mitigates the need for tuning these options *most* of the time, but they remain in case specific situations require them:

{{<configopt source_stagger_threshold number>}}
This determines when Kismet will start staggering local source bring-up - if you have more than this number of sources defined, Kismet will slow down the startup process.
{{</configopt>}}


{{<configopt source_launch_group number>}}
This determines how many sources will be bought up at a time.
{{</configopt>}}

{{<configopt source_launch_delay seconds>}}
The number of seconds between launching each group of sources.
{{</configopt>}}


While the default values may be sane for your application, adding this many local sources to Kismet implies an advanced configuration - you may find benefit to tuning these options for your specific configuration.

You may also find it necessary to decrease the channel hopping speed to alleviate contention in the kernel.  This can be especially true with some drivers, such as the rtl8812au/rtl88xx drivers, which have severe contention when setting channels.

When running an extremely large number of sources, remember also that Kismet will likely require a significant amount of CPU and RAM for the additional data being gathered.

## Disabling auto-probe and auto-list of source types

Some systems (specifically embedded systems running OpenWRT, but also others) may have sufficient CPU and RAM to run remote capture (or even local capture) of complex datasources, like rtladsb, but take so long to bring up the environment that it causes disruption to Kismet autodetecting devices or listing available interfaces.

If this is the case, those datasource types can be masked from discovery, using the `mask_datasource_type` configuration option:

```
mask_datasource_type=rtladsb
mask_datasource_type=rtlamr
mask_datasource_type=rtl433
```

and so on.

Masked types will NOT be able to autodetect the interface, and MUST have a `type=...` in the source definition, such as:
`source=rtladsb-0:type=rtladsb,name=foo,...`.

Masked types will NOT show up in the data sources UI.
