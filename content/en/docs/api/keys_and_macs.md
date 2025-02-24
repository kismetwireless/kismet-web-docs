---
title: "Keys and MAC addresses"
description: ""
lead: ""
date: 2022-10-30T09:22:57-04:00
lastmod: 2022-10-30T09:22:57-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "keys_and_macs-b8c9c2626c2239dd37ce571e2c0b1c78"
weight: 50
toc: true
---

Devices are indexed two primary ways in Kismet:

1. Keys

    A key is unique for each device.  The key is derived *from* the MAC address, but contains additional information about the PHY type.

    This allows multiple devices to have the same MAC under different PHY types; this can be particularly important when using non-traditional PHY types like those derived from SDR captures, when the devices do not have an actual MAC address.

2. MAC addresses

    The MAC address is a (theoretically) unique identifier given to each device at manufacture time.  It is used to identify the device uniquely on a network.

    Typically, the the IEEE assigns each manufacturer a block of addresses with a common header (the OUI) and the manufacturer is responsible for creating unique identifiers within that block.

    For datasources without a defined MAC address, Kismet will attempt to synthesize a MAC address from the unique data available.

## MAC address masking

On queries and filters affecting MAC addresses, Kismet supports complete addresses or partial addresses with masking.

A masked address resembles the syntax typically used for IP network masking: `[MAC]/[MASK]`.

For instance, to match only the OUI, a masked MAC of:

```json
"aa:bb:cc:00:00:00/ff:ff:ff:00:00:00"
```

This would match any MAC address where the OUI, or first three bytes, are "aa:bb:cc".  A similar feature to match on the first *four* bytes would be:

```json
"aa:bb:cc:dd:00:00/ff:ff:ff:ff:00:00"
```
