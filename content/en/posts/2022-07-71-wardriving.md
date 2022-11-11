---
title: "Wardriving & Multple WiFi Cards"
description: "Introducing Doks, a Hugo theme helping you build modern documentation websites that are secure, fast, and SEO-ready — by default."
excerpt: "Introducing Doks, a Hugo theme helping you build modern documentation websites that are secure, fast, and SEO-ready — by default."
date: 2022-07-31
draft: false
weight: 50
images: []
categories: ["News", "Wardriving"]
tags: ["wardriving", "wi-fi" ]
contributors: ["Mike Kershaw"]
pinned: false
homepage: false
aliases: 
    - /wardriving/
---

## Wardriving with multiple WiFi cards

It's [World Wide War Drive](https://wigle.net/wwwdintro/DC30) season again!  So let's talk about why so many setups are being built with piles of radios and why you might want to add some radios to your setup, too.

### Seeing a network

To see a WiFi network, you need to capture a beacon packet it from it.

Beacon packets advertise that a network is present, what the SSID is, what the encryption options are, and so forth.  Networks typically advertise a beacon at 10Hz, or ten times a second.

To see the beacon, you need to be on the right channel when the beacon is sent.  Some channels overlap (in 2.4GHz) so being near the right channel is enough, but on 5GHz networks, channels are organized to minimize or eliminate overlap.

To capture packets from multiple channels, you need to hop between all the channels in the list.  Since you can only see one at a time, you of course miss traffic on the other channels.

### So how many channels are there?

A simple question with a less than obvious answer!

There are 11 (in the US) and 14 (world-wide) channels for 2.4GHz, and typically around 37 channels in 5.8GHz.

However, with 802.11n and 802.11ac, there are also HT20+, HT20-, HT40, HT80, and HT160 variants of the channels, each with multiple possible center channels.  To capture data on *all* the channels, Kismet has to expand the list, and a 2.4GHz+5GHz channel pattern could be 90 channels or more!

Fortunately, we likely don't *actually care* about more than the basic set of 50 or so channels:  Beacons are meant to be very obvious and noticeable, so they're sent at the slowest speeds at the most basic encoding.  There's value in an 802.11n card being able to detect and avoid an 802.11ac network, or join it at a lower speed, so we don't need to look at the 802.11ac-specific channel modes, or even the 802.11n-specific channel modes, we should be able to see the network advertisements just fine.  If we cared about capturing *data* then we'd want to monitor the expanded channels, but for wardriving, not so much.

In Kismet, the [Wardriving Mode Overlay](https://www.kismetwireless.net/docs/readme/wardriving/) sets this by configuring all the WiFi sources to ignore HT, VHT, and explicitly HT20 channels:

```
dot11_datasource_opt=ht_channels,false
dot11_datasource_opt=vht_channels,false
dot11_datasource_opt=default_ht20,false
dot11_datasource_opt=expand_ht20,false
```

### Hopping speeds

The [Nyquist Frequency](https://en.wikipedia.org/wiki/Nyquist_frequency) is a rule from signal processing which essentially says that to capture a signal, you need to sample at twice the frequency.  For us, this means that we need to be on a channel for at least two beacon periods to ensure we see the beacon.

Since networks beacon at ten beacons a second, we can hop at 5 channels a second (`10 / 5 = 2`), which is also the Kismet default.

The actual hopping speed is likely to be less than five channels per second: While we can tell the card to hop at a given frequency, each channel set command has to go through the kernel and firmware, and the firmware has to complete the radio tuning command.

### Channel coverage

Assuming 50 channels (more or less; it's a nice round number at least) at 5 channels per second, it would take a single WiFi card 10 seconds to cover all the channels.

We can reduce the time needed to cover all channels by adding additional WiFi cards.  Kismet will automatically split sources of the same type up so that they hop non-overlapping channels; adding a second card halves the time needed to cover all channels, using four cards reduces it to a quarter of the time, and so on.

### Channel coverage and Wardriving

So how does this apply to wardriving?

Typically WiFi advertise a 300 foot / 100 meter effective range.

If we assume that when we're wardriving we're highly unlikely to pass through the center of a network, we might safely guess that the effective detectable range of a network is closer to 150 feet / 50 meters.

Using this, we can start making some rough calculations as to how long we have to see a network.

If we have a single WiFi card cycling all channels every 10 seconds, if we're traveling more than about 10 miles per hour, we'll miss the chance to see networks - if we were to cover 150 feet in 10 seconds we'd be travelling at 15 feet per second, or 10 mph.

If we're travelling at 30mph (a more reasonable speed for residential and city streets in the United States), that's 44 feet per second - so with a single card, at the fastest reasonable hopping rate, we'd miss more than half the networks because we simply wouldn't have time to be on the right channel as we passed!

### Adding more cards

Since Kismet offsets the cards to avoid overlap, we can basically linearly increase our speed while maintaining max coverage.

Using two WiFi cards would allow a max speed of 20mph - we cover our channels in half the time, so 5 seconds to cover all the channels, 30 feet per second.

If we wanted to wardrive at 45mph and have a decent chance of seeing all the channels while we're in range, we'd want 5 cards.

### More is almost always better

All of this assumes the bare minimum to have a *good chance* of capturing the traffic.  If you want to increase your chances, more cards will absolutely do that!

### Hand-waving measurements

A final thought - these are all relatively hand-waving measurements.  150 feet coverage for a network seems like a pretty reasonable size, but depending how far from the road the access point is, it could easily be far less - or far more, if the access point is higher up in a building and visible for a much longer range.

The actual hopping rate of a WiFi card is hard to guarantee.  We can ask for hopping 5 times a second, but delays in scheduling the capture thread which performs the hop, issuing the hop command to the firmware - with whatever delays the kernel introduces in terms of USB or PCI bus contention, kernel contention for changing the state of the device, and so on - and the actual time the firmware takes to change the channel (which may not be the actual amount of time, as it may report completion before it's actually finished), all add up to a lot of estimation.

We also didn't take the overlap of 2.4GHz channels into account, strictly speaking.  Arguably, hopping only on channels 1, 6, and 11 would let us see all the other channels due to overlap, and reduce the total number of channels we have to scan - on the other hand, overlapping channels on 2.4GHz do so typically at much less power than the primary channel, and if we're attempting to spot networks at range, we want as much chance as we can get of seeing that signal.
