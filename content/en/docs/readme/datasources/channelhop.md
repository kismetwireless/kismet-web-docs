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

    Changing channel more frequently than devices are likely to transmit means the chances of losing data is significantly higher. 

3. Ability of the drivers to tune rapidly 

    Some device drivers do not gracefully handle tuning at high speeds.

### Kismet defaults 

Kismet defaults to changing channels 5 times a second.  This rate is chosen as a compromise for WiFi devices - an Access Point typically beacons at 10 times a second, so a hop rate of 5Hz nicely fits the [Nyquist](https://en.wikipedia.org/wiki/Nyquist_frequency) calculations to have the best chance of capturing a packet.

Channel hopping rates can be configured per-source in the source definition.

## Channel splitting 

When channel hopping, Kismet will automatically split the list of channels between all the datasources of the same type.  There is little benefit to hopping to the *same* channels at the same time with multiple interfaces! 

Kismet will automatically divide the list so that the maximum number of unique channels are covered by the devices available.

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

For more esoteric datasource configuration options, check `kismet.conf`
