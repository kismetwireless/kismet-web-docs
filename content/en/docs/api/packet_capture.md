---
title: "Packet capture"
description: ""
lead: ""
date: 2022-11-03T22:14:45-04:00
lastmod: 2022-11-03T22:14:45-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "packet_capture-ef4e6cdc0c3ab7d9c492e8731631928f"
weight: 300
toc: true
---

Kismet provides endpoints to obtain packets live as a stream in the PCAP-NG format.

PCAP-NG is a standard, extended version of the traditional PCAP format, which offers the 
ability to include multiple interfaces, multiple link types, and the original radio headers of 
all the captured packets. 

Tools like Wireshark can process the complete PCAP-NG format, while simpler tools like tcpdump 
and other libpcap-based tools can process single-linktype pcapng directly. 

PCAP-NG files can be post-processed with `tshark` or `wireshark` to strip the capture to a 
single interface and link type if necessary.

{{< kismet_api packet_capture >}}
