---
title: "Alerts"
description: ""
lead: ""
date: 2022-09-18T23:09:56-04:00
lastmod: 2022-09-18T23:09:56-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "alerts-a1fa807b249b9356aec185f87f9abcf2"
weight: 10
toc: true
---

Kismet can function as a WIDS (Wireless Intrusion Detection System) with alerts for stateless and stateful fingerprint and trend based monitoring. Kismet fingerprint alerts can trigger on known-hostile specific behavior such as attacks against wireless drivers, and trend-based monitors can detect unusual behavior over time, such as flooding and denial of service attacks.

Kismet can integrate with other tools via the live packet export REST API, the Kismet alert REST API, and via syslog and some SIEM tools.

Kismet is most effective as an IDS in stationary (ie, non-wardriving) capacity. Kismet WIDS functionality can be used in mobile and channel-hopping installations, but accuracy and coverage may suffer.

## Configuring alerts

### Alert rates

Alerts are configured with the `alert=` configuration option, and the defaults are defined in `kismet_alerts.conf`.  Alerts are configured by name, with `throttle` and `burst` options.  They can be overridden with `kismet_site.conf` (preferred) or by editing `kismet_alerts.conf` directly (discouraged).

The throttle option controls how many alerts are allowed per time unit (seconds and minutes), and burst controls how many alerts are allowed in quick succession.  For instance:

```
alert=NETSTUMBLER,5/min,1/sec
```

Will allow at most one alert per second, and at most 5 alerts per minute.  Excess alerts will not be reported.

### Disabling alerts

An alert can be disabled by setting the maximum throttle and burst to 0.

```
alert=NOCLIENTMFP,0/min,0/sec
```

Some critical system alerts, such as those raised while loading configuration files, can not be disabled.

### Complex alert configuration

Some alerts, such as `APSPOOF`, have additional configuration options.  These options are documented in the description of each alert.

## False positives

Kismet includes alerts for many theoretical attacks reported in research, as CVEs, etc.

Many of these attacks rely on a combination of specific chipsets and drivers, and specific abuses of the Wi-Fi standard; as Wi-Fi evolves, what was previously an over-long packet element used to exploit a driver may become a commonly used field which needs extra data.

Deprecated attacks in Kismet are typically disabled by default in the config file, but at times a new evolution or use of Wi-Fi will trigger an alert with a false positive.

*Generally* speaking, it is unlikely that most users will encounter cutting edge attacks in the wild.  Many things are possible - which is why Kismet provides the alerts - but often unlikely.  When given an usual alert, consider taking the step of examining the PCAP log directly with a tool like [Wireshark](https://wireshark.org).

## Alerts

{{< kismet_alert_list >}}
