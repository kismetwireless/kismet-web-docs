---
title: "Ethernet (IEEE802.3)"
description: ""
lead: ""
date: 2026-11-21T10:00:00-05:00
lastmod: 2026-11-21T10:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "ethernet-1636fdadc1af405bb2272aa92eded78a"
weight: 372
toc: true
---

After 2026-10-R1, the Kismet `IEEE802.3` phy tracks wired Ethernet devices, from the [wired data source](/docs/readme/datasources/wired-linux/) and from pcap and kismetdb replays of Ethernet captures.  Ethernet devices are listed in the `phy-IEEE802.3` [device view](/docs/api/device_views/), and carry an `ethernet.device` record:

| Field | Contents |
| ----- | -------- |
| `ethernet.device.vlans` | VLANs the device sent on, each with `ethernet.device.vlan.tags` (1 for 802.1Q, where VLAN 0 is priority tagged; 2 or more for QinQ), `.vid` (outer tag), `.inner_vid` (second tag, 0 with one tag), `.first_time`, `.last_time`, and `.packets` |
| `ethernet.device.ipv4`, `ethernet.device.ipv6` | Addresses, each with `ethernet.device.ip.address`, `.source` (`arp`, `dhcp`, `dhcpv6`, or `traffic`), `.first_time`, and `.last_time` |
| `ethernet.device.names` | Names the device announced, each with `ethernet.device.name.name` (unprintable bytes escaped), `.source` (`dhcp_hostname`, `dhcp_fqdn`, `dhcpv6_fqdn`), `.first_time`, and `.last_time` |
| `ethernet.device.dhcp_prl`, `.dhcp_vendor`, `.dhcp_client_id` | DHCP parameter request list (option 55), vendor class (option 60), and client ID (option 61, hex) |
| `ethernet.device.dhcpv6_duid`, `.dhcpv6_vendor`, `.dhcpv6_oro` | DHCPv6 client DUID (hex), vendor class, and option request list |
| `ethernet.device.tx_bytes`, `ethernet.device.rx_bytes` | Bytes sent, and received as a unicast destination |
| `ethernet.device.tx_unicast`, `.tx_multicast`, `.tx_broadcast` | Frames sent, by kind of destination |
| `ethernet.device.protocols` | Protocols sent, a bitfield: 1 ARP, 2 IPv4, 4 IPv6, 8 TCP, 16 UDP, 32 ICMP, 64 ICMPv6, 128 DHCP, 256 DHCPv6, 512 LLC, 1024 VLAN tagged, 2048 QinQ, 4096 other |
| `ethernet.device.roles` | Roles seen, a bitfield: 1 DHCP server, 2 DHCPv6 server, 4 gateway (named in a DHCP router option), 8 DNS server (named in a DHCP DNS option) |

The [field list](/docs/api/exploring/) of a running server gives every field, with its description.

{{< kismet_api ethernet >}}
