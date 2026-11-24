---
title: "Ethernet: Linux wired"
description: ""
lead: ""
date: 2026-11-21T10:00:00-05:00
lastmod: 2026-11-21T10:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "wired-linux-94a62fc1e2e64b8cb90821a5b534b172"
weight: 180
toc: true
---

Added: after `2026-10-R1`

After 2026-10-R1, Kismet tracks wired (Ethernet, IEEE 802.3) devices, as the `IEEE802.3` phy.  Ethernet frames come from:

* The `wired` data source, which captures live from Ethernet interfaces on Linux (`kismet_cap_wired`), locally or as a [remote capture](/docs/readme/remotecap/remotecap/).
* [Pcap files](/docs/readme/datasources/pcapfile/) and [kismetdb logs](/docs/readme/datasources/kismetdb/) of Ethernet frames (`DLT_EN10MB`), and Linux cooked captures of the `any` interface.

Devices are tracked by MAC address.  Only a MAC which sends a frame becomes a device; a destination only updates a device already seen.  Each device lists:

* The VLANs it sent on, with one tag (802.1Q; VLAN 0 is priority tagged) or two or more (QinQ).
* Its IP addresses, and where each came from: ARP, DHCP, DHCPv6, or the traffic it sends.
* Names from DHCP and DHCPv6 (the hostname and FQDN), and its DHCP details (client ID, vendor class, parameter request list, DHCPv6 DUID).
* Bytes and frames sent and received, the protocols it sends (ARP, IPv4, IPv6, TCP, UDP, ICMP, and so on), and roles seen, such as DHCP server or gateway.
* The IP flows it takes part in.

Devices are typed *Ethernet Device*, *Ethernet Router*, or *Ethernet Server*, with the simple type `Ethernet`.  The sensor's GPS position is never used as an Ethernet device's position, and `kismetdb_to_kml` and `kismetdb_to_gpx` leave Ethernet devices out.

## Compiling wired support

The wired source is built by default on Linux when libcap is available; configure prints `Wired (Ethernet): yes`, or why it isn't built.  `--disable-wired` turns it off.  It is Linux only.

## Adding the source

The source type is `wired`.  An Ethernet interface given without `type=` is detected as wired:

```bash
kismet -c eth0
```

```
source=eth0:type=wired
source=eth0:type=wired,name=uplink,snaplen=256,filter="not port 22"
```

Only Ethernet interfaces are accepted: loopback, Wi-Fi interfaces (use the [Linux Wi-Fi](/docs/readme/datasources/wifi-linux/) source), and non-Ethernet interfaces such as `tun` are refused.  Bridges, bonds, VLAN interfaces, and veths are Ethernet to the kernel and can be captured.

`kismet_cap_wired --list`, and the data sources window of the web UI, list at most 256 interfaces: NICs first, then bridges, bonds, VLANs and other virtual interfaces, then veth and tap interfaces, so the NICs of a container or VM host are always offered.

