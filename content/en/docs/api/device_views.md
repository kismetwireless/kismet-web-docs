---
title: "Device views"
description: ""
lead: ""
date: 2022-10-30T09:45:10-04:00
lastmod: 2026-11-12T10:30:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "device_views-266e5d0e082c8d800a65c26a0f2313b1"
weight: 240
toc: true
---

Device views in Kismet are optimized subsets of the global device list. 

Device views can be defined by PHY handlers, plugins, as part of the Kismet basic code, or by user-supplied data. 

Kismet uses device views to organize devices by capture interface, phy type, specific device type (like the phy80211 access point view), and more. 

After 2026-10-R1, each [device rule](/docs/readme/configuring/device_rules/) with a `view` makes a view named `rule-<name>` holding the devices which match it.  A rule view stays after its rule is removed, empty, and is filled again if a rule of the same name gets a `view`.

After 2026-10-R1, the view `default` holds every device which no [`exclude` rule](/docs/readme/configuring/device_rules/#the-default-view) matches; new devices are in it until the rules have checked them.  Devices which an `exclude` rule matches carry `kismet.device.rules.excluded`.  The web UI opens the device list on this view.

Some views also answer under a second path made from what they hold: the view of each phy (`phy-IEEE802.11`) under `/devices/views/phy/IEEE802.11/`, and the view of each data source (`seenby-<uuid>`) under `/devices/views/seenby-uuid/<uuid>/`.  The `devices`, `last-time`, `modified-since`, and `monitor` endpoints work the same under either path.  The second paths work after 2026-10-R1; earlier versions answered them with a 404.

All clients are strongly encouraged to use the device view API going forwards. 

Device views are also designed to work with paginating user interfaces; as part of the request, a client can request a "page" of information; with each subsequent page (or scroll) the user interface fetches only the data it needs. 

The Kismet device views are written around the API of the [jquery-datatables](https://datatables.net/) web component API, but this API can easily be adapted for use with any pagination system.

{{< kismet_api device_views >}}
