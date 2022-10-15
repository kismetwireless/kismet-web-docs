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
Enable cross-origin resource sharing (CORS). To access the REST API from an web app hosted on a different origin (domain, protocol, or port) to the Kismet webserver this option needs to be set to true. The `http_allowed_origin` option will also need to be configured to pass CORS. 
{{</configopt>}}


{{<configopt httpd_allowed_origin "http://origin.url">}}
Sets the webserver `Access-Control-Allow-Origin` response header. The origin is the full address of the server hosting your web app including protocol and port number. Because [nearly all Kismet REST endpoints require authentication](/docs/devel/webui_rest/endpoints/) an actual origin, not a `*` wildcard, should be specified to meet the CORS specification. The `httpd_allow_cors` option is also required to enable CORS cross-site requests. 
{{</configopt>}}

{{<configopt httpd_port port>}}
Sets the port for the webserver to listen to.  By default, this is port 2501, the port traditionally used by the Kismet client/server protocol. Kismet typically should not be started as root, so will not be able to bind to ports below 1024.  If you want to run Kismet on, for instance, port 80, this can be done with a proxy or a redirector, or via DNAT rewriting on the host. 
{{</configopt>}}

{{<configopt httpd_bind_address "a.b.c.d">}}
Added `2019-03`

Typically Kismet listens on all interfaces; To restrict Kismet to a single interface (such as the loopback address), set the address in the `httpd_bind_address` option.  To restrict binding to the loopback interface only, use `http_bind_address=127.0.0.1`.
{{</configopt>}}

{{<configopt httpd_uri_prefix "/prefix">}}
Added `2019-03`

Sets the URI prefix - this prefix is an optional lead-in value to all the existing URIs in Kismet which allows it to be run via a HTTP proxy such as nginx.  For example, setting a httpd_uri_prefix of `/kismet/` would allow proxying from the `/kismet/` directory of a nginx server. 
{{</configopt>}}

{{<configopt httpd_home "/path/to/httpd/data">}}
Path to static content web data to be served by Kismet.  This is typically set automatically to the directory installed by Kismet in the installation prefix. Typically the only reason to change this directory is to replace the Kismet web UI with alternate code or when doing development on the Kismet UI so that changes can be immediately reflected.
{{</configopt>}}

{{<configopt httpd_user_home "/path/to/user/httpd/data">}}
Path to static content stored in the home directory of the user running Kismet.  This is typically set to the httpd directory inside the users .kismet directory. This allows plugins installed to the user directory to install web UI components. Typically there is no reason to change this directory. If you wish to disable serving content from the user directory entirely, comment this configuration option out.
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

## Runtime censorship 

Kismet can censor aspects of the UI to make it easier to share screenshots or demos without revealing your location via MAC addresses, SSIDs, or location data.

Censorship mode can be enabled by adding `?censor=1` to the Kismet URL, for instance `http://localhost:2501?censor=1`

## Kismet and SSL

The best way to provide SSL support for Kismet is to wrap it with a HTTP proxy such as nginx.  This simplifies the process of obtaining public certificates from services like letsencrypt, which typically expect the webserver to be able to answer dynamic challenges.

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

