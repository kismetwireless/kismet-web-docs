---
title: "REST-like API"
description: ""
lead: ""
date: 2022-10-10T19:53:38-04:00
lastmod: 2022-10-10T19:53:38-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "rest_like-5edfafb37ea8541854db41cf9888d6e9"
weight: 10
toc: false
---

Kismet uses a REST-like interface for the embedded webserver, which provides data and accepts commands.

Kismet attempts to provide sane and consistent endpoints.

Many Kismet endpoints support both a basic `GET` implementation, and a more complex `POST` implementation which accepts filtering, optimization, and more.

Kismet can serialize the endpoint data to multiple formats; whenever possible, an endpoint will support all output formats.

The default output format is basic JSON, but additional transformations of the JSON data are available, including optimization for streamed processing, field renaming, and human-readable formatting for learning and investigating data.

As of `2019-04-git`, Kismet requires a login on ALL endpoints, excluding:

* `/system/user_status`
* `/session/check_login`
* `/session/check_session`
* `/session/check_setup_ok`
