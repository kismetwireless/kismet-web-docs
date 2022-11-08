---
title: "Streams"
description: ""
lead: ""
date: 2022-11-06T17:34:06-05:00
lastmod: 2022-11-06T17:34:06-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "streams-64218d2acff7148c3f1f7768703f522f"
weight: 340
toc: true
---

Kismet considers anything logging a continual egress of data to be a "stream".

The primary set of streams includes packet logging to PCAP files or to web endpoints.

Streams can be viewed and manipulated, for instance a client pulling a packet endpoint can 
either cancel the open connection, or issue a stream close command via the stream API.

{{< kismet_api streams >}}
