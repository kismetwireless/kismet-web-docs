---
title: "Remote Capture"
description: ""
lead: ""
date: 2022-09-15T16:40:58-04:00
lastmod: 2022-09-15T16:40:58-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "remotecap-d0d709855f7b3cc86f7ea17c20c04694"
weight: 10
toc: true
---

Kismet supports transparent remote capture, using the same sources that can capture locally.

Remote capture is helpful for:

* Monitoring multiple locations simultaneously.

    Multiple sensors can be installed throughout a building, and all packets sent to a single Kismet capture server.

* Capturing from a large number of data sources.

    Large numbers of data sources can exhibit issues as the load is increased on the USB bus (for USB based radios), and on the kernel infrastructure.

    These effects can be alleviated by using lighter-weight hardware to capture from smaller numbers of data sources, sending the packets to a higher capacity server for processing.

* Reducing antenna distance.

    Similar to placing multiple sensors throughout a location, placing a remote capture sensor with a short antenna cable can reduce cabling and signal loss.

## Starting remote capture

Kismet remote capture is part of the Kismet capture tools; the same tools launched by Kismet can be launched individually in remote mode.

| Datasource | Capture tool |
| ---------- | ------------ |
| ADSB | kismet_cap_sdr_rtladsb |
| Bluetooth - HCI | kismet_cap_linux_bluetooth |
| Bluetooth - NRF51822 | kismet_cap_nrf_51822 |
| Bluetooth - NXP KW41Z | kismet_cap_nxp_kw41z |
| Bluetooth - TICC 2540 | kismet_cap_ti_cc_2540 |
| Bluetooth - Ubertooth | kismet_cap_ubertooth_one |
| Meters - AMR | kismet_cap_sdr_rtlamr |
| Sensors - rtl_433 | kismet_cap_sdr_rtl433 |
| Wi-Fi - Linux | kismet_cap_linux_wifi |
| Wi-Fi - macOS | kismet_cap_osx_corewlan |
| Wi-Fi - BladeRF2 | kismet_cap_bladerf_wiphy |
| Wi-Fi - Hak5 Coconut | kismet_cap_hak5_wifi_coconut |
| Zigbee - Freaklabs | kismet_cap_freaklabs_zigbee |
| Zigbee - NRF52840 | kismet_cap_nrf_52840 |
| Zigbee - NXP KW41Z | kismet_cap_nxp_kw41z |
| Zigbee - Raven AVR | kismet_cap_rz_killerbee |
| Zigbee - TICC 2531 | kismet_cap_ti_cc_2531 |

For each device you use for remote capture, you will need to start a remote capture process.

### Remote capture sources

Each remote capture defines the Kismet source, using the same [source definitions](/docs/readme/datasources/datasources/) as the rest of Kismet.

Source definitions are passed on the `--source` parameter.

### Remote capture prototocol

Remote captures connect to Kismet via Websockets (modern) or raw TCP (legacy).

Remote captures default to websockets mode unless `--tcp` is passed.

### Datasources must be unique

Every datasource in Kismet must have a unique identifier, the source UUID. Kismet calculates this using the MAC address (when available) of the capture device, or on other source types, the serial number, USB information, or other identifying characteristics.

Not all devices provide sufficient unique identifiable information; for instance the RTL-SDR hardware often reports a serial number of "00000000". This is not a problem when using a single device or capturing from a single remote capture, however if multiple remote capture devices advertise the same identity, problems occur.

For some source types this can be solved permanently with a source-specific tool; for RTL-SDR the device serial number can be set using the `rtlsdr_eeprom` tool as part of the rtlsdr software packages; remember, the serial number is used to derive the unique ID in Kismet, and therefore must be unique across all devices!

For other data sources, or to avoid changing the eeprom of the RTL-SDR, Kismet accepts the `uuid=` parameter on the source definition.  When using non-Wi-Fi datasources over remote capture, you will likely need to set a unique remote UUID for each source.

