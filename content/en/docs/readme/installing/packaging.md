---
title: "Packaging"
description: ""
date: 2022-08-09T00:00:00+00:00
lastmod: 2022-08-09T00:00:00+00:00
images: []
url: "/docs/readme/packaging/"
toc: true
---

Every distribution is different, and has different idioms for configuration location
and style, but we recommend the following guideliens for packages where ever possible.

Of all the guidelines, perhaps the most important is to provide a suid or setcap
option; Kismet is designed to run only the minimal required components with
elevated privileges, and it is much more secure to run the main Kismet server as
a non-privileged normal user.

Example packages for various distributions are in the [kismet-packages](https://github.com/kismetwireless/kismet-packages) repository.

### Provide a suid (or setcap) install option

The Kismet capture binaries (`kismet_cap_linux_wifi`, `kismet_cap_linux_bluetooth`,
and so on) require root privileges to control the interfaces, however generally
Kismet itself should not be run as root.

Kismet supports two mechanisms for privilege separation:

1. Installing the binaries setuid root, and restricting access to them by
   limiting them to a specific group (`kismet`, by preference).
2. Installing the binaries normally, but using `setcap` to give them
   authority to change network settings: `setcap cap_net_raw,cap_net_admin=eip`,
   and restricting them to a single group (`kismet` again, by preference).

When installed suid-root, the Kismet helper utilities will drop capabilities
and pivot into a read-only mount namespace.

### Building with Protobufs support

Until `2025-09-R1` the Kismet IPC and remote capture datasource protocol was based on
Google Protobufs.  The Protobufs dependency has become increasingly difficult to
deal with in a portable fashion, and has been superceded by a much simpler
protocol encoded via messagepack.  The messagepack encoder is embeded in the
Kismet source.

For `2025-09-R1` and possibly the next major release after, the legacy Protobufs
protocol remains available as an optional compile-time toggle.  Packagers are
generally recommended to enable it, as this allows older remote capture installs
to still talk to the new Kismet server until the user has upgraded them, however
it likely is not a major issue if carrying the protobufs dependency is
problematic.

Legacy protobufs support will likely be completly removed once upgrading remote
captures is no longer of concern.

### Provide multiple packages for capture tools

Kismet capture tools can be packaged independently.  By preference, the capture tools should be independent packages so that a user building a remote capture system only needs the specific capture packages.  A meta-package which references all of the capture tools can provide a simple installation point for users.

### Default prefix

The Kismet configure defaults to `/usr/local/`; typically a distribution package would target `/usr` as the prefix.  This can be adjusted as per LSB and distribution guidelines.

### Data files

Kismet installs data and lookup files to `${prefix}/share/kismet/`; these include `kismet_manuf.txt.gz` and `kismet_adsb_icao.txt.gz` and in the future will include similar files for Bluetooth service resolution.

The manuf file should, if possible, always be installed - this is the lookup database for manufacturer assignments
based on MAC address.  For *extremely* size constrained distributions this file could be omitted (preferably moved
to a separate so that a user can choose to install it), however the user experience will be degraded as
manufacturers will no longer be detected.

The ICAO file is particularly large (6+ MB, gzipped).  This file is used to resolve the FAA ICAO registration for ADSB.
In the main Kismet packages, this is installed as a by-default included, but independent, package.  For any platform
where storage is a concern, this file can be split into an independent package.  The user experience will only be
impacted if the user is using a SDR to capture ADSB airplane data.

### Config files

Kismet looks for config files in the directory specified in `configure` via the `--sysconfdir` directive.
This location may vary per distribution, however typically `/etc/kismet` would be the appropriate default,
and is the location used by the packages provided on the Kismet site.

#### Use kismet_package.conf

When building packages for tiny systems, like under OpenWRT, you can include a `kismet_package.conf` in
your package; the default Kismet configs will first load the Kismet configuration files, then, if
present, a `kismet_package.conf` configuration file which will override any options specified, and
finally, `kismet_site.conf` which will override any previous settings.

This setup allows tuning Kismet automatically for inclusion on some systems, while removing the
need to maintain patches to the base Kismet configs.

`kismet_package.conf` should be placed in the configuration directory with the other Kismet configs.

#### Never override kismet_site.conf

Kismet provides an override mechanism for local configurations which take precedence over all
other config options; these are kept in `kismet_site.conf` by default.  A package should never
provide this file, as changes made by the user will likely go here.  You can auto-configure
options via `kismet_package.conf` however.

### Package log tools

Kismet provides a suite of tools for interacting with the kismetdb logs (built in the `log_tools/`
directory).  Typically it would make sense to make a package encompassing the suite of tools
rather than build them as part of the core package.

### Protobuf-lite

Some distributions (like OpenWRT) use libprotobuf-lite to save space.  Kismet does not use any of
the options removed in the lite version, but *should* be configured with
the `--enable-protobufite` option to `./configure`.

