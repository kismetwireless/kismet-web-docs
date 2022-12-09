---
title: "Scanning mode: Bluetooth"
description: ""
lead: ""
date: 2022-11-10T23:56:19-05:00
lastmod: 2022-11-10T23:56:19-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "bluetooth_scanningmode-a6d5a2d1288a733e75ffe098427d6ff2"
weight: 420
toc: true
---

The design of Bluetooth makes capturing packets very difficult, but performing active 
scans for discoverable Bluetooth and BTLE devices can still yeild results. 

### Scanning mode data sources 

The scan report API is designed to be as simple as possible, and to automate as 
much of the process as possible.

To assist with automation, scanning mode datasources are created dynamically by 
Kismet when scan reports are submitted; there is no need to define a specific 
datasource before sending a scanning mode report.  

To create the scanning mode datasource, a scanning report must include: 

1. A datasource UUID.  This UUID must be unique within Kismet, and consistent for 
all reports from this datasource.  Scanning software should cache this UUID for 
consistent reporting between instances. 

2. A human-readable name.  This wil be assigned as the name of the datasource, 
and will be updated automatically if the name changes in subsequent reports. 

### Cache and burst mode reporting 

Scanning mode assumes that the device doing scanning may not be able to maintain a 
constant connection to the Kismet server. 

Reports can be cached in sent in groups using the report endpoint;  each report 
contains a timestamp, GPS location, and signal information.  Multiple reports for 
the same AP reflecting information over time can be sent in a single connection.

{{< kismet_api bluetooth_scanningmode >}}
