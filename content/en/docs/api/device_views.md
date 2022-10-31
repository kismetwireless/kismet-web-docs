---
title: "Device views"
description: ""
lead: ""
date: 2022-10-30T09:45:10-04:00
lastmod: 2022-10-30T09:45:10-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "device_views-266e5d0e082c8d800a65c26a0f2313b1"
weight: 240
toc: true
---

Device views in Kismet are optimized subsets of the global device list. 

Device views can by defined by PHY handlers, plugins, as part of the Kismet basic code, or by user-supplied data. 

Kismet uses device views to organize devices by capture interface, phy type, specific device type (like the phy80211 access point view), and more. 

All clients are strongly encouraged to use the device view API going forwards. 

Device views are also designed to work with paginating user interfaces; as part of the request, a client can request a "page" of information; with each subsequent page (or scroll) the user interface fetches only the data it needs. 

The Kismet device views are written around the API of the [jquery-datatables](https://datatables.net/) web component API, but this API can easily be adapted for use with any pagination system.

{{< kismet_api device_views >}}
