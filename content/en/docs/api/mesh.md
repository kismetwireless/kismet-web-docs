---
title: "Mesh networks"
description: ""
lead: ""
date: 2026-10-15T22:10:12-04:00
lastmod: 2026-10-15T22:10:12-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "mesh-8f6f0b1cf2f84c23a003ee22f839f4a7"
weight: 403
toc: true
---

Kismet decodes [Meshtastic](https://meshtastic.org) and [MeshCore](https://github.com/meshcore-dev/MeshCore) LoRa mesh networks, captured with the [LoraPipe](/docs/readme/datasources/lora-lorapipe/) datasource.

Mesh nodes are tracked as devices; these endpoints provide the mesh channels Kismet knows about, and the messages decoded on them.

{{< kismet_api mesh >}}
