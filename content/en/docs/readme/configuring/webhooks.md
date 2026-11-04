---
title: "Webhooks"
description: ""
lead: ""
date: 2026-11-04T12:00:00-05:00
lastmod: 2026-11-04T12:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "webhooks-4b8e2d6f1a3c4e9b8d7f0a2c5e1b9d34"
weight: 46
toc: true
---

Added: `after 2026-10-R1`

Webhooks send devices which match a [device rule](/docs/readme/configuring/device_rules/) to an HTTP or HTTPS server, as JSON: a Home Assistant automation, a chat bot, a script, or anything else which takes a web request.

Endpoints, the servers Kismet sends to, are defined in the Kismet config, in `kismet_webhooks.conf` or `kismet_site.conf`.  Rules name the endpoint they send to with a [`webhook` statement](/docs/readme/configuring/device_rules/#webhooks), which also says when to send and what.

## Endpoints

Each endpoint is one `webhook_endpoint` line, with a name and its options:

```
webhook_endpoint=<name>:url=<url>[,option=value...]
```

Names are letters, digits, `-`, and `_`.  Endpoints can only be set in the config, not over the REST API.

| Option | |
| ------ | - |
| `url=<url>` | The `http://` or `https://` URL calls are POSTed to.  Required.  Put credentials in a header rather than in the URL. |
| `secret=<text>` | [Sign](#signed-calls) each call with this secret; use 16 or more characters. |
| `header="Name: value"` | Add a header to each call, such as an `Authorization` header; up to 8. |
| `rate=<n>/<period>` | The most calls per period, such as `30/1m`.  Default `30/1m`. |
| `burst=<n>` | Calls which may go at once before the rate applies.  Default 10. |
| `queue=<n>` | Events waiting to be sent; when it's full, the oldest are dropped.  Default 200. |
| `max_events=<n>` | The most events in one call.  Default 100. |
| `timeout=<time>` | The time one call may take, from `1s` to `60s`.  Default `10s`. |
| `ca=<file>` | A PEM file of the certificate authorities to trust for HTTPS, instead of the system ones. |
| `insecure=true` | Don't check the HTTPS server's certificate. |

```
webhook_endpoint=ha:url=https://homeassistant.local:8123/api/webhook/kismet-events,secret=change-this-secret-text
webhook_endpoint=log:url=http://127.0.0.1:8000/kismet,header="Authorization: Bearer abc123",rate=60/1m
```

Two options apply to every webhook together:

{{<configopt webhook_global_rate "n/period">}}
The most webhook events from every rule together, per period.  Default `600/1m`.
{{</configopt>}}

{{<configopt webhook_max_tracked "count">}}
The most devices each rule's webhook keeps state for, which `for`, `change`, `every`, `new`, and `stop` need.  Devices past this are skipped and counted in the [status](#status).  Default 100000.
{{</configopt>}}

## What is sent

Each call is one JSON object, with one or more events:

```json
{
  "kismet": {"server_name": "Kismet", "server_uuid": "...", "version": "..."},
  "endpoint": "ha",
  "sent": 1793800000,
  "dropped": 0,
  "suppressed": 0,
  "events": [
    {
      "rule": "new-public-btle",
      "description": "New BTLE devices with public addresses",
      "trigger": "new",
      "time": 1793799990,
      "seq": 1,
      "device": {"kismet.device.base.macaddr": "...", "kismet.device.base.commonname": "...", "kismet.common.signal.last_signal": -71},
      "changed": {"kismet.common.signal.last_signal": {"old": -80, "new": -71}}
    }
  ]
}
```

* `dropped` counts the events dropped since the last call that was delivered, and `suppressed` the events rate limits held back.
* `trigger` is what sent the event: `match`, `new`, `once`, `every`, `change`, or `stop`.
* `device` has the rule's `fields`, named as the [REST API](/docs/api/devices/) names them; the default fields are the device key, MAC, name, phy, type, manufacturer, channel, frequency, first and last time, and last signal.
* `changed` is only in `change` events, with the old and new value of each field which changed.

## Signed calls

With a `secret`, each call has two more headers:

* `X-Kismet-Timestamp`: the time the call was sent, in seconds since the epoch.
* `X-Kismet-Signature`: `sha256=` and the hex HMAC-SHA256, with the secret as the key, of the timestamp, a `.`, and the body.

A receiver should check the signature against the body exactly as received, and refuse a call whose timestamp is too old, so a captured call can't be sent again.  In Python:

```python
import hashlib
import hmac
import time

SECRET = b"change-this-secret-text"
MAX_AGE = 300

def kismet_call_ok(headers, body):
    ts = headers.get("X-Kismet-Timestamp", "")
    sig = headers.get("X-Kismet-Signature", "")

    if not ts.isdigit() or abs(time.time() - int(ts)) > MAX_AGE:
        return False

    want = "sha256=" + hmac.new(SECRET, ts.encode() + b"." + body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(sig, want)
```

The timestamp comes from the Kismet server's clock, so keep the clocks of both close.

## Delivery and retries

* A `2xx` answer delivers the call.
* No answer, a timeout, or a `408`, `429`, or `5xx` answer is retried later, after 5 seconds and then longer, up to 5 minutes; a `429`'s `Retry-After`, in seconds, is honored, up to an hour.  Each event is tried 3 times, then dropped.
* Any other answer, such as a `401` or a redirect, drops the call's events.  Redirects aren't followed.

Calls go out under the endpoint's `rate`, `burst`, and `queue` limits, the rule's own [`rate`](/docs/readme/configuring/device_rules/#webhooks), and `webhook_global_rate`; events which don't fit are counted as suppressed or dropped in the next call and in the status.

## Status

[`/webhooks/status.json`](/docs/api/webhooks/) shows each endpoint and each rule's webhooks: what was sent, failed, dropped, and held back, and the last answer.  The status and Kismet's logs show only the scheme, host, and port of an endpoint's URL, never the path or query, which often hold a token.

## Security

* `kismet.conf` and the files it includes are installed readable by everyone, and secrets, headers, and URLs with tokens in them are readable by anyone who can read the file they're in.  Put endpoints in `kismet_site.conf`, readable only by the user Kismet runs as (`chmod 600`).
* Device names and most other fields come from the air: anyone nearby can set them.  Treat every field of an event as untrusted text, and never use one in a command, a query, or a page without escaping it.
* Plain `http://` isn't encrypted, so devices, headers, and tokens can be read on the network between Kismet and the receiver.  Use `https://` to send beyond the local machine or a trusted network, and keep `insecure=true` for testing.

## Home Assistant

A Home Assistant [webhook trigger](https://www.home-assistant.io/docs/automation/trigger/#webhook-trigger) takes Kismet's calls.  Home Assistant doesn't check signatures, so the webhook ID, which is in the URL, is the secret: make it long and random.

```
webhook_endpoint=ha:url=https://homeassistant.local:8123/api/webhook/kismet-3c9f0a6e1d2b48f7,rate=10/1m
```

An automation which notifies for each device in a call:

```yaml
alias: "Kismet devices"
triggers:
  - trigger: webhook
    webhook_id: kismet-3c9f0a6e1d2b48f7
    allowed_methods: [POST]
    local_only: true
actions:
  - repeat:
      for_each: "{{ trigger.json.events }}"
      sequence:
        - action: persistent_notification.create
          data:
            title: "Kismet: {{ repeat.item.rule }}"
            message: >
              {{ repeat.item.device['kismet.device.base.macaddr'] }}
              {{ repeat.item.device['kismet.device.base.commonname'] | default('') }}
```

Home Assistant serves plain HTTP on port 8123 unless it's set up for HTTPS; over plain HTTP, the webhook ID can be read on the network.
