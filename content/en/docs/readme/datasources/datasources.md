---
title: "Datasources"
description: ""
lead: ""
date: 2022-08-26T12:04:12-04:00
lastmod: 2022-08-26T12:04:12-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "datasources-1d6c1e2d59efe56eba6640569a3d8f9b"
weight: 10
toc: true
---

Kismet captures data from "data sources".  The captured data is typically raw packets, but can also be JSON information or other device records.

## Configuring sources 

Sources are added to Kismet via the Web UI (Menu->Datasources), via the Kismet config file, or on the command line when starting Kismet.

Most datasources can be detected automatically, however some must be manually added because the hardware can't be identified.

Sources have any number of options:  per-source tweaks for how that specific source will be configured.

### Source definitions 

Sources are always defined as:

```
[capture]:option1=value1,option2=value2
```

For instance, to define a source that captures from the wlan0 Wi-Fi card with the name `Wifi0`:

```
source=wlan0:name=Wifi0
```

If there are no options, only the capture name is needed:

```
source=wlan0 
```

### Launching Kismet with a source on the command line

Sources are added with the `-c` option on the command line when launching Kismet.  This takes priority over any other configuration - if any source is provided on the command line, *only* the sources listed on the command line are used!

```bash
kismet -c wlan0:name=Wifi0
```

Multiple `-c` options can be passed for multiple datasources:

```bash
kismet -c wlan0:name=Wifi0 -c wlan1:name=Wifi1
```

### Configuring datasources in kismet_site.conf

Sources can be permanently added to the `kismet_site.conf` [override config file](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf).  You can add multiple datasources with multiple `source=` lines:

```
source=wlan0:name=Wifi0 
source=wlan1:name=Wifi1
```

## Naming and describing datasources 

A datasource is by default named after the interface: `source=wlan0` will create a datasource named `wlan0`.

You can provide an arbitrary name to help identify the source; this name is shown in the web UI and recorded in the database.

Naming sources is particularly useful when recording from multiple systems or using [remote capture](/docs/readme/remotecap/remotecap/) where there may be multiple systems connected to one Kismet server which all have `wlan0`.

You can also annotate a source with information about the antenna and amplifiers; this is logged in the kismetdb log and can be used by other tools.

Source description options:

{{<configopt name custom_name>}}
Give the source a human-readable name.  This name shows up in the web UI and the Kismet log files.  This can be extremely useful when running remote capture where multiple sensors might all have `wlan0`, or simply to give interfaces a more descriptive name.

```
source=wlan0:name=foobar_some_sensor
```
{{</configopt>}}


{{<configopt info_antenna_type antenna_type>}}
Give the source a human-readable antenna type.  This type shows up in the logs.

```
source=wlan0:name=foobar,info_antenna_type=omni
```
{{</configopt>}}


{{<configopt info_antenna_gain value_in_db>}}
Antenna gain in dB.  This gain is saved in the Kismet logs that describe the datasources.

```
source=wlan0:name=foobar,info_antenna_type=omni,info_antenna_gain=5.5
```
{{</configopt>}}


{{<configopt info_antenna_orientation antenna_orientation_in_degrees>}}
Antenna orientation, in degrees.  This is useful for a fixed antenna deployment where different sources have physical coverage areas.

```
source=wlan0:name=foobar,info_antenna_orientation=180
```
{{</configopt>}}


{{<configopt info_antenna_beamwidth width_in_degrees>}}
Antenna beamwidth in degrees.  This is useful for annotating sources with fixed antennas with specific beamwidths, like sector antennas.

```
source=wlan0:info_antenna_type=sector,info_antenna_beamwidth=30
```
{{</configopt>}}


{{<configopt info_amp_type amplifier_type>}}
Arbitrary human-readable type of amplifier, if one is present, this is added to the logs for the datasource.

```
source=wlan0:info_amp_type=custom_duplex
```
{{</configopt>}}


{{<configopt info_amp_gain amplifier_gain_in_db>}}
Amplifier gain, if any, in dB.  This is added to the logs for the datasource.

```
source=wlan0:info_amp_type=custom_duplex,info_amp_gain=20
```
{{</configopt>}}

## Setting source type 

Nearly all sources in Kismet will autodetect the type.  You can manually set the type for the datasource by using the `type=...` source option.  The official type name for each datasource is in the documentation for the sources.

There are few situations where you will need to manually specify the type:

1. A datasource which does not auto-detect 

    These will be clearly marked in the documentation for each data source.

2. A datasource which may not be present when Kismet is started, that you would like Kismet to automatically enable when it becomes available 

    Kismet will not attempt to re-open a datasource which couldn't be found on startup, to prevent eternally spamming the console with open errors.  You can force Kismet to keep trying to re-open the source by passing a type, which forces Kismet to view the source as a known source in an error state.  For instance:

    `source=wlan0:type=linuxwifi`

## Setting source IDs

