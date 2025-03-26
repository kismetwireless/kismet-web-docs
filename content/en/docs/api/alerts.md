---
title: "Alerts"
description: ""
lead: ""
date: 2022-10-31T17:14:05-04:00
lastmod: 2022-10-31T17:14:05-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "alerts-9b88a9f4860a1f3fa27c1bb5f25ce79a"
weight: 260
toc: true
---

Kismet uses alerts to communicate wireless intrusion events and critical Kismet server events.

Alerts are generated both as text messages on [the messagebus](/docs/api/messages/) and as dedicated alert records.

For real-time monitoring of alerts, see the [eventbus API](/docs/api/eventbus/).

### Alert severities

Alerts severities are categorized by numerical value; a higher number is more severe.

| Severity | Definition | Use                                                                                            |
| -------: | --------- | ---                                                                                            |
| 0        | INFO      | Informational alerts, such as datasource errors, Kismet state changes, etc                     |
| 5        | LOW       | Low-risk events such as probe fingerprints                                                     |
| 10       | MEDIUM    | Medium-risk events such as denial of service attempts                                          |
| 15       | HIGH      | High-risk events such as fingerprinted watched devices, denial of service attacks, and similar |
| 20       | CRITICAL  | Critical errors such as fingerprinted known exploits                                           |

### Alert types

Alerts are categorized by type; alert types are free-form strings, but include:

| Type    | Use                                                                |
| ----    | ---                                                                |
| DENIAL  | Possible denial of service attack                                  |
| EXPLOIT | Known fingerprinted exploit attempt against a vulnerability        |
| OTHER   | General category for alerts which don't fit in any existing bucket |
| PROBE   | Probe by known tools                                               |
| SPOOF   | Attempt to spoof an existing device                                |
| SYSTEM  | System events, such as log changes, datasource errors, etc         |

{{< kismet_api alerts >}}
