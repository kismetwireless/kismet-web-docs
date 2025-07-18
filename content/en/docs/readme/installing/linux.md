---
title: "Linux"
excerpt: "Basic instructions for compiling on Linux-based systems"
weight: 50
toc: true
---

## Installing from package

Packages for many popular distributions are available on the [Kismet packages page](/packages/).

Make sure you're installing a modern version when installing from packages!  Some distributions still include the very old 2016 version of Kismet which predates the web UI and modern device support.

## Installing suid-root

Kismet has the option to be installed as a *suid-root* tool.

To configure network interfaces, the Kismet capture process needs root privileges.  These can be granted by running *all* of Kismet as root (`sudo kismet`), or by installing the capture tools as suid-root.

It is more secure to install the capture tools as suid-root than to run all of Kismet as root; this way *only* the capture process has root privileges.  The Kismet capture processes will self-revoke all but the necessary aspects of root access to minimize any attack surfaces.

## Installing from source

### Uninstall any previous Kismet installs

If you installed Kismet using a package from your distribution, uninstall it using your package management tools.  Typically packages are installed into `/usr/` while compiling from source defaults to `/usr/local`; leaving the package installed will interfere.

If you compiled Kismet from source, the safest course is to remove it manually, however if you did not change the install prefix, a new compile and install will overwrite it.

### Install dependencies

Kismet needs a number of libraries and  development headers to compile; these should be available in nearly all
distributions.  Some distributions use a single package for the libraries and development headers, while others split them
into `-devel` packages.

* *Linux Ubuntu/Debian/Kali/Mint* and other deb-based distributions

### Core dependencies

For Debian-based systems (Debian, Raspbian, Ubuntu, Kali, Mint, and similar), the basic dependencies can be installed with `apt`:

```bash
sudo apt install build-essential git libwebsockets-dev pkg-config \
zlib1g-dev libnl-3-dev libnl-genl-3-dev libcap-dev libpcap-dev \
libnm-dev libdw-dev libsqlite3-dev libprotobuf-dev libprotobuf-c-dev \
protobuf-compiler protobuf-c-compiler libsensors-dev libusb-1.0-0-dev \
python3 python3-setuptools python3-protobuf python3-requests \
python3-numpy python3-serial python3-usb python3-dev python3-websockets \
librtlsdr0 libubertooth-dev libbtbb-dev libmosquitto-dev librtlsdr-dev
```

On some older distributions, `libprotobuf-c-dev` may be called
`libprotobuf-c0-dev`, and `libsensors-dev` may be called `libsensors4-dev`.

Don't be afraid to look for the required packages using the `apt` tool, if your
distribution has different names!  Package names sometimes shift over time.

On Fedora based systems:

```bash
sudo dnf install gcc gcc-c++ zlib-devel sqlite3 sqlite-devel openssl-devel \
libwebsockets libwebsockets-devel libpcap libpcap-devel libusb1 libusb1-devel \
rtl-sdr rtl-sdr-devel mosquitto mosquitto-devel lm_sensors lm_sensors-devel \
libnl3-devel NetworkManager-libnm-devel

```

Compiling from git / nightly code man require additional packages as well.

#### RTL-433 SDR

For rtl-433 SDR support, you will need the [rtl_433 tool](https://github.com/merbanan/rtl_433).  On more modern distributions this is available as a package:

```bash
sudo apt install rtl-433
```

If it is not available as a package on your distribution, you will need to compile it from source.

#### Libwebsockets

On some older distributions, `libwebsockets` may not be available as a modern version.  Kismet uses the libwebsockets async
API which was introduced a year ago, but some distributions still may not provide it.  You can try to compile libwebsockets
yourself, or you can disable libwebsockets in the Kismet build with `--disable-libwebsockets` in the configure stage below.

Libwebsockets is used by the remote capture code; compiling without it will not remove websockets from the Kismet server,
or prevent using websockets, but any remote capture code compiled without libwebsockets will only be able to use the legacy
TCP connection mode.  If you're not planning to use remote capture nodes, none of this matters to you, and you can
[read more about remote capture here](/docs/readme/remotecap/remotecap/).

When installing `libwebsocktets` from packages, if your distribution splits binary and development packages, make sure to
install both: the development package will be needed for compiling.

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

This will find all the specifics about your system and prepare Kismet for compiling.  If you have any missing dependencies
or incompatible library versions, they will show up here.

```bash
cd kismet
./configure
```

Pay attention to the summary at the end and look out for any warnings! The summary will show key features and raise warnings for missing
dependencies.  You may need to install additional libraries (or additional `-devel` development packages), especially if compiling the
latest git code.

If you're compiling for a remote capture platform *only*, check the [remote capture docs](/docs/readme/remotecap/remotecap/) for more information.

### Compile

If you are compiling a fresh checkout, the version file will be automatically generated.  If you use one git checkout and recompile
on demand, be sure to update the version file:

```bash
make version
```

Then, compile Kismet and the Kismet tools:

```bash
make
```

You can accelerate the process by adding `-j #`, depending on how many CPUs you have.  To automatically compile on all the available cores:

```bash
make -j$(nproc)
```

*WARNING*: Compiling modern C++ (such as the Kismet codebase) can require a *significant* amount of RAM.  You may need to limit the
number of parallel compile processes if you encounter memory errors during compiling.  Typically if you have less than 16GB of ram,
limit to `-j2` or `-j4`, and limit to `-j10` for 32GB of RAM.  Adding more parallel compiles than you have CPU cores is also rarely
beneficial.

#### Compile-time dependency errors

Sometimes, when updating the git repository, files have changed significantly enough that the Makefile system does not automatically recover fully.  If you encounter errors about missing header files (`foo.h not found` for example), try removing all `.d` files and running `make` again:

```bash
rm *.d
```

These files are used to identify which parts of the code need to be recompiled; rarely, when code is moved around, they get confused.

If this still does not fix the problem, you can try a clean git checkout (remove the `kismet` directory and re-run the `git clone` and `configure` steps.)

### Installing

Generally, you should install Kismet as suid-root; Kismet will automatically add a group and install the capture binaries accordingly.

When installed suid-root, Kismet will launch the binaries which control the channels and interfaces with the needed privileges, but will keep the packet decoding and web interface running without root privileges.

```bash
sudo make suidinstall
```

### Setting up the group

`make suidinstall` will automatically create a `kismet` group.  To run Kismet, your user needs to be part of this group.

```bash
sudo usermod -aG kismet your-user-here
```

This will add your current logged in user to the `kismet` group.

### Reload your groups

Groups are not updated automatically; you will need to reload the groups for your user.

Either log back out and log in, or in some cases, reboot.

Check that you are in the Kismet group with:

```bash
groups
```

If you are not in the `kismet` group, you should log out and log back in, or reboot - some session and desktop managers don't reload the groups on logout, either.