Typically Kismet generates a UUID based on attributes of the source - the interface MAC address if the datasource is linked to a physical interface, the device's position in the USB bus, or some other consistent identifier.

To override the UUID generation, the `uuid=...` parameter can be set:

```
source=wlan0:name=foo,uuid=AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE
```

If you are assigning custom UUIDs, you **must ensure** that every UUID is **unique**.  Each data source **must have** its own unique identifier.

You can generate a UUID using the `uuidgen` tool.

Most datasource types do not need a custom UUID set, the most notable exception being some SDR-based **remote** sources, where multiple SDR devices can have the same serial number and same position on the USB bus on different capture devices.  Check the documentation for the sources you use for information about UUID conflicts.

## Attaching a "meta" GPS

*Added in Kismet-2022-01-R3*

Sometimes, you might want to connect a specific source to a different GPS, for instance when using [remote capture](/docs/readme/remotecap/remotecap/).  A "meta-gps" device reports location to Kismet and is attached to a specific datasource, but obtains location data from the REST API.

To set a meta GPS, use the `metagps` parameter:

```
source=wlan0:name=foo,metagps=foobar
```

More likely, you will use this as part of [remote capture](/docs/readme/remotecap/remotecap/):

```bash
$ kismet_cap_linux_wifi --connect *host* --source wlan0:name=remote1,metagps=remote1
```

You will then need to use an additional tool to populate the GPS, using the [metagps api](/docs/api/gps/#meta-gps).

Multiple datasources can use the same meta GPS, or have independent meta GPS devices (or use the system-wide GPS if no metagps is specified).

## Datasource errors 

Kismet will attempt to re-open any datasource which has gone into error state.


### Default options

When no options are provided for a data source, the defaults are controlled by settings in kismet.conf; these defaults are applied to all new datasources:

{{<configopt channel_hop true false>}}
Universally enable or disable channel hopping.

A radio can typically only tune to a single channel at a time.  To capture from multiple channels, Kismet needs to rapidly change channel.

Typically, channel hopping should be left on.  It can be disabled per-source as a source option to zero in on a specific channel.
{{</configopt>}}


{{<configopt channel_hop_speed "channels/sec" "channels/min">}}
Control how quickly Kismet hops channels.

Finding the right balance of channel hopping speed can depend on your environment, hardware, and capture goals.

The faster Kismet hops channels, the more likely it is to spot a device, but the less likely it is to capture useful data because it will leave the channel equally quickly.  Conversely, a slow hopping speed may show a more accurate representation of data use, but can miss devices which briefly transmit.

The maximum channel hop rate is also impacted by both the protocol itself - the minimum amount of time for a complete packet to be transmitted - and the hardware and drivers ability to set channels.

Adding additional datasources is often the best way to increase coverage, as it allows multiple channels to be observed at the same time.

By default, Kismet hops 5 times a second, which is a reasonable balance for most datasource types.  Individual datasources can also have independent hop rates.

Examples:

```
channel_hop_speed=5/sec
channel_hop_speed=10/min
```
{{</configopt>}}


{{<configopt split_source_hopping true false>}}
Divide channels between multiple datasources with the same coverage.

Kismet can capture from multiple datasources at once; for example two, three, or more Wi-Fi cards.  To increase coverage, Kismet will split the channel list between datasources which have the same channel support and hopping rate.

Generally there is no reason to disable this option.
{{</configopt>}}


{{<configopt randomized_hopping true false>}}
Offset the channel hop pattern to maximize coverage when channels overlap.

On some common datasources, like Wi-Fi, channels can overlap (2.4GHz channels overlap by a significant amount).  By offsetting the channel hop sequence by the overlap, Kismet can use the overlap to increase coverage of adjacent channels.

Generally, there is no reason to turn this off.
{{</configopt>}}


{{<configopt retry_on_source_error true false>}}
Kismet will try to re-open a source which is in an error state after five seconds.  This helps Kismet re-open sources which are disconnected or have a driver error.

There is generally no reason to turn this off.
{{</configopt>}}


{{<configopt timestamp true false>}}
Typically, Kismet will override the timestamp of the packet with the local timestamp of the server; this is the default behavior for remote data sources, but it can be turned off either on a per-source basis or in `kismet.conf` globally.

Generally the defaults have the proper behavior, especially for remote data sources which may not be NTP time synced with the Kismet server.
{{</configopt>}}



### Multiple Kismet Datasources

Kismet will attempt to open all the sources defined on the command line (with the `-c` option), or if no sources are defined on the command line, all the sources defined in the Kismet config files.

If a source has no functional type and encounters an error on startup, it will be ignored - for instance if a source is defined as:

```
source=wlx4494fcf30eb3
```

and that device is not connected when Kismet is started, it will raise an error but will be ignored.

To force Kismet to try to open a device which could not be found at startup, you will need to provide the source type; for instance, the same source defined with the type field:

```
source=wlx4494fcf30eb3:type=linuxwifi
```

will continually try to re-open the device.