By default the source brings a down interface up (see [`ifup`](#ifup)), and an interface which is up transmits on its own: the kernel sends IPv6 link-local traffic and router solicitations, and a network manager which owns the interface may start DHCP on it.

## Permissions

`kismet_cap_wired` needs `CAP_NET_RAW` to capture, and `CAP_NET_ADMIN` only to bring a down interface up.  It is not installed setuid; `make suidinstall` gives it both as file capabilities:

```bash
sudo setcap cap_net_raw,cap_net_admin+ep /usr/local/bin/kismet_cap_wired
```

`setcap cap_net_raw+ep` alone works for interfaces which are already up.

Before it connects to anything, the helper hands `CAP_NET_ADMIN` to a small child process which can only set an Ethernet interface up, and which exits with the helper.  The capture itself keeps only `CAP_NET_RAW`, drops every other capability, and exits if it can't, saying why in the server's messages.

The helper refuses to capture as root:

* Started as root (by a server running as root, or setuid root), it switches to the user who started it, or to `nobody` when that was root, keeping only `CAP_NET_RAW`.  Root without `CAP_SETUID` and `CAP_SETGID`, such as a container started with `--cap-drop ALL --cap-add NET_RAW`, can't switch; run it there as a user with the file capability.
* A gid 0 or supplementary group 0 is left the same way; without `CAP_SETGID` the helper exits.  Containers which run every process with gid 0, as OpenShift does by default, need another group for the helper.
* With root's uid or group it starts no ifup child and brings no interface up.
* In a user namespace (a rootless or user-namespaced container) it checks what its ids are outside the namespace, and exits when they are unmapped or root's.  It needs `/proc` for this.  Supplementary groups from outside the namespace show as 65534 and might be root's, so they are refused too; plain `unshare -r` by a user with groups is refused for that reason.  Namespaces made with `newuidmap` and `newgidmap` (`unshare --map-auto`, rootless podman) work.

Once its privileges are dropped it sets `no_new_privs`.

## Remote capture

As a [remote capture](/docs/readme/remotecap/remotecap/), the helper leaves out of the capture all TCP to and from the server's address and port, so it doesn't capture its own connection (or those of other helpers on the same sensor) and send it again in a loop.  This covers untagged frames and frames behind up to three VLAN tags, whatever `filter=` says.  `kismet.datasource.wired.remote_excluded` is true when the connection's interface is the captured one, or sits on it through VLANs, bridges, bonds, teams, macvlans or ipvlans; the source warns when it can't tell.

Only the connection as the helper sees it is left out.  Through an SSH forward, a VPN, or another tunnel, the frames on the wire are the tunnel's and are captured; if the tunnel runs over the captured interface, every frame sent comes back as more tunnel traffic.  The same goes for policy-based IPsec, MACsec, VXLAN, PPPoE and MPLS.  Leave the tunnel out with a filter, such as `filter="not port 22"` for SSH, the VPN's port, or `"not esp"` for IPsec, or capture another interface.

## NIC offloads

GRO and LRO merge received frames into one large frame, TSO and GSO send large frames the wire never carries, and `rx-vlan-filter` can drop frames for VLANs the host isn't a member of.  The source lists the offloads which are on in `kismet.datasource.wired.offloads`, and leaves them alone.  Merged frames only make packet counts low, so the source only warns for `rx-vlan-filter` on an interface which isn't promiscuous, where whole VLANs go missing.  Turn offloads off with `ethtool`, for example `ethtool -K eth0 gro off lro off`; the warning goes once the offload is off.

## VLANs

VLAN tags are seen in captures of a single interface (`DLT_EN10MB`): the Linux kernel strips the tag, and libpcap puts it back.  Captures of the `any` interface (Linux cooked SLL2) have been seen without their tags, so their VLANs are not shown.

## Privacy

Full mode sends frame contents, up to `snaplen`, to the server, and they are logged to the pcap and kismetdb logs when packet logging is on.  Use a small `snaplen` (such as `128`, headers only) or a filter where payloads should not be kept.  Flows are kept in memory only, and never logged.

## Viewing

In the new web UI, Ethernet devices have their own icons, *VLAN*, *IP*, and *Hostname* columns, and details with their addresses, names, DHCP details, and flows.  Once the server has Ethernet devices, the *Ethernet flows* tab, after *Map*, lists the IP flows, filtered by device or VLAN when opened from one, and the *Ethernet VLANs* window, from the menu, lists the VLANs seen.  Both say so when devices or flows weren't kept because of the limits below.

Clicking a flow in the list opens its details window, with each side's addresses, MAC and linked devices, and graphs of the flow's traffic each way over the past minute, hour or day once it has a history.  A flow which has gone keeps its last numbers, with a button to check again.  The *Flow table* section of the *Ethernet flows* tab graphs the whole table: flows in the table, new and deferred or dropped flows, and bytes and packets per second.

The data is also available from the [Ethernet API](/docs/api/ethernet/).

## Wired source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

An option the source doesn't know, such as a misspelled one, is reported in the messages when the source opens, and otherwise ignored.

### mode

{{<configopt mode full>}}
Every frame is sent to the server.  This is the only mode for now, and a source without `mode=` runs in full mode.  A later version will add a summary mode and require `mode=full` to keep sending every frame, so set it now on sources which need it.
{{</configopt>}}

### snaplen

{{<configopt snaplen bytes>}}
Bytes kept of each frame, `96` to `15872`; default `1600`.  A frame and its report must fit in one 16KB message to the server, so jumbo frames past this are cut short.  A remote helper with a fixed GPS (`--fixed-gps`, `--gps-name`) sends the GPS name with every frame, so its maximum is less by the name's length.
{{</configopt>}}

### buffer_mb

{{<configopt buffer_mb mb>}}
Kernel capture buffer in MB, `1` to `1024`; default `64`.  Raise it when the source reports kernel drops.
{{</configopt>}}

### promisc

{{<configopt promisc true false>}}
Promiscuous mode; default `true`.  Without it only frames to and from the sensor, and broadcast and multicast, are seen.
{{</configopt>}}

### ifup

{{<configopt ifup true false>}}
Bring the interface up when it is down at open; default `true`.  Only the interface's up flag is changed, and the interface is never taken down again: it stays up when the source closes, as Wi-Fi sources leave theirs.  The source's messages say when it brought the interface up, failed opens included.

This needs `CAP_NET_ADMIN`; without it, or with `ifup=false`, opening a down interface fails, saying to run `ip link set eth0 up`.  Option and filter mistakes fail before anything is brought up.  A link without a carrier yet, such as a USB adapter still negotiating, is fine; the carrier warning shows until it comes up.
{{</configopt>}}

### filter

{{<configopt filter "expression">}}
A libpcap (tcpdump) filter, in quotes, up to 1024 printable ASCII characters with balanced parentheses.  As in tcpdump, `arp` or `udp` match untagged frames; add `vlan and ...` or `or (vlan and ...)` for tagged frames.  `ip broadcast` uses the interface's IPv4 netmask, and fails before the interface is brought up when it has none.

```
source=eth0:type=wired,filter="not port 22"
```
{{</configopt>}}

### sample

{{<configopt sample n>}}
Send only the first frame of every `n`, `1` to `1000000`; default `1`.  The source still counts every frame it saw.
{{</configopt>}}

### uuid

{{<configopt uuid uuid>}}
A fixed source UUID.  By default it comes from the interface name and MAC, so VLAN interfaces, bridges, and bonds which share a MAC with their parent each get their own.
{{</configopt>}}

## Source status

Each wired source reports, in its data source record:

| Field | Contents |
| ----- | -------- |
| `kismet.datasource.wired.kernel_received` | Frames the kernel received for the capture since the source opened |
| `kismet.datasource.wired.kernel_drops` | Frames the kernel dropped because the capture fell behind |
| `kismet.datasource.wired.if_drops` | Frames the interface or its driver dropped |
| `kismet.datasource.wired.frames` | Frames the helper captured, before sampling |
| `kismet.datasource.wired.forwarded` | Frames the helper sent to the server |
| `kismet.datasource.wired.sample` | 1 in this many frames is sent |
| `kismet.datasource.wired.snaplen` | Most bytes of each frame captured |
| `kismet.datasource.wired.buffer_mb` | Kernel capture buffer, MB |
| `kismet.datasource.wired.promisc` | The interface is promiscuous |
| `kismet.datasource.wired.remote_excluded` | A remote helper's own connection is left out of the capture |
| `kismet.datasource.wired.carrier` | Link state: `up`, `down`, or empty when the helper can't tell |
| `kismet.datasource.wired.offloads` | NIC offloads which are on and change what the capture sees, comma separated |

## Ethernet options

These go in `kismet_wired.conf`, or better, in [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf).  They apply to Ethernet frames from every source, pcap files included.

{{<configopt wired_max_devices count>}}
The most Ethernet devices tracked; default `16384`, `0` for no limit.  A MAC flood (`macof` and similar) sends from a new random MAC with every frame, so without a limit it can fill memory.  Each device takes about 17 to 20KB.

Once reached, new MACs are counted (see the [status endpoint](/docs/api/ethernet/)) but not tracked, except that a MAC seen again replaces the oldest device which sent only a frame or two (up to 100 a second), so real hosts arriving during a simple flood still get tracked.  A flood sending three or more frames from each MAC makes devices which are never evicted; new hosts then aren't tracked until the flood's devices time out or the limit is raised.
{{</configopt>}}

{{<configopt wired_new_device_rate count>}}
New Ethernet devices allowed per second of capture time; default `200`, `0` for no limit.  MACs past the rate are counted but don't make devices; a MAC which keeps sending gets a second budget of the same size.  The budget follows the capture's timestamps, not how fast a file is read, so a pcap read at full speed still gets this many new devices per second recorded in it.  Raise it, or set `0`, to keep every device from a capture of a large network.
{{</configopt>}}

{{<configopt wired_learn_remote_ips true false>}}
List every address a device sends IP traffic from; default `false`.  By default only local addresses are listed from traffic: RFC 1918 private, `100.64/10`, link-local, IPv6 ULA, and the subnets DHCP and DHCPv6 hand out.  A router forwards traffic from every remote address, which would otherwise fill its list.  Addresses from ARP and DHCP are always listed.
{{</configopt>}}

{{<configopt wired_max_flows count>}}
The most IP flows (addresses, ports, protocol, and VLAN) kept in memory; default `16384`, `0` turns flow tracking off.  About 156 bytes each.  Past 90% full, a new flow is only kept once a second packet of it is seen, so a scan of single packets can't fill the table.

The flow table hash is seeded at random each time the server starts, as are the IP table and VLAN inventory, so traffic can't be crafted to fall in one part of the table.
{{</configopt>}}

{{<configopt wired_flow_full evict drop>}}
What happens to a new flow when the flow table is full; default `evict`.

With `evict`, the new flow replaces an idle one, once a second packet of it is seen, so single packets can't replace anything.  Up to 8 flows in the part of the table the new flow belongs to are looked at: a TCP flow which has closed (FIN or RST seen) goes first, then one without a traffic history, then the one idle longest.  A flow with a packet in the last 10 seconds (1 second for a closed TCP flow) is never replaced; when every flow looked at is that recent, the new flow is dropped.  Replaced flows are counted in `ethernet.status.flows_evicted`.

With `drop`, every new flow is dropped until flows time out.
{{</configopt>}}

{{<configopt wired_flow_tcp_timeout seconds>}}
Seconds a TCP flow can be idle before it's forgotten; default `300`.  `wired_flow_tcp_closed_timeout` (default `10`) is used after a FIN or RST, and `wired_flow_udp_timeout` (default `60`) for UDP and other protocols.  Idle time is measured on the server clock, so replaying an old capture doesn't expire its flows at once.
{{</configopt>}}

{{<configopt wired_flow_history_max count>}}
The most flows which keep a traffic history; default `4096`, `0` turns history off.  A history holds bytes and packets each way, per second over the last minute, per minute over the last hour, and per hour over the last day, by the server clock.  About 3.2KB each (13MB at `4096`).  It is never more than `wired_max_flows`, and at most `65536`.  History is kept in memory only.
{{</configopt>}}

{{<configopt wired_flow_history_min_packets count>}}
Packets of a flow, both ways, seen before it gets a traffic history; default `8`, `1` to `1000000`.  Lookups and scans don't take histories this way; a flow's first packets aren't in its history.
{{</configopt>}}

{{<configopt wired_flow_history_idle seconds>}}
Once 90% of the histories are in use, flows idle this many seconds give theirs back; default `60`, `10` to `86400`.
{{</configopt>}}

A flow and its history are served by the [flow by key endpoint](/docs/api/ethernet/#ethernet-flow-by-key), with the key from the flow's `ethernet.flow.key` in the flow list; a flow which has expired is not found.  The history of the whole flow table (flows in the table, new and refused flows, bytes and packets per second) is served by the [flow table history endpoint](/docs/api/ethernet/#ethernet-flow-table-history), and is kept whether or not flows keep histories.

## Linking wired and Wi-Fi devices

After 2026-10-R1, a Wi-Fi device and an Ethernet device with the same MAC are linked, so what a tap on the wire saw a wireless device do (its addresses, names, DHCP fingerprint, VLANs, sensors, traffic and flows) can be found from its Wi-Fi record.  The two records stay separate: a linked pair shares `kismet.device.base.entity_id`, each lists the other in its related devices, and the [linked devices API](/docs/api/entities/) shows the evidence and the other record.

Links are made two ways:

* `wired_same_mac`: the Wi-Fi record is a client (confidence 80, or 75 for a locally administered MAC), or an AP or WDS radio (70), which also sends on the wire.
* `wired_bridged`: the Wi-Fi record is a host bridged onto Wi-Fi, the source of from-DS frames behind an AP or of 4-address frames from a WDS radio (70).  A wired host behind a wireless bridge shows up this way.

The same IPv4 address on both records adds 10, unless the Ethernet device filled its IPv4 list or is a gateway.  A Wi-Fi client heard only in probes and other management frames scores 45, and a Wi-Fi record which was only ever a destination 40; with the IPv4 bonus they stay under the default threshold, as possible links.  Group MACs and VRRP and HSRP virtual router MACs are never linked.

Anyone can send frames with any MAC, so a link is evidence that two records are the same device, not proof.

Linking runs once a second, on new and forgotten devices, and costs nothing without Ethernet devices.  It works with `track_device_phy_views=false`.  Links last one server run; the entity id isn't kept between runs.

{{<configopt entity_linking true false>}}
Link wired and Wi-Fi records; default `true`.
{{</configopt>}}

{{<configopt entity_link_min_confidence number>}}
Links at or above this confidence, `1` to `90`, are linked; lower ones are kept as possible links.  Default `60`.
{{</configopt>}}

{{<configopt entity_max_edges count>}}
The most links kept, linked and possible; default `65536`, `0` turns linking off.  A link takes about 540 bytes in the link graph, and 1.3 to 1.6KB in all with the entity id and related device entries on both records.  Links refused at this limit are made once older ones go.

Linking also keeps an index of Ethernet MACs which holds twice `wired_max_devices`, or twice `tracker_max_devices` when that's lower or `wired_max_devices` is `0`; with both at `0` it holds 65536.  Ethernet devices past that stay unlinked until older ones are forgotten.
{{</configopt>}}

{{<configopt entity_max_evidence_per_tick count>}}
Changed MACs read each second; default `2048`.  `entity_sweep_per_tick` (default `1024`) is how many links are re-read each second, so a change such as a bridged host turning out to be a client, or a new address, is picked up.
{{</configopt>}}

`entity_max_edges_per_device` and `entity_max_component` don't apply yet: links are only between records with the same MAC, so a record has one link and an entity two records.
