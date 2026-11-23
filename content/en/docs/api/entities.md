---
title: "Linked wired and Wi-Fi devices"
description: ""
lead: ""
date: 2026-11-23T12:00:00-05:00
lastmod: 2026-11-23T12:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "entities-82ce8afe2c3d4688b5ddb956038ade57"
weight: 373
toc: true
---

After 2026-10-R1, Kismet links a Wi-Fi device record and an [Ethernet](/docs/api/ethernet/) device record which share a MAC address, so what a wired tap saw a wireless device do (its addresses, names, DHCP fingerprint, VLANs, traffic and flows) can be found from its Wi-Fi record.  How links are made and the options which control them are on the [wired source page](/docs/readme/datasources/wired-linux/#linking-wired-and-wi-fi-devices).

The two records stay separate.  A linked pair shares `kismet.device.base.entity_id`, and each lists the other in its related devices.  The entity id lasts one server run.

`kismet.device.base.entity_id` is present only on linked records.  To select records which aren't linked in a [device filter or rule](/docs/readme/configuring/device_rules/), use `!exists(kismet.device.base.entity_id)`: a comparison such as `kismet.device.base.entity_id == 0` never matches, because a missing field compares false.

{{< kismet_api entities >}}
