---
title: "Devices"
description: ""
lead: ""
date: 2022-10-28T23:43:50-04:00
lastmod: 2022-10-28T23:43:50-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "devices-a22253203ac73a2e6dec114e080ba1c0"
weight: 230
toc: true
---

A device is the central record of a tracked entity in Kismet.  Clients, bridges, access points, wireless sensors, and every other type of entity seen by Kismet will ultimately be a device.  

Each PHY layer will add fields to the device record and populate the common fields. 

For complex relationships (such as 802.11 Wi-Fi), a list of related devices in the device record describes the access point-client relationship, shared hardware, etc.

All devices will have a basic set of records (held in the `kismet.base.foo` group of fields, generally) and sub-trees of records attached by the phy-specific handlers.  A device may have multiple phy-specific records, for instance a device may contain both a `device.dot11` record and a `device.uav` record if it is seen to be a Wi-Fi based UAV/Drone device.

Some care must be taken when requesting large numbers of device records:  Kismet may be tracking tens or hundreds of thousands of devices in a single session, and requesting *all* devices can run both the Kismet server and your UI out of resources. 

Whenever possible, use the pagination functions of the [device view](/docs/api/device_views/) API and request devices groups.

Since the `2019-06` release, Kismet has migrated most device interactions to the device view api.  Any new users of the API should use the device views.

{{< kismet_api devices >}}
