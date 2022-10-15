---
title: "Launching Kismet"
description: ""
lead: ""
date: 2022-08-13T10:23:01-04:00
lastmod: 2022-08-13T10:23:01-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "starting-cea5066786e8f16060de7f84b1c24da5"
weight: 10
---

Kismet is launched from the command line, and can run headless (with no UI), but the typical way to interact with it is via the integrated web UI.

## Starting Kismet

The simplest way to start Kismet is to open a terminal and simply run it:

```
kismet
```

This will launch Kismet with the default configuration, and no pre-defined capture sources.

Assuming you have installed Kismet with suid-root (the recommended, more secure method) and your user is in the `kismet` group, you can now add sources via the web interface.

If you did *not* install Kismet suid-root, you will need to launch it as root with the `sudo` command, or it will not be able to control capture sources:

```
sudo kismet
```

Kismet will display information about the startup process, and any errors.  

A typical startup from Kismet would look like:

```text
dragorn@boron ~ % kismet -n --no-ncurses
INFO: Including sub-config file: /usr/local/etc/kismet_httpd.conf
INFO: Including sub-config file: /usr/local/etc/kismet_memory.conf
INFO: Including sub-config file: /usr/local/etc/kismet_alerts.conf
INFO: Including sub-config file: /usr/local/etc/kismet_80211.conf
INFO: Including sub-config file: /usr/local/etc/kismet_logging.conf
INFO: Including sub-config file: /usr/local/etc/kismet_filter.conf
INFO: Including sub-config file: /usr/local/etc/kismet_uav.conf
INFO: Loading config override file '/usr/local/etc/kismet_package.conf'
INFO: Optional sub-config file not present: /usr/local/etc/kismet_package.conf
INFO: Loading config override file '/usr/local/etc/kismet_site.conf'
INFO: Optional sub-config file not present: /usr/local/etc/kismet_site.conf
INFO: Setting server UUID DBC402AE-9B3E-11EC-88C2-4B49534D4554
INFO: Starting Beast webserver on 0.0.0.0:2501
INFO: Opened OUI file '/usr/local/share/kismet/kismet_manuf.txt.gz
INFO: Indexing manufacturer db
INFO: Completed indexing manufacturer db, 31466 lines 630 indexes
INFO: Saving devices to the Kismet database log every 30 seconds.
INFO: Using default rates of 10/min, 1/sec for alert 'DEVICEFOUND'
INFO: Using default rates of 10/min, 1/sec for alert 'DEVICELOST'
INFO: Registering support for DLT_PPI packet header decoding
INFO: Registering support for DLT_RADIOTAP packet header decoding
INFO: Registering support for DLT_BTLE_RADIO packet header decoding
INFO: Using default rates of 10/min, 1/sec for alert 'BADFIXLENIE'
INFO: PHY80211 will only process AP signal levels from beacons
INFO: Allowing Kismet clients to view WEP keys
INFO: Keeping EAPOL packets in memory for easy download and WIDS functionality; this can use more RAM.
INFO: Registered PHY handler 'IEEE802.11' as ID 0
INFO: Registered PHY handler 'RTL433' as ID 1
INFO: Registered PHY handler 'Z-Wave' as ID 2
INFO: Registered PHY handler 'Bluetooth' as ID 3
INFO: Registered PHY handler 'UAV' as ID 4
INFO: Registered PHY handler 'NrfMousejack' as ID 5
INFO: Using default rates of 10/min, 1/sec for alert 'BLEEDINGTOOTH'
INFO: Registered PHY handler 'BTLE' as ID 6
INFO: Registered PHY handler 'METER' as ID 7
INFO: Indexing ADSB ICAO db
INFO: Completed indexing ADSB ICAO db, 322278 lines 6446 indexes
INFO: Registered PHY handler 'ADSB' as ID 8
INFO: Registered PHY handler '802.15.4' as ID 9
INFO: Registered PHY handler 'RADIATION' as ID 10
INFO: Serving static file content from /usr/local/share/kismet/httpd/
INFO: Enabling channel hopping by default on sources which support channel control.
INFO: Setting default channel hop rate to 5/sec
INFO: Enabling channel list splitting on sources which share the same list of channels
INFO: Enabling channel list shuffling to optimize overlaps
INFO: Sources will be re-opened if they encounter an error
INFO: Saving datasources to the Kismet database log every 30 seconds.
INFO: Launching remote capture server on 127.0.0.1 3501
INFO: No data sources defined; Kismet will not capture anything until a source is added.
ALERT: LOGDISABLED Logging has been disabled via the Kismet config files or the command line.  Pcap, database, and related logs will not be saved.
INFO: Logging disabled, not enabling any log drivers.
INFO: GPS track will be logged to the Kismet logfile
INFO: Starting Kismet web server...
INFO: HTTP server listening on 0.0.0.0:2501
INFO: Could not open system plugin directory (/usr/local/lib/kismet/), skipping: No such file or directory
INFO: Did not find a user plugin directory (/home/user/plugins/), skipping: No such file or directory
```

Kismet will be verbose during startup; lines starting with `INFO` are meant to communicate configuration options and general state.  Lines which prevent Kismet from starting will be prefixed with `FATAL` and repeated as Kismet exits.

