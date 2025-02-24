---
title: "Downloads"
description: ""
lead: "Kismet and related projects primary download page"
date: 2022-08-09T00:00:00+00:00
lastmod: 2022-08-09T00:00:00+00:00
images: []
url: "/download/"
toc: true
---

### <a name="kismet-packages"></a>Kismet Packages

You can get packages for the latest Kismet code for many distributions from [the Kismet package repositories](/packages/).

{{< kismet_release >}}

### <a name="kismet-git"></a>Kismet git

Kismet uses git for code management; code under development is in the `master` branch of the git repository, and the development of new features happens here.

While the development code *may* be unstable, generally it is quite usable, and may offer features and bug fixes which haven't made it into a release version yet.

To get the latest code prior to release, check out the git master branch:

```bash
git clone https://www.kismetwireless.net/git/kismet.git
```

or to checkout from the Github mirror:

```bash
git clone https://github.com/kismetwireless/kismet.git
```

You can browse the development code [via Github here](https://github.com/kismetwireless/kismet)

[Nightly packages](/packages/) are also available, which are built for many distributions from the `master` branch of git.

### <a name="kismet-docs"></a>Kismet documentation

The Kismet documentation (in markdown/kramdown format used to generate the documentation for the website) is available as part of its own repository.  This repository is linked as a sub-module in the Kismet git tree, or is available stand-alone at:

```bash
git clone https://www.kismetwireless.net/git/kismet-docs.git
```

or the Github mirror:

```bash
git clone https://github.com/kismetwireless/kismet-docs.git
```

### <a name="kismet-python"></a>Kismet Python modules

Kismet has several Python modules which help when scripting against the Kismet server or Kismet data; these modules are being spun into their own repositories for easier inclusion in PyPy and similar.

#### py-kismetdb database module

A utility Python module for processing the Kismetdb log file format and extracting devices, packets, messages, and the other data stored therein.

```bash
git clone https://www.kismetwireless.net/git/python-kismet-db.git
```

or the Github mirror:

```bash
git clone https://github.com/kismetwireless/python-kismet-db.git
```

#### py-kismetrest module

A utility python module for interacting with the Kismet REST endpoints

```bash
git clone https://www.kismetwireless.net/git/python-kismet-rest.git
```

or the Github mirror:

```bash
git clone https://github.com/kismetwireless/python-kismet-rest.git
```

#### py-kismetexternal module

A utility python module for creating Kismet datasources and external-helper plugins

```bash
git clone https://www.kismetwireless.net/git/python-kismet-external.git
```

or the Github mirror:

```bash
git clone https://github.com/kismetwireless/python-kismet-external.git
```

### <a name="spectools-git"></a>Spectools

Spectools development code can be found in the spectools git at:

```bash
git clone https://www.kismetwireless.net/git/spectools.git
```

or you can download the Spectools-2016-01-R1 code release [here](/code/spectools-2016-01-R1.tar.xz)

### <a name="android-pcap-git"></a>Android PCAP

Android PCAP was an experiment in porting a Wi-Fi USB driver from Linux to the Android USB API; while functional, this targets only a very old version of an old driver, and an old version of Android, making the code likely of academic interest only.

```bash
git clone https://www.kismetwireless.net/git/android-pcap.git
```
