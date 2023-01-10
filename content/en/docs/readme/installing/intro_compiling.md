---
title: "Introduction"
excerpt: "Kismet has many many configuration knobs and options, but check here for the quickest way to get Kismet working with the latest release (or git version) and what you need to compile and do the initial configuration."
weight: 25
toc: true
---

## Getting current versions 

Often distributions lag behind the latest versions of tools - sometimes significantly so.  Several distributions are still shipping the 2016 Kismet code! 

When installing from packages, make sure that your distribution is installing a *current* version of Kismet - and if it isn't, continue on for how to install from the official Kismet package repositories or build it from git!

## Official Kismet respositories

Kismet provides official packages - release and nightly - for many common distributions including Ubuntu, Kali, and Raspbian.

Learn more about the Kismet packages [here](/packages/)!

## Compiling or packages?

If you are on a distribution which does not provide packages, and is not part of the official Kismet packages, or are working on developing contributions to Kismet, you can always compile from source!

If you're using a very resource constrained system, like a Raspberry Pi, you may want to consider either the packages, or making a cross compiling environment - modern C++ can be very resource intensive to compile, and a Raspberry Pi 3 or Raspberry Pi Zero is unlikely to be able to successfully compile natively.  

You can modify the Docker-based build environments used by Kismet for package building as a starting point, [hosted on Github](https://github.com/kismetwireless/kismet-packages)

