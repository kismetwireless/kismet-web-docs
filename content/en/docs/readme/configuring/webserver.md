---
title: "Webserver"
description: ""
lead: ""
date: 2022-08-23T21:43:28-04:00
lastmod: 2022-08-23T21:43:28-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "webserver-d2f2f9c23438c20d8feaa349557271b9"
weight: 40
toc: true
---

Kismet integrates a webserver which serves the web-based UI and data to external clients.

Kismet does not have a default username or password.  *The first time Kismet is run* the web UI will require the creation of a user and password.

The password is stored in `~/.kismet/kismet_httpd.conf` which is in the home directory of **the user which started Kismet**.

You will need this password to log into Kismet in the future, and to give scripts and tools which need administrative access to Kismet the login.

The webserver is configured via the `kismet_httpd.conf` file.  These options may be included in the base kismet.conf file, but are broken out for clarity.  We recommend you use `kismet_site.conf` to make changes to the configuration.

HTTP configuration options:

{{<configopt httpd_username username>}}
Set a global, fixed username.  This overrides any per-user login information in `~/.kismet/kismet_httpd.conf`.  This can be used to set a fixed password during deployment, for instance via `kismet_site.conf` overriding.  If `httpd_username=` is specified, `httpd_password=` *must* also be provided. 
{{</configopt>}}


{{<configopt httpd_password password>}}
Set a global, fixed password.  This overrides any per-user login information in `~/.kismet/kismet_httpd.conf`.  This can be used to set a fixed password during deployment, for instance via `kismet_site.conf` overriding. It is generally preferred to keep the username and password in the per-user configuration file, however they may also be set in the global config.
{{</configopt>}}


{{<configopt httpd_allow_cors true false>}}
Enable cross-origin resource sharing (CORS). To access the REST API from a web app hosted on a different origin (domain, protocol, or port) to the Kismet webserver this option needs to be set to true. The `http_allowed_origin` option will also need to be configured to pass CORS. 
{{</configopt>}}


{{<configopt httpd_allowed_origin "http://origin.url">}}
Sets the webserver `Access-Control-Allow-Origin` response header. The origin is the full address of the server hosting your web app including protocol and port number. Because [nearly all Kismet REST endpoints require authentication](/docs/api/rest_like/) an actual origin, not a `*` wildcard, should be specified to meet the CORS specification. The `httpd_allow_cors` option is also required to enable CORS cross-site requests. 
{{</configopt>}}

{{<configopt httpd_port port>}}
Sets the port for the webserver to listen to.  By default, this is port 2501, the port traditionally used by the Kismet client/server protocol. Kismet typically should not be started as root, so will not be able to bind to ports below 1024.  If you want to run Kismet on, for instance, port 80, this can be done with a proxy or a redirector, or via DNAT rewriting on the host. 
{{</configopt>}}

{{<configopt httpd_bind_address "a.b.c.d">}}
Added `2019-03`

Typically Kismet listens on all interfaces; To restrict Kismet to a single interface (such as the loopback address), set the address in the `httpd_bind_address` option.  To restrict binding to the loopback interface only, use `httpd_bind_address=127.0.0.1`.
{{</configopt>}}

{{<configopt httpd_uri_prefix "/prefix">}}
Added `2019-03`

Sets the URI prefix - this prefix is an optional lead-in value to all the existing URIs in Kismet which allows it to be run via a HTTP proxy such as nginx.  For example, setting a httpd_uri_prefix of `/kismet/` would allow proxying from the `/kismet/` directory of a nginx server. 
{{</configopt>}}

{{<configopt httpd_home "/path/to/httpd/data">}}
Path to static content web data to be served by Kismet.  This is typically set automatically to the directory installed by Kismet in the installation prefix. Typically the only reason to change this directory is to replace the Kismet web UI with alternate code or when doing development on the Kismet UI so that changes can be immediately reflected.
{{</configopt>}}

{{<configopt httpd_max_connections count>}}
After 2026-10-R1.  The most HTTP connections open at once, by default `512`.  Each open connection, including each web UI websocket, holds a thread and a socket until it closes; connections over the limit are refused at once.  `0` turns the limit off.
{{</configopt>}}

{{<configopt httpd_max_connections_per_ip count>}}
After 2026-10-R1.  The most HTTP connections open at once from one client address, by default `128`.  `0` turns the limit off.

