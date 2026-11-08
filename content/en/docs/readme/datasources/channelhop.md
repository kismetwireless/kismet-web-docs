---
title: "Channels & Hopping"
description: ""
lead: ""
date: 2022-08-26T13:29:04-04:00
lastmod: 2022-08-26T13:29:04-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "channelhop-8ab5dd335aa7e3f0b47d2c5998cd56b1"
weight: 20
toc: true
---

Typically, a wireless device can only tune to one part of the available spectrum at a time.

For Wi-Fi and many related sources, these are called *channels*. 

## Channel hopping 

There is always a trade-off between channel coverage and complete capture of a single channel:  Either you remain on a single channel and capture as much data as possible, while missing events on other channels, or you change channels frequently and gather more information about the environment as a whole, but risk missing specific events on individual channels. 

By default, Kismet will enable channel hopping on all datasources which support it. 

Most commonly, channel hopping is discussed in relationship with Wi-Fi, but some other datasource types also hop channels.

## Hop speeds 

Picking a channel hopping speed is a balance between several factors:

1. The tuning speed of the device.  

    Some devices are able to re-tune very quickly, others are not. 

2. The frequency of data in the target protocol.

    Changing channel more frequently than devices are likely to transmit means the chances of losing data are significantly higher. 

3. Ability of the drivers to tune rapidly 

    Some device drivers do not gracefully handle tuning at high speeds.

### Kismet defaults 

Kismet defaults to changing channels 5 times a second.  This rate is chosen as a compromise for WiFi devices - an Access Point typically beacons at 10 times a second, so a hop rate of 5Hz nicely fits the [Nyquist](https://en.wikipedia.org/wiki/Nyquist_frequency) calculations to have the best chance of capturing a packet.

Channel hopping rates can be configured per-source in the source definition.

## Channel splitting 

When channel hopping, Kismet will automatically split the list of channels between all the datasources of the same type.  There is little benefit to hopping to the *same* channels at the same time with multiple interfaces! 

Kismet will automatically divide the list so that the maximum number of unique channels are covered by the devices available.

After 2026-10-R1, the *Time* view of the web UI's *Channel coverage* window estimates how much of the time each channel is listened to across all the sources, which shows how the split works out.

## Synchronized hopping

After 2026-10-R1, Kismet can keep the channel hopping of all its sources in step.  Normally each source changes channel on its own timer, so two sources splitting the channel list drift past each other, and sometimes sit on the same channel while another goes unwatched.

With synchronized hopping, every source hops on one shared schedule kept by the Kismet server.  The capture tools sync their clocks to the server, local and remote alike, and change channel at the same moment.  Sources at the same hop rate stay on separate channels when they split the list, and stay exactly together when they're in a hop group.

Synchronized hopping is off by default for now.  Turn it on for every source with `channel_hop_sync=true`, or per source with `hopsync=true`.

Capture tools from before synchronized hopping keep hopping on their own; Kismet works with them as before.

### Hop groups

Sometimes the same channel should be watched by several sources at once: a set of directional antennas, or sources at different locations feeding one Kismet server.  Give those sources the same `hopgroup=` name, and Kismet hops them together, on the same channel at the same moment, instead of splitting the channels between them:

```
source=wlan0:name=north,hopgroup=sectors
source=wlan1:name=south,hopgroup=sectors
```

A hop group turns on synchronized hopping for its sources, unless a source says `hopsync=false`.  A group name is up to 32 letters, digits, `.`, `_` or `-`.

The sources in a group must be identical: the same type of source and hardware, the same channels, hop list and hop rate as the first source of the group, and a capture tool which syncs its clock.  A source which doesn't match hops on its own and Kismet says why, in the messages and in the source's *Hop sync* section of the *Data sources* window.

Locking one source of a group to a channel, or changing its channel list or hop rate, does the same to every source in the group.

When Kismet splits channels between sources, a hop group counts as one source.

### Channel change timing

Capture tools which support synchronized hopping also report how long changing channel takes, whether or not sync is turned on: the time for a channel change, the time for a change between bands (such as 2.4 and 5 GHz, which is often slower), how many hops ran late or failed, and the state and accuracy of the clock sync.  The web UI shows them in the *Hop sync* section of each source in the *Data sources* window, and the API in the `kismet.datasource.hop_timing` record of each source.

Packets received while a source is changing channel may be reported on the wrong channel; Kismet marks them, and counts them per source as `kismet.datasource.num_chanswitch_packets`.

## Configuration 

The global channel hopping controls affect all datasources, unless a source specifically changes the values.  

Global hopping options can be overridden in `kismet_site.conf` [override config file](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf):

{{<configopt channel_hop true false>}}
Control if any source channel hops by default. 
{{</configopt>}}


{{<configopt channel_hop_speed "rate/sec" "rate/min">}}
Set the default channel hop speed.  Rate can be expressed in hops per second or hops per minute, and defaults to `5/sec`. 

```
channel_hop_speed=5/sec
```

or 

```
channel_hop_speed=10/min
```
{{</configopt>}}

{{<configopt channel_hop_sync true false>}}
Hop every source on the shared, synchronized schedule (after 2026-10-R1).  Defaults to `false`.  Sources can override it with the `hopsync=true` or `hopsync=false` source option.

```
channel_hop_sync=true
```
{{</configopt>}}

{{<configopt channel_hop_report_ms milliseconds>}}
How often capture tools report their channel change timing, in milliseconds (after 2026-10-R1).  Defaults to `10000`, and capture tools report at most once a second; `0` turns the reports off.
{{</configopt>}}

### Source options

These options go in a source definition, and work for any source which hops:

{{<configopt hopsync true false>}}
Hop this source on the synchronized schedule, or not, whatever `channel_hop_sync` says.
{{</configopt>}}

{{<configopt hopgroup name>}}
Hop this source together with the other sources of the same group name; see [Hop groups](#hop-groups).
{{</configopt>}}

For more esoteric datasource configuration options, check `kismet.conf`
