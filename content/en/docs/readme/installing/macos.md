---
title: "macOS"
exerpt: "Compiling Kismet on macOS"
weight: 75
---

## Kismet on macOS 

Kismet on macOS supports the Airport internal WiFi NIC, the Hak5 WiFi Coconut USB device, the BladeRF2 SDR with WiPhy, and more, however it does *not* work with generic USB WiFi devices.  This is because there is a lack of monitor-mode capable drivers on macOS for third-party WiFi cards.

## Kismet in a VM 

Kismet may work in a VM which supports USB passthrough using a USB Wi-Fi card (or other USB capture types).  Parallels and VMWare Fusion are known to typically have good USB passthrough support, though not all devices will work. 

UTM and other virtual machines built on qemu may or may not work, as the libusb engine appears to have some problems with some devices and some versions of macOS.

## Installing with Brew 

Kismet can be installed directly on macOS via `brew`.

You will need to install the `brew` tool from [brew.sh](https://brew.sh).

To install the latest git development code:  

```
brew tap kismetwireless/kismet 
brew install --HEAD kismet-git
```

This will install the dependencies, download Kismet, build, and install it. 

The next release of Kismet will support `brew` based installation; for now, you'll need to use the nightly versions.

## Building it manually

### Install dependencies 

macOS requires the XCode toolchain from the Apple store.  Once installed, you will need to launch the XCode IDE at least once to accept the license; do so before using the command line tools.

You will need to install the `brew` tool from [brew.sh](https://brew.sh).  There are of course other package managers for MacOS; feel free to use any of them which have the required packages, but Brew is known to work.

#### Install the required packages via Brew:

```bash
brew install pkg-config python3 libpcap protobuf protobuf-c pcre librtlsdr libbtbb ubertooth libusb openssl libwebsockets rtl_433
```

### Clone git 

Clone Kismet from git.  If you haven't cloned Kismet before:

```bash
git clone https://www.kismetwireless.net/git/kismet.git
```

If you have a Kismet repo already:

```bash
cd kismet
git pull
```

### Configure
    
This will find all the specifics about your system and prepare Kismet for compiling.  If you have any missing dependencies or incompatible library versions, they will show up here.

```bash
cd kismet
LDFLAGS=-L$(brew --prefix)/lib CPPFLAGS="-I$(brew --prefix)/include -I$(brew --prefix openssl)/include" ./configure --with-openssl=$(brew --prefix openssl)
```

Pay attention to the summary at the end and look out for any warnings! The summary will show key features and raise warnings for missing dependencies which will drastically affect the compiled Kismet.

### Compile

```bash
make
```

You can accelerate the process by adding `-j #`, depending on how many CPUs you have.  To automatically compile on all the available cores:

```bash
make -j$(nproc)
```

Compiling modern C++ (such as the Kismet codebase) can require a significant amount of RAM.  You may need to limit the number of parallel compile processes if you encounter memory errors during compiling.

#### Compile-time dependency errors

Sometimes, when updating the git repository, files have changed significantly enough that the Makefile system does not automatically recover fully.  If you encounter errors about missing header files (`foo.h not found` for example), try removing all `.d` files and running `make` again:

```bash
rm *.d
```

These files are used to identify which parts of the code need to be recompiled; rarely, when code is moved around, they get confused.

If this still does not fix the problem, you can try a clean git checkout (remove the `kismet` directory and re-run the `git clone` and `configure` steps.)

### Installing

When installed suid-root, Kismet will launch the binaries which control the channels and interfaces with the needed privileges, but will keep the packet decoding and web interface running without root privileges.

```bash
sudo make install
```

