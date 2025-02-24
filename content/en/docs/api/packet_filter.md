---
title: "Packet filters"
description: ""
lead: ""
date: 2022-11-03T22:52:15-04:00
lastmod: 2022-11-03T22:52:15-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "packet_filter-72f6ca0ed29c3d0aeb16c86a13678f52"
weight: 310
toc: true
---

Packet filtering in Kismet can be used to limit the packets; typically to prevent the packets from being logged, returned in packet streams, and similar functions.

The packet filtering system uses a common endpoint layout mapped to different components.

### Filter logic

Kismet filters *block* packets when active.  A *positive* match on a filter will *exclude* the packet.

Filter terms may match on packet attributes, dependent on the type of filter.  Matches can operate as `filter` or `pass` to explicitly allow or block a match.

Packets which do not match any filter terms are handled by the filter default behavior, which can be used to accept or reject all non-matching packets.

The filter engine recognizes several terms when setting filtering:  `true`, `reject`, `deny`, `filter`, and `block` are synonymous and tell the filtering system to exclude a matching packet. `false`, `allow`, `pass`, and `accept` are synonymous for allowing a packet to pass the filter and be processed.

### MAC address filters

MAC address filters use the filter type `mac_filter`, and filter (perhaps obviously) on MAC addresses.

MAC filters can be applied to:

* *source* - Original source device.  In Wi-Fi networks, equivalent to the source MAC; in other phy types, typically the originating device.
* *destination* - Target device.  In Wi-Fi networks, the destination MAC; in other phy types, if present, the equivalent destination address.
* *network* - Associated network.  In Wi-Fi, this is the BSSID.
* *other* - Other address; in Wi-Fi this is the fourth MAC found in WDS; in other phy types it represents some form of alternate address.
* *any* - Matching any of the address fields.

Address filters are applied in the order:  `source`, `destination`, `network`, `other`, `any`, `default`.  If an address is accepted by the `source` stage and would be rejected by the `destination` stage, the filter will *accept* the packet, as this is the first operation.

{{< kismet_api packet_filters >}}
