---
layout: "docs"
title: "Packages"
description: ""
date: 2022-09-18T17:36:41-04:00
lastmod: 2022-09-18T17:36:41-04:00
images: []
toc: true
---

These repositories are maintained on the Kismet server, and contain the latest Kismet releases and nightly package builds.

There are automatically-built repositories for Kismet on several Linux distributions.  More are being added over time.

Some distributions, such as Pentoo, offer up-to-date packages and mechanisms for building the latest git code.

## Before installing the Kismet packages

### Remove any Kismet installed from source

Firstly, before switching to a packaged version of Kismet, you will need to remove any Kismet versions installed from source.

This can be done with:

```bash
sudo rm -rfv /usr/local/bin/kismet* /usr/local/share/kismet* /usr/local/etc/kismet*
```

### Remove any other Kismet packages

If you installed Kismet packages from your distribution already, remove them first.

While efforts are made to make sure the Kismet repositories can cooperate with any distribution-sourced packages, sometimes there are problems and conflicts.

## Configuration and locations

The packaged version of Kismet installs into the standard directories for packaged tools, based on `/usr/`, while building from source defaults to the user-compiled directory, `/usr/local/`.

Additionally, the packaged versions of Kismet place all the configuration files in a single directory; by default, `/etc/kismet/`.

### Use kismet_site.conf

Installing Kismet from packages highlights the utility of the [kismet_site.conf](/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf) configuration override file.

By placing any configuration changes in this override, you will be able to upgrade the Kismet packages at any time without losing configuration changes or raising configuration conflict errors.

## Release or git

If you'd like to be on the cutting edge of testing, you can pull Kismet from nightly git builds.  These builds take the latest git version and compile it - this version has all the absolutely latest features, but also is the most likely to have new, exciting bugs.  The git version is *generally* fine to use, but is not recommended for installations that need consistency or long-term support, and if you're about to capture unique data or drive a long distance, be sure to test all the features you plan to use before doing so!

The release versions are built from the latest tagged releases.

## Hardware platforms

Packages are built for specific hardware platforms; your package manager should automatically select packages for your platform.

| Platform | Type | Devices |
| -------- | ---- | ------- |
| i386 | x86 32-bit (Amd and Intel) | Generic PC, Laptop, Servers, legacy 32-bit |
| amd64 | x86 64-bit (Amd and Intel) | Generic PC, Laptop, Servers |
| armhf | ARM + Floating point  | Raspberry Pi 3 32-bit, Raspberry Pi 4 32-bit |
| armel | Legacy ARM | Raspberry Pi 0, Raspberry Pi 0-2 (kali) |
| arm64 | Arm 64-bit | Raspberry Pi 3 64-bit, Raspberry Pi 4 64-bit, Apple Silicon virtual machines |

## Pick the right packages!

Many Debian-derived distributions are very similar, but be sure to pick the packages for *your* distribution.

Installing packages from another distribution, or another version, *may* work sometimes, but often results in errors about missing library packages or similar.

{{< kismet_packages >}}

## Suid-root / privileged capture

During the package install process, you will be prompted to install Kismet with suid-root, or without; We strongly recommend installing the capture sources as suid-root!

Kismet is split between the actual Kismet server itself (which processes packets, presents the UI, performs logging, etc) and the packet datasources (capture programs which actually collect packets and send them to the server).

Many datasources require root privileges to be able to reconfigure the device, change channel, etc.  However, generally it is unwise to run the Kismet server itself as root:  While Kismet is written with security in mind, any vulnerabilities in the code could then be used with root privileges as well.

To address this, Kismet can be installed with the datasources configured as suid-root or with elevated capabilities.  To further protect the install from untrusted users being able to reconfigure network interfaces, users running Kismet need to be part of the `kismet` group.

After installing Kismet as suid-root, be sure to add your user to the `kismet` group:

```bash
sudo usermod -aG kismet your-user-here
```

Once you've added your user to the group, you *will need to reboot your system* because Linux does not refresh the groups until the user logs into a new session!

## Installing Kismet

To install the standard version and all related tools, the simplest method is by using the metapackage:

```bash
sudo apt install kismet
```

Individual tools can still be installed:
```bash
sudo apt install kismet-core kismet-capture-linux-bluetooth kismet-capture-linux-wifi kismet-capture-nrf-mousejack python-kismetcapturertl433 python-kismetcapturertladsb python-kismetcapturertlamr python-kismetcapturefreaklabszigbee kismet-logtools
```

## Installing piecemeal

Most of the Kismet components will work independently - with the caveat of course that you will not be able to capture from a device if you don't have the required capture tool.

To install only the capture tools, for instance to build a remote-capture node, you can install just the individual components.

Follow the same instructions for adding the repository, and then install only the capture drivers you need:

```bash
sudo apt install kismet-capture-linux-wifi
```

or,

```bash
sudo apt install kismet-capture-linux-bluetooth
```

## Building packages

The Kismet packages are built using [fpm](https://fpm.readthedocs.io/en/v1.14.2/), Docker, and a collection of scripts for automation.

The Dockerfiles and scripts are all available in the [kismet-packages repo](https://github.com/kismetwireless/kismet-packages) on Github.
