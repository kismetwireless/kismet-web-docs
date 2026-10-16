---
title: "Wi-Fi: OpenBSD"
description: ""
lead: ""
date: 2026-10-15T20:45:33-04:00
lastmod: 2026-10-15T20:45:33-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "wifi-openbsd-83ef9041cf6141e68aeb067c72073d1f"
weight: 107
toc: true
---

Added: `2024-01`

The OpenBSD Wi-Fi source captures from Wi-Fi interfaces on OpenBSD, using the net80211 monitor mode support and libpcap.

The OpenBSD Wi-Fi source is still under development, and has significant limitations; see [Limitations](#limitations) below.

The source should be configured with the type set explicitly:

```
source=iwm0:type=openbsdwifi
```

## Supported hardware

Any OpenBSD Wi-Fi interface supporting monitor mode can be used.  Interfaces in the `wlan` interface group are listed as available sources.

## Compiling OpenBSD Wi-Fi support

OpenBSD Wi-Fi support is built automatically when compiling Kismet on OpenBSD, and requires libpcap.

The capture tool must run as root to control the interface; install it with `make suidinstall`, or run Kismet as root.

On other platforms the OpenBSD Wi-Fi source can only be used as a [remote capture](/docs/readme/remotecap/remotecap/) from an OpenBSD system.

## Kismet OpenBSD Wi-Fi support

When the source is opened, Kismet places the interface in monitor mode and brings it up.  Kismet also assigns a random MAC address to the interface.

Packets are captured with radiotap headers and processed as normal 802.11 frames.

## OpenBSD Wi-Fi source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

### Channel options

The OpenBSD Wi-Fi source supports the common [channel and hopping](/docs/readme/datasources/channelhop/) options.  The channel list is read from the interface.

{{<configopt channel "channel number">}}
The channel to tune to when the source opens.
{{</configopt>}}

### Filtering options

{{<configopt filter_mgmt true false>}}
Only capture management frames and EAPOL frames.
{{</configopt>}}

{{<configopt truncate_data true false>}}
Truncate data frames to the 802.11 header, while keeping EAPOL frames.
{{</configopt>}}

### Debugging options

{{<configopt verbose true false>}}
Report when setting a channel takes longer than 100ms.
{{</configopt>}}

{{<configopt statistics true false>}}
Report the average time taken to set the channel, every 100 channel changes.
{{</configopt>}}

## Limitations

The OpenBSD Wi-Fi source currently has these limitations:

* Only 2.4GHz channels are tuned correctly.  HT and VHT channels (such as `6HT40+`) are not supported.
* The `ht_channels`, `vht_channels`, `default_ht20`, `expand_ht20`, `band24ghz`, `band5ghz`, and `band6ghz` options are accepted for compatibility with the Linux Wi-Fi source, but have no effect.
* The `filter_locals`, `filter_interface`, and `filter_address` options are accepted, but no filter is applied.
* The source does not auto-detect interfaces reliably; always set `type=openbsdwifi`.
* The interface MAC address is changed when the source opens, and the source UUID is generated from it, so the UUID changes each time the source opens.  Set a fixed UUID with the `uuid=` option if needed.
