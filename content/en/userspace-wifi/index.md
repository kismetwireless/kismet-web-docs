---
title: "Userspace USB Wi-Fi"
description: "Linux USB Wi-Fi drivers running in userspace, for monitor mode capture, injection and SDR"
date: 2026-11-18T08:07:03-05:00
lastmod: 2026-11-18T08:07:03-05:00
images: []
---

## Userspace USB Wi-Fi drivers

[userspace-wifi](https://github.com/kismetwireless/userspace-wifi) runs unmodified Linux USB Wi-Fi drivers in userspace, on top of libusb.  It gives monitor mode capture and packet injection on systems with no kernel driver for an adapter (such as macOS), or where the kernel driver can't do monitor mode.

These are the same drivers Kismet uses for its [USB userspace Wi-Fi datasource](/docs/readme/datasources/wifi-usb-userspace/).  If all you want is monitor mode capture in Kismet, you don't need this project: Kismet already includes them.  userspace-wifi is the standalone version, with its own tools:

* `uwifi`, to list adapters, capture to pcap, and inject frames;
* on Linux, `uwifi hwsim`, which turns an adapter into an ordinary Linux Wi-Fi interface;
* `usbsdr`, a SoapySDR module and a GNU Radio block, which use some MediaTek adapters as SDR receivers.

Why run a Wi-Fi driver in userspace?

* Some drivers misbehave.  In userspace, a misbehaving driver can't take down the system, and restarting it is simply restarting a program.
* New hardware support lands in the newest kernels first.  A driver ported to userspace runs on the kernel you already have.

All of the driver code is derived from the Linux kernel.

## Supported adapters

| Driver | Devices |
|---|---|
| mt7921u | MediaTek MT7921AU and the other mt7921u devices |
| mt7925u | MediaTek MT7925, and the Netgear A8500 and A9000 |
| mt76x2u | MediaTek MT7612U / MT7632U, such as the ALFA AWUS036ACM |
| rtw88 | Realtek RTL8812AU/8811AU, RTL8821AU, RTL8814AU, RTL8812BU/8822BU, RTL8812CU/8822CU, RTL8811CU/8821CU, RTL8723DU |
| mm8108 | Morse Micro MM8108 802.11ah (HaLow) |

The MediaTek drivers come from the Linux kernel `mt76` driver.  The Realtek drivers come from the kernel `rtw88` driver, with fixes from [lwfinger/rtw88](https://github.com/lwfinger/rtw88).

## Building

userspace-wifi needs libusb-1.0 and pkg-config.  If libzstd and liblzma are installed, it also loads compressed firmware files.

```
make
sudo make install
```

## Capture and injection

```
uwifi list
uwifi info
uwifi capture -b 2,5 -W 20,40,80 -t 250 -w capture.pcap
uwifi capture -c 1,6,11,36VHT80,6g:37HE80 -T 60
uwifi inject -c 6 -n 100 -i 20
uwifi inject -c 36 -r frames.pcap
```

Channels use Kismet's notation (`6`, `6HT40+`, `36VHT80`); 6GHz channels take a `6g:` prefix.  Injected frames take the same path as on a Linux monitor interface: a radiotap header and the 802.11 frame, sent through mac80211's monitor transmit code into the driver.  Whether an adapter uses the injected rate, and whether it reports ACKs, depends on the chip, as it does in the kernel; the [README](https://github.com/kismetwireless/userspace-wifi) lists what each driver does.

On Linux, run `uwifi` as root, or give your user access to the USB device.  Only the adapter's Wi-Fi interface is detached from the kernel driver, and it goes back to the kernel when `uwifi` exits.

## A Linux Wi-Fi interface

On Linux, `uwifi hwsim` makes the adapter an ordinary kernel Wi-Fi interface, using the `mac80211_hwsim` simulation driver.  `iw`, wpa_supplicant and hostapd work on it unchanged:

```
sudo modprobe mac80211_hwsim radios=0
sudo uwifi hwsim -d 0 -C US
```

Scanning works with every driver.  Connecting to a network (WPA2, or WPA3-SAE on HaLow) works on the rtw88, mt76x2u and mm8108 adapters.  The MT7921AU and MT7925 firmware don't acknowledge frames in this mode, so they can scan but not connect.

## 802.11ah (HaLow)

The Morse Micro MM8108 driver captures 802.11ah, the sub-GHz Wi-Fi standard also called HaLow.  Linux has no sub-GHz Wi-Fi band to give the frames, so, like Morse Micro's own Linux driver, userspace-wifi maps each HaLow channel onto a 5GHz channel 20 times as wide.  `uwifi info` prints the channel map for the adapter's region.

## SDR

Built with `make SDR=1`, userspace-wifi adds raw I/Q capture from two MediaTek chips, which makes an inexpensive Wi-Fi adapter into a 2.4, 5 and 6GHz SDR receiver:

| Chip | Tunes | Widths |
|---|---|---|
| MT7921AU | 2.4 and 5GHz | 20, 40 and 80MHz, continuous; both receive chains at 40MHz |
| MT7925 | 2.4, 5 and 6GHz | 20, 40, 80 and 160MHz, in snapshots |

The samples are available through:
* the `usbsdr` command line tool;
* a SoapySDR module, so GNU Radio, gqrx, SDR++ and other SoapySDR programs can use the adapter;
* a GNU Radio block;
* a C library, `libuwifisdr`, for programs of your own.

Both chips need a USB 3 port.  The MT7921AU I/Q capture is the work of the [Mtk79ICAP](https://github.com/MtkWifiRev/Mtk79ICAP) project.  [SDR.md](https://github.com/kismetwireless/userspace-wifi/blob/main/SDR.md) in the repository has the details and credits.

## Adding a driver

Copy the driver's kernel sources into `drivers/`, add them to the Makefile, and build.  Missing kernel functions show up as compile or link errors; add those to the kernel compatibility layer rather than changing the driver.  If you need a driver ported and can't do it yourself, ask: it may be quick to add.
