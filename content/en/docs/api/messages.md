---
title: "Messages"
description: ""
lead: ""
date: 2022-10-31T16:58:20-04:00
lastmod: 2022-10-31T16:58:20-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "messages-0de8b73ab596d4eb89dc319303b81247"
weight: 250
toc: true
---

Kismet uses an internal `messagebus` system (an extension of the event bus) for communicating messages from various components to the UI.

The messagebus is used to pass error, status, and debug messages, as well as notifications to the user about detected devices, alerts, etc.

For real-time messages, see the [eventbus](/docs/api/eventbus).  The Kismet UI uses a combination of the messages API to load previous content, and the eventbus to received pushed future messages immediately.

{{< kismet_api messages >}}
