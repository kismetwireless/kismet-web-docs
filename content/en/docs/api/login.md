---
title: "Logins and sessions"
description: ""
lead: ""
date: 2022-10-14T11:36:05-04:00
lastmod: 2022-10-14T11:36:05-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "login-b898b25d5b6a19d57507937ca625ed36"
weight: 200
toc: true
---

Kismet uses HTTP basic-auth to submit login information, and session tokens to retain login state.

As of `2019-04-git`, all interaction with the Kismet server requires a login.

As of `2020-10-git`, all endpoints on the Kismet server support a role:  All login sessions made with the admin username and password are granted the `admin` role.  The `admin` role has access to all endpoints.  Additional sessions may be set by creating API keys with an assigned role which restricts the available endpoints of the session.

As of `2022-10-git`, Kismet uses a JWT system internally to generate session tokens.  This change is essentially invisible to users of the API, but alleviates some internal stress on Kismet for retaining a session database and list.

A session will automatically be created during authentication to any endpoint which requires login information, and returned in the `KISMET` session cookie.

Logins may be manually validated against the `/session/check_session` endpoint if validating user-supplied credentials.

## Providing logins

Kismet accepts logins via HTTP Basic authentication, session cookie, and GET URI parameters.

If the administrator username and password is provided via Basic auth or via get URI parameters, a session cookie is created (if one does not already exist) or found, and returned in the `KISMET` cookie parameter.

*Added 2020-10* API-token-only consumers of the API should provide *ONLY* the API token given, and supply it in the `KISMET` cookie or URI parameter.

## API Keys

API keys are, essentially, pre-provisioned session tokens stored in the Kismet settings files in the users home directory.

An API key is associated with a role, and can be used with any endpoint which supports that role.

Generally, an API key should be preferred for any tool interacting with Kismet on more than a one-off basis.

## URI parameters

Some mechanisms, such as websockets, do not commonly support HTTP Basic Auth or cookie passing, and must use URI parameters:

| Key      | Value                             |
| ---      | -----                             |
| user     | Administrator username            |
| password | Administrator password            |
| KISMET   | Kismet session cookie / API token |

The same rules apply to the user and password and session token login process - if a valid username and password is provided, it will return a session token in the set-cookie parameter for future logins.

## Login roles

As of `2020-10`, Kismet supports login roles.

Every endpoint supports one or more roles.  The provided authentication, session key, or API key must be authorized for that role or the endpoint will return a permission denied error.

Roles are not inherited; a role limits the API token to those roles.

Logins as the Kismet user are given the role `admin`, which has access to all endpoints; this retains the standard behavior of endpoints and logins.

The most common use for roles is to limit the access of an API token.

## API tokens and roles

As of `2020-11`, Kismet supports the use of API tokens and roles to restrict the actions of sessions.  Predefined roles include:

| Role       | Description                                                                                                      |
| ----       | -----------                                                                                                      |
| admin      | Main role with access to all endpoints.  Logins created via HTTP auth are automatically assigned the admin role. |
| readonly   | Read-only role with access to endpoints which do not modify any devices, state, or configuration                 |
| scanreport | Role able to submit device/network scan reports, via the Wi-Fi and Bluetooth scanning-mode API                   |
| datasource | Role for remote capture websocket sources                                                                        |

Roles are not inherited or cascading; for instance a `readonly` role does not have access to reporting scans or acting as remote datasources.  The only role with access to all endpoints is `admin`.

## Login and session API

{{< kismet_api login >}}
