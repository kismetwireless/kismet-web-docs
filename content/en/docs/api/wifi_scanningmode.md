---
title: "Scanning mode:  Wi-Fi"
description: ""
lead: ""
date: 2022-11-10T00:11:53-05:00
lastmod: 2022-11-10T00:11:53-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "phy80211_scanningmode-efcc3df7e5072d608d4fcc4dcf5130ec"
weight: 410
toc: true
---

Capturing raw packets in Wi-Fi requires a monitor-mode capable interface and either 
local capture or a high-bandwidth connection to the remote capture device. 

Scanning mode utilizing the normal network detection mode present in essentially 
all Wi-Fi cards to collect information about nearby networks for Kismet to use, 
but comes with some significant limitations:  

* Clients will not be visible.  

    Scanning mode cannot detect clients, only advertising access points. 

* Scanning mode transmits packets 

    Often, scanning for nearby networks generates probe requests from the device 
    which is scanning.  

* Full beacon information may not be available 

    Often only the basic content of the beacons is available. 

* Packet data will not be available 

    Data packets, retransmissions, and other information will not be available. 

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

2. A human-readable name.  This will be assigned as the name of the datasource, 
and will be updated automatically if the name changes in subsequent reports. 

### Cache and burst mode reporting 

Scanning mode assumes that the device doing scanning may not be able to maintain a 
constant connection to the Kismet server. 

Reports can be cached and sent in groups using the report endpoint;  each report 
contains a timestamp, GPS location, and signal information.  Multiple reports for 
the same AP reflecting information over time can be sent in a single connection.

{{< kismet_api wifi_scanningmode >}}
