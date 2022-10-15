---
title: "Windows"
description: ""
lead: ""
date: 2022-08-12T11:27:15-04:00
lastmod: 2022-08-12T11:27:15-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "windows-bb74ddc0002303f8a452e4258156a155"
weight: 100
---

## Virtual Machines

It may be possible to run Kismet in Linux inside a virtual machine, however this typically depends on the VM being used and the hardware being used.

If it works, you will need a USB WiFi card for capture, and a VM solution which allows USB passthrough (such as VMWare).  Hyper-V does not support USB passthrough, and Virtualbox may or may not work.

It is not possible to pass an internal PCI Wi-Fi card to a VM under Windows.

Not all USB Wi-Fi cards work on Windows with USB passthrough.

## Kismet on WSL

Kismet has deep dependencies on the Posix (ie, Unix-based) libraries and environment, and as such, does not run *directly* on Windows platforms.

It is possible to run Kismet inside the WSL (Windows Subsystem for Linux) environment, either in WSL1 or WSL2.

## Limits 

The WSL environment (and the WSL2 HyperV environment) do not have direct access to USB, PCI, or other hardware interfaces.  It is not possible to capture packets directly in Kismet in WSL from a local device.

However, it *IS* possible to capture packets using the Kismet remote capture system.

For more info on remote capture, see the Kismet remote cap docs (LINK NEEDED)

## Compiling

Since WSL is Linux, follow the compile directions for the Linux distribution you haveinstalled (typically Ubuntu or Kali) under the [Linux documentation](/docs/readme/compiling/linux)
