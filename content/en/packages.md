---
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

Installing Kismet from packages highlights the utility of the (kismet_site.conf)[/docs/readme/configuring/configfiles/#customizing-configs-with-kismet_siteconf] configuration override file.

By placing any configuration changes in this override, you will be able to upgrade the Kismet packages at any time without losing configuration changes or raising configuration conflict errors.

## Release or git

If you'd like to be on the cutting edge of testing, you can pull Kismet from nightly git builds.  These builds take the latest git version and compile it - this version has all the absolutely latest features, but also is the most likely to have new, exciting bugs.  The git version is *generally* fine to use, but is not recommended for installations that need consistency or long-term support, and if you're about to capture unique data or drive a long distance, be sure to test all the features you plan to use before doing so!

The release versions are built from the latest tagged releases.

## Hardware platforms 

Packages are built for specific hardware platforms; your package manager shoudl automatically select packages for your platform.

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

## Kali Linux

Kali Linux (amd64, armel, armhf, arm64)

### Release

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/kali kali main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/kali kali main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Debian / Raspbian Buster 

Debian Buster (amd64, arm64)

*WARNING* - You will *not* be able to capture from the built-in Wi-Fi on the Raspberry Pi 3 or Pi 4 unless you also install the [nexmon driver patch](https://github.com/seemoo-lab/nexmon/).  This patch adds reverse-engineered monitor mode to the Broadcom driver.  You can still use USB devices, though!

### Release

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/buster buster main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/buster buster main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Debian Bullseye

Debian Bullseye (i386, amd64, armhf, arm64)

### Release (beta and release versions)

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/bullseye bullseye main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/bullseye bullseye main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Debian Bookworm

Debian Bookworm (amd64, arm64)

### Release (beta and release versions)

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/bookworm bookworm main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/bookworm bookworm main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Ubuntu 18.04 Bionic 

Ubuntu 18.04 Bionic

***Note***: The Bionic packages do not include support for all features, due to limitations in the packages available for Bionic.  You may be able to manually install newer versions of the required libraries and compile from source.

The following are not available in the Bionic packages:

* Remote capture via websockets (server support is present, but datasources will not be able to export over remote capture)

### Release (beta and release versions)

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/bionic bionic main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git


```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/bionic bionic main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Ubuntu 20.04 Focal 

Ubuntu 20.04 Focal  (amd64, armhf, arm64)

### Release (beta and release versions)

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/focal focal main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/focal focal main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

## Ubuntu 22.04 Jammy

Ubuntu 22.04 Jammy  (amd64, arm)

### Release (beta and release versions)

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/release/jammy jammy main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

### Nightly git

```bash
wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key | sudo apt-key add -
echo 'deb https://www.kismetwireless.net/repos/apt/git/jammy jammy main' | sudo tee /etc/apt/sources.list.d/kismet.list
sudo apt update
sudo apt install kismet
```

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