Behind a [reverse proxy](#using-proxies-and-forwarding), every client shares the proxy's address, so raise this limit to cover all of them (or turn it off).
{{</configopt>}}

{{<configopt httpd_session_db "/path/to/session/db">}}
Path where API keys and session data is stored.  If you want to refresh the logins (and require browsers to log in again after each restart), comment this option. Typically there is no reason to change this option. 
{{</configopt>}}

{{<configopt httpd_mime "extension:mimetype">}}
Kismet supports MIME types for most standard file formats, however if you are serving custom content with a MIME type not correctly set, additional MIME types can be defined here. Typically, MIME types do not need to be added. 
{{</configopt>}}

{{<configopt httpd_jwt_key keystring>}}
Kismet uses JWT tokens to maintain session state.

By default, Kismet generates a random JWT key on startup, each time Kismet is started.  This key is used to protect the session tokens, but is lost when Kismet exits or restarts, requiring sessions re-authenticate. 

If you wish JWT sessions to persist, set a persistent key here, however this typically is not needed.
{{</configopt>}}

{{<configopt httpd_jwt_issuer issuer>}}
By default, Kismet uses a JWT issuer of `kismet`.  If you wish to change this for some reason, set this option.  

There is typically no benefit to changing this option.
{{</configopt>}}

## The web UI

After 2026-10-R1, Kismet serves a [new web UI](/docs/readme/webui/webui_intro/) at `/` (for instance `http://localhost:2501/`), and the previous UI at `/legacy/` (`http://localhost:2501/legacy/`).  The *Legacy UI* item in the new UI's top bar opens the previous UI.

Plugins which add pages to the previous UI keep working in it from `/legacy/`; the new UI lists plugins which don't have a page for it yet.

Both UIs use the same login, and settings in one don't change the other.

Other parts of the new UI:

* *Packet rates*, in the menu or from the packets count in the top bar, graphs the packet rate of each data source, with dropped packets, errors, and events such as sources opening, and links to the channel heat map.
* *Settings*, *Units* picks how speeds (km/h, mph, or knots) and lengths (meters and kilometers, or feet and miles) are shown, including the map's range rings.
* *Settings*, *Appearance*, *Device Highlights* colors rows in the device list by [device rule](/docs/readme/configuring/device_rules/#rules-in-the-web-ui) tag, by the type of radio (phy), and by other phy-specific highlights.  Tags and other highlights can be dragged into priority order; picking a color turns its highlight on.
* The device list has a *Tags* column, which can be searched and sorted, and the device details list a device's tags first, with the rules that set them.
* The device list's *Search or filter* box searches for plain words as before, and takes [device filters](/docs/readme/webui/webui_filters/).

The new UI's map can draw the [receiver range](/docs/readme/configuring/receiver_range/) for each kind of device on it: the furthest distance devices were heard at in each direction over all time, over the last day, or by altitude, with range rings.  Without Kismet's own location, it draws the area the devices were heard over.

### Installing the web UI as an app

After 2026-10-R1, the web UI can be installed on a phone or desktop as an app, with its own icon and window.  Browsers only allow this over HTTPS they trust, so the Kismet server must either use [Kismet's own HTTPS](#kismet-and-ssl), with the Kismet CA installed on the phone, or be [behind an HTTPS proxy](#using-proxies-and-forwarding) with a trusted certificate.  The *Install as an app* settings in the web UI walk through it, and the installed app can switch between Kismet servers.

## Runtime censorship 

Kismet can censor aspects of the UI to make it easier to share screenshots or demos without revealing your location via MAC addresses, SSIDs, or location data.

Censorship mode can be enabled by adding `?censor=1` to the Kismet URL, for instance `http://localhost:2501?censor=1`.  After 2026-10-R1, censorship is available in the legacy UI, for instance `http://localhost:2501/legacy/?censor=1`.

After 2026-10-R1, the new UI has censor mode under *Settings*, *Censor mode*, and also takes it from the page address, which wins over the settings for that page:

| Parameter | Hides |
| --------- | ----- |
| `censor=1` | MAC addresses, names and identifiers, and locations, partly |
| `censor_heavy=1` | All of them, completely |
| `censor_macs=1` | MAC addresses, and names |
| `censor_names=1` | Names and identifiers of devices and networks |
| `censor_location=1` | Locations, and the map |
| `censor_more=1` | Hides completely instead of partly |

Partly hidden, a MAC address keeps its manufacturer half, a name its first and last two characters, and a location its whole degrees.

## Kismet and SSL

The best way to provide SSL support for a Kismet server reached over the Internet is to wrap it with a HTTP proxy such as nginx.  This simplifies the process of obtaining public certificates from services like letsencrypt, which typically expect the webserver to be able to answer dynamic challenges.

After 2026-10-R1, Kismet can also serve HTTPS itself, on its own port alongside the plain HTTP port.  This is meant for a local network, such as reaching Kismet from a phone, and especially for installing the web UI as an app.

{{<configopt httpd_ssl true false>}}
Added after 2026-10-R1

Serve HTTPS on `httpd_ssl_port`, in addition to plain HTTP on `httpd_port`.  Disabled by default.
{{</configopt>}}

{{<configopt httpd_ssl_port port>}}
Added after 2026-10-R1

Port for the HTTPS listener, by default 2502.  It listens on the same address as `httpd_bind_address`.
{{</configopt>}}

{{<configopt httpd_ssl_cert "/path/to/cert.pem">}}
Added after 2026-10-R1

Use your own certificate: a PEM file holding the server certificate first, then any intermediate certificates.  Requires `httpd_ssl_key`.
{{</configopt>}}

{{<configopt httpd_ssl_key "/path/to/key.pem">}}
Added after 2026-10-R1

The private key for `httpd_ssl_cert`, in PEM format.
{{</configopt>}}

{{<configopt httpd_ssl_dir "/path/to/ssl/dir">}}
Added after 2026-10-R1

Without `httpd_ssl_cert` and `httpd_ssl_key`, Kismet makes a small certificate authority (CA) of its own in this directory (by default `~/.kismet/ssl/`), and a server certificate signed by it for this host's name, `name.local`, and its private addresses.  The server certificate is valid for 397 days; Kismet makes a new one at startup when it's within 30 days of expiring, or when this host's names or addresses change.

Install the CA (`kismet_ca.pem` in this directory, or download it from the *Install as an app* settings in the web UI, or from `/ssl/kismet_ca.crt`) on the phones and browsers which will use Kismet.  When installing it, check that its SHA-256 fingerprint matches the one Kismet logs at startup.

The CA can only sign for local names (`.local`, `.lan`, `.home.arpa`, `.internal`, `localhost`, this host's name, and names given in `httpd_ssl_names`) and private addresses, so even if its key were copied it couldn't be used to impersonate other sites.

To start over with a new CA, stop Kismet and remove the files in this directory.
{{</configopt>}}

{{<configopt httpd_ssl_names "name,address,...">}}
Added after 2026-10-R1

Extra names or addresses, comma separated, for the certificate Kismet makes, such as `httpd_ssl_names=kismet.lan,192.168.1.10`.
{{</configopt>}}

{{<configopt httpd_https_proxy true false>}}
Added after 2026-10-R1

Kismet is behind an HTTPS proxy with its own trusted certificate (such as one from Let's Encrypt).  Set `httpd_public_url` as well; the web UI then offers that address for installing the UI as an app, and there's no CA to install.
{{</configopt>}}

{{<configopt httpd_public_url "https://kismet.example.com/">}}
Added after 2026-10-R1

The address clients reach Kismet at through the proxy, for the web UI's install instructions.  Must start with `https://` or `http://`.
{{</configopt>}}

### When should I use SSL?

SSL provides encryption between the Kismet server and the web browser, and between the Kismet server and remote capture sources.

SSL is usually not considered necessary when using Kismet exclusively locally (such as on a laptop or on a dedicated capture device connected to your laptop), however if you plan to use Kismet remotely over a public network or over the Internet, enabling SSL is a must.

## Using proxies and forwarding

Kismet supports being proxied through a HTTP/HTTPS proxy such as nginx.  This allows using standard configuration of certs on the public server, instead of moving the configuration to Kismet.

1. Set up Kismet to support a proxy URI.
    By setting the `httpd_uri_prefix` variable, Kismet can handle a proxied URI directory:
    ```
    httpd_uri_prefix=/kismet
    ```

2. Set up the nginx proxy

    nginx proxy can connect HTTPS and HTTP endpoints.  In `/etc/nginx/sites-enabled/default`, a `location` stanza similar to:

    ```
    location /kismet/ {
        proxy_pass http://localhost:2501;
        proxy_set_header Host $http_host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header X-Proxy-Dir kismet/;
        add_header X-Proxy-Dir kismet/;
        proxy_http_version 1.1;
        client_max_body_size 0;
    }
    ```

    *Note the trailing slash* on the `proxy_set_header` and `add_header` lines!

3. Tunnel the Kismet server over SSH

    SSH supports port forwarding/tunneling; We can use this to bring a connection to the Kismet server to the proxy system:

    ```bash
    $ ssh -R *:2501:localhost:2501 user@host
    ```

###  Using LetsEncrypt certificates

LetsEncrypt (https://letsencrypt.org) provides free, signed SSL certificates which are accepted by most browsers.  These certificates can be used with Kismet and may offer a simpler and more secure option than self-signed certificates.

LetsEncrypt currently uses a set of python (or third-party) clients to automatically generate certificates.  In order to verify that you control the domain the certificate is issued for, you must run these scripts on the webserver with that domain.

The LetsEncrypt software can automatically configure Apache and nginx.

