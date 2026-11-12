---
title: "Device rules"
description: ""
lead: ""
date: 2026-10-29T12:00:00-04:00
lastmod: 2026-11-12T10:30:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "device_rules-3e9a51c7d0b24f68a1c5e7d9b2f4a6c8"
weight: 245
toc: true
---

After 2026-10-R1, [device rules](/docs/readme/configuring/device_rules/) tag, color, sort, and collect devices into views, and raise alerts, on the server.

Devices which match at least one rule carry `kismet.device.base.rules`:

| Field | Content |
| ----- | ------- |
| `kismet.device.rules.matched` | Names of the rules the device matches |
| `kismet.device.rules.tags` | Tags from the matching rules |
| `kismet.device.rules.color` | Highlight color from the first matching rule with a color |
| `kismet.device.rules.excluded` | Set when an `exclude` rule matches the device, which leaves it out of the `default` view (after 2026-10-R1) |

Each rule with a `view` makes a [device view](/docs/api/device_views/) named `rule-<name>`, and [device views](/docs/api/device_views/#view-based-device-lists) can be ordered with a sort by passing `rule_sort`.

After 2026-10-R1, devices which no `exclude` rule matches make up the [device view](/docs/api/device_views/) `default`.

Rules set over the API come after the rules from the Kismet config, and replace only the rules set earlier over the API.

{{< kismet_api device_rules >}}
