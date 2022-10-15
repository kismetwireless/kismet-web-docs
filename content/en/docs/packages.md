---
title: "Packages"
description: ""
lead: ""
date: 2022-08-17T16:26:28-04:00
lastmod: 2022-08-17T16:26:28-04:00
images: []
weight: 1
toc: true
category: false
url: "/packages/"
redirect_from:
    - /docs/howto/repos_deb/
    - /docs/readme/packages/
---

These repositories contain the latest Kismet versions, which may not be available in the standard repositories for your distribution; distributions typically pick up new releases at relatively long intervals, and will not include git or beta versions in the official packages.

These are repositories for several Linux distributions provide the latest Kismet release and nightly builds.  More are being added over time, and your distribution may already have modern packages (Pentoo, for instance).

## Remove any Kismet installed from source

If you have already installed Kismet from source, you should remove the manually installed versions.  

```bash
sudo rm -rfv /usr/local/bin/kismet* /usr/local/share/kismet* /usr/local/etc/kismet*
```

This is only necessary when switching from source installs to package installs.

## Release or git

The Kismet release packages are built from the latest tagged release.

If you'd like to live on the cutting edge, are helping with testing, or want to try the latest features and fixes under development, the nightly packages are built from the current git code. Typically the git code is usable, but may not always function properly. Nightly packages are generally built around 5AM UTC.

## Configuration and locations

The Kismet packages install Kismet and the capture tools into `/usr/bin/`, and the configuration files into `/etc/kismet/`.

If you're used to compiling from source, these are new directories, which match the standard locations for system packages.

## Kali Linux (Intel, Raspberry Pi)

Kali Linux (on i386, amd64, armhf - Raspberry Pi 3, Raspberry Pi 4, arm64 - Raspberry Pi 3 64bit, and armel - Raspberry Pi 0w)

### Release (beta and release versions)

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

## Debian / Raspbian Buster (Intel, Raspberry Pi)

Debian Buster (amd64, armhf - Raspberry Pi 3, Raspberry Pi 4)

*WARNING* - You will *not* be able to capture from the built-in Wi-Fi on the Raspberry Pi 3 or Pi 4 unless you also install the [nexmon driver patch](https://github.com/seemoo-lab/nexmon/).  This patch adds reverse-engineered monitor mode to the Broadcom driver.  You can still use USB devices, though!

### Release (beta and release versions)

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

## Debian Bullseye (Intel, Raspberry Pi)

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

## Ubuntu 18.04 Bionic (Intel)

Ubuntu 18.04 Bionic (i386, amd64):

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

## Ubuntu 20.04 Focal (Intel, Raspberry Pi)

Ubuntu 20.04 Focal  (amd64, arm)

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

## Ubuntu 22.04 Jammy (Intel, Raspberry Pi)

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

There are 2 primary builds of Kismet:  The debug build, and the normal build.

The debug build contains all the debugging symbols.  If you are helping test Kismet or debugging a problem, you want the debug symbols, however the debug version will take *significantly* more space.  By default, the `kismet` metapackage installs the stripped version.

To install Kismet and all related tools, the simplest method is by using the metapackage:

```bash
sudo apt install kismet
```

Individual tools can still be installed:

```bash
sudo apt install kismet-core kismet-capture-linux-bluetooth kismet-capture-linux-wifi kismet-capture-nrf-mousejack python-kismetcapturertl433 python-kismetcapturertladsb python-kismetcapturertlamr python-kismetcapturefreaklabszigbee kismet-logtools 
```

## Installing individual components

Most of the Kismet components will work independently - with the caveat of course that you will not be able to capture from a device if you don't have the required capture tool.

To install only the capture tools, for instance to build a remote-capture node, you can install just the individual components:

Follow the same instructions for adding the repository, and then install only the capture drivers you need:

```bash
sudo apt install kismet-capture-linux-wifi
```

or,

```bash
sudo apt install kismet-capture-linux-bluetooth
```

