---
title: "Datasources"
description: ""
lead: ""
date: 2022-10-31T23:28:01-04:00
lastmod: 2022-10-31T23:28:01-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "datasources-f5c3169d096545e69dbfee18e66a2bad"
weight: 280
toc: true
---

Every source of packet and device data in Kismet is a datasource.  Typically a datasource is analogous to a network interface, but may encompass other captures such as SDR, serially attached capture systems, or summarized scan data posted to an endpoint.

Datasources are defined on startup in `kismet.conf` as a `source=...`, or on the command line with `-c {source definition}`

{{< kismet_api datasources >}}