Unique IDs can be generated with a tool like `genuuid`, or non-random UUIDs can be assigned so long as they fit the UUID pattern of `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`

## Websockets

### About websockets

As of Kismet 2020-10, remote capture works over websockets as well as a basic TCP protocol, and defaults to using websockets.

Websockets are a standard extension on top of HTTP, which allows a connection to function more like a traditional stream; websockets can maintain a continual connection and pass real-time data, but remain portable through most HTTP proxy software.

Websocket remote capture adds:

* Single port for Kismet server and remote capture

    All communication is done over the standard Kismet port, `2501` by default.

* Authentication

    Remote capture over websocket can authenticate either using the Kismet username and password, or using a restricted API key with the `datssource` role.

* Proxy capable

    Remote capture can be proxied via standard web proxies like nginx, allowing Kismet to run safely on an internal network while remote capture is encrypted and proxied.

* Encryptable

    When exposed via a proxy like nginx, remote capture over websockets can be easily wrapped in SSL, including [letsencrypt](https://letsencrypt.org) provisioned easily via certbot.

To use remote capture over websockets, the remote capture tools must be compiled with websockets support.  Some older distributions do not ship with a working libwebsockets implementation, either update the distribution on the remote sensor, or use the legacy TCP configuration for remote capture.

### Proxying websockets

Websockets can be proxied by almost all HTTP proxy servers, such as nginx.

Check the [webserver documentation](/docs/readme/configuring/webserver/#using-proxies-and-forwarding) for more information on configuring Kismet with HTTP proxies.

### Websocket parameters

{{<argument connect "host:port">}}
Connect to the Kismet server at `{host}:{port}`.

If connecting directly to a Kismet server, this will be port `2501`; if connecting to a Kismet server behind a web proxy, this may be port `80` or `443`, or any other port as configured in your proxy.
{{</argument>}}


{{<argument ssl>}}
Connect via SSL (https).  If the SSL certificate is in the system certificate lists, no additional options are required, for instance, using a [LetsEncrypt](https://letsencrypt.org) certificate.

If doing remote capture over a public network connection, always use SSL (or otherwise protect the remote capture)
{{</argument>}}


{{<argument endpoint "endpoint-url">}}
Specify an alternate endpoint for the websocket connection.  By default, remote capture connections are terminated in Kismet at `/datasource/remote/remotesource.ws`

This should only need to be changed if using a HTTP proxy and re-homing Kismet under an alternate directory.

Supplied endpoints should include the full path to the websocket endpoint; for example:

`--endpoint=/proxy/kismet/datasource/remote/datasource.ws`
{{</argument>}}


{{<argument ssl-certificate "certificate file">}}
Provide a trusted certificate chain used to validate the SSL certificate.  Typically this is only required when using a self-signed or otherwise untrusted SSL certificate.
{{</argument>}}


{{<argument user username>}}
Username used to authenticate to the remote capture connection, if not using an API key.

Generally, an API key is preferred.
{{</argument>}}


{{<argument password password>}}
Password for authenticating to the remote capture connection, if not using an API key

Generally, an API key is preferred.
{{</argument>}}


{{<argument apikey key>}}
Use an API key instead of a username and password.  This API key should have a `datasource` role.

Generally, an API key is the preferred way of connecting remote sources.
{{</argument>}}

## TCP

Kismet legacy remote capture uses a pure TCP socket, which is by default on port `3501`.

Legacy remote capture does not support authentication, but can be protected with SSH port forwarding, VPN, or similar.

By default, Kismet will only listen on localhost:3501 for remote capture connections; this allows tunneling over SSH port forwarding or similar tricks, while not exposing your Kismet server.

If you change this option, *make sure* that you are not exposing your remote capture port to an untrusted network!

### TCP options

{{<argument tcp>}}
Connect using the legacy TCP socket, instead of websockets.

Remember, TCP doesn't support user authentication, API keys, or SSL!

To protect your remote cap using TCP, be sure to tunnel it through an encrypted tunnel like SSH or a VPN, and never expose your remote capture port to an untrusted network.
{{</argument>}}

### Connecting over a SSH tunnel

Set up a tunnel from the remote sensor to your Kismet server, for example using SSH port forwarding. This is very simple to do, and adds encryption transparently to the remote packet stream. This can be done as simply as:

```bash
ssh someuser@192.168.1.2 -L 3501:localhost:3501
```

This sets up a SSH tunnel from localhost port 3501 to 192.168.1.2 port 3501. Then in a second terminal running the Kismet remote capture, using localost:3501 as the destination:

```bash
/usr/local/bin/kismet_cap_linux_wifi --connect localhost:3501 --source=wlan1
```

Other, more elegant solutions exist for building the SSH tunnel, such as [autossh](https://linux.die.net/man/1/autossh) which can be used to automatically maintain the tunnel and start it on boot.

### Connecting over VPN

A site-to-site or host-to-host VPN can be used to protect and tunnel remote capture connections.

Make sure to configure Kismet to expose the remote capture service to an address on your VPN!

### Exposing remote capture

Kismet can be configured to accept connections on a specific interface, or from all IP addresses, by changing the remote_capture_listen= line in kismet.conf or kismet_site.conf as an override. To enable listening on ALL network interfaces:

```
remote_capture_listen=0.0.0.0
```

Or a single specific network interface:

```
remote_capture_listen=192.168.1.2
```

Remote capture should only be enabled on interfaces on a protected LAN.  Remember, there is no authentication on TCP remote capture!

## Remote capture and GPS

Remote capture was not originally designed for use with a moving sensor as it is not optimized for bandwidth, and is designed to be as minimal a sensor as possible.

There are, however, options for tagging packets from a sensor with different coordinates than the Kismet server:

* Sensors in fixed locations

    For a remote capture sensor in a fixed location, use the `--fixed-gps` argument when launching the remote capture tool will tag all packets with that location information.

    Kismet will factor the remote sensor location into location averaging, seen-by locations, etc.

* Moving sensors

    *Added in Kismet 2022-01-R3*

    For a dynamic remote GPS, the `meta-GPS` system can be used.

    Each "meta" GPS is identified by name, and the GPS location is updated by an external tool communicating updates via the [MetaGPS REST API](/path/to/new/docs) endpoint.

    To set a meta-GPS name for a given source, use the `metagps` source option:

    ```
    kismet_cap_linux_wifi --connect 192.168.1.1:2501 --apikey foobarbaz --source wlan0:name=remote0,metagps=remote0
    ```

## Timestamps

By default, Kismet uses the timestamp of the Kismet server for all packets; typically this offers the best performance, as variances in system timestamps can cause invalid alerts or other problems as some packets arrive "in the past".

If you use NTP to sync system clocks between the Kismet server and all remote capture hardware, and if you need to preserve the exact time-of-arrival timestamp from the remote server, you can override time stamp handling on a per-source basis using the `timestamp=false` source parameter:

```
kismet_cap_linux_wifi --connect 192.168.1.1:2501 --apikey foobarbaz --source wlan0:name=remote0,timestamp=false
```

## Remote capture packages

The [packages on the Kismet site](/download/packages) bundle each capture driver independently.  Simply add the package repository per the instructions for your distribution, and install the tools you want:

```
sudo apt install kismet-capture-linux-wifi kismet-capture-nrf-51822
```

The list of datasource packages can be queried from your package manager, for instance

```
apt search kismet-capture
```

## Building remote capture only

By default, the Kismet `./configure` script will check for all the packages need to compile all of Kismet, and the Kismet `Makefile` will attempt to compile everything.

To compile only for remote capture, pass the `--enable-capture-tools-only` option along with any other options you pass to `configure`:

```
./configure --some-options --other-options --enable-capture-tools-only
```

Then, compile only the datasources:

```
make datasources
```
