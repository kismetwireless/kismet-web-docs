---
title: "Cell: modems over libusb"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "cell-usb-3a101473c71500b08656fd8cae088e22"
weight: 402
toc: true
---

Added: `2026-10`

Quectel cell modems present their AT, DIAG, and NMEA ports as vendor-specific USB serial interfaces.  Linux binds them to the `option` driver and creates `/dev/ttyUSB*` ports, but macOS has no host driver for them: no `/dev/cu.*` ports appear when the modem is plugged in.

The [cell AT](/docs/readme/datasources/cell-at/) and [cell DIAG](/docs/readme/datasources/cell-diag/) sources instead talk to the modem's interfaces directly over libusb, so these modems work on macOS with no driver or kernel extension.

The libusb method works on Linux as well.  It is used automatically for a supported modem which no driver has claimed (for instance when the `option` driver isn't loaded, or doesn't know the modem's USB ID), and `usb=force` uses it even when the `option` driver has bound the modem.  This can be useful on a system where the serial driver is missing or misbehaves, or to avoid depending on `/dev/ttyUSB*` numbering.

## Supported modems

| Modem | USB ID |
|-------|--------|
| Quectel EC21 | `2c7c:0121` |
| Quectel EC25 / EG25-G | `2c7c:0125` |
| Quectel EG91 | `2c7c:0191` |
| Quectel EG95 | `2c7c:0195` |
| Quectel BG96 | `2c7c:0296` |
| Quectel EP06 / EG06 / EM06 | `2c7c:0306` |
| Quectel EG12 / EM12 / EG18 | `2c7c:0512` |
| Quectel RM500Q / RM502Q | `2c7c:0800` |
| Quectel RM520N | `2c7c:0801` |
| Telit LM960A18 (after 2026-10-R1) | `1bc7:1040` |
| Fibocom FM350-GL (after 2026-10-R1) | `0e8d:7127` |

The Quectel interfaces are given their roles from Quectel's usual layout.  On the EG25-G, for instance:

| Interface | Role |
|-----------|------|
| 0 | DIAG |
| 1 | NMEA (GNSS) |
| 2 | AT |
| 3 | modem (also answers AT) |
| 4 | QMI / RmNet; not a serial port, and not used |

The other two have their own measured layouts:

* **Telit LM960A18:** interface 0 is DIAG, 3 NMEA, 4 AT, and 5 the modem port (which also answers AT).  On a USB 2.0 link with hardware link power management (LPM) on, this modem can drop or hold a command sent after an idle gap, through libusb and the Linux serial driver alike; the cell AT source asks its identity commands again when the first try gets no reply.
* **Fibocom FM350-GL:** only interface 6, its AT port, is used.  Every serial interface of this modem has the same interface class, so the log port (interface 2) and the factory META port (interface 4) are never claimed, and interface 3, which answers AT only beside the GNSS service, is left to the host driver.  This modem has no DIAG port.

### Other modems

After 2026-10-R1, other models from modem vendors (Quectel, Qualcomm, Novatel / Inseego, Fibocom, Sierra Wireless, Telit, SIMCom, Dell, and Foxconn) are used too, with each interface's role taken from its USB interface class, subclass, and protocol where those have only one meaning across the modems measured so far:

| Class / subclass / protocol | Role |
|-----------------------------|------|
| `ff/ff/30` | DIAG |
| `ff/ff/40` | AT |
| `ff/00/40` | NMEA |

Interfaces of class `ff/ff/ff` or `ff/00/00` are never used on an unlisted model, since they are DIAG, QMI, AT, a PPP port, or a vendor tool port depending on the modem.  A device from one of these vendors with none of the triples above, such as a Dell keyboard, isn't listed or opened, and MediaTek devices other than the FM350-GL aren't used at all.

This widens what `usb=auto` reaches: an unlisted device from these vendors with one of these interfaces unclaimed by a host driver is now listed and probed, for instance a Qualcomm (`05c6`) device in DIAG mode, which can include a phone with its diagnostic port enabled.  Use `usb=off` to keep the cell sources to host serial ports.

Which of these modems the cell sources can survey is listed under the [cell AT supported hardware](/docs/readme/datasources/cell-at/#supported-hardware).

## USB port names

A modem interface reached over libusb is named `usb:<bus>-<addr>:<interface>` anywhere a serial port path would be used.  On macOS the bus is numbered from 0, so a name may look like `usb:0-3:2`; on Linux buses are numbered from 1, matching `lsusb`, such as `usb:1-4:2`.

The port scan of both cell sources includes these interfaces, `--list` shows the modems found this way, and the `atport=`, `diagport=`, and `gpsport=` options accept them:

```bash
$ kismet -c cellat-<imei>
$ kismet -c 'celldiag-<imei>:atport=usb:0-3:2,diagport=usb:0-3:0'
```

The bus address changes when the modem re-enumerates (when it is re-plugged or reboots), so a `usb:` name is only good for one session.  The IMEI in the source name stays the same, so normally there is no need to name the ports.

## The usb= option

Both cell sources take a `usb=` option:

* `usb=auto` (default): use the interfaces of supported modems which no host driver has claimed.  On macOS this is every supported modem; on Linux it is a modem the `option` driver hasn't bound.
* `usb=force`: also take interfaces away from their host driver (such as `option` or `qcserial` on Linux) while the source runs.  The driver gets them back when the source closes.
* `usb=off`: don't use libusb.

## Behavior

* Each source claims only the interface it uses, so a cell AT source and a cell DIAG source can share one modem.  An interface claimed by another process is treated as busy, the same as a serial port another process holds.
* When the modem is unplugged, the source reports that the device was removed.
* The Qualcomm DIAG interface on the EG25-G accepts only one HDLC frame per USB transfer, and drops the rest of the transfer; the libusb support splits DIAG writes into one frame per transfer.

## kismet_usbserial

`kismet_usbserial` serves the serial interfaces of a supported modem as pseudo-terminals, on macOS or Linux, so other serial tools (a terminal program, `minicom`, a GNSS tool reading NMEA) can open the modem like any tty.  It takes interfaces away from a host driver while it runs.

```
$ kismet_usbserial --list
2c7c:0125 bus 0 addr 3  Quectel EC25 / EG25-G

$ kismet_usbserial --link-dir /tmp
Quectel EC25 / EG25-G
  diag   interface 0  /dev/ttys004  /tmp/modem-diag
  nmea   interface 1  /dev/ttys005  /tmp/modem-nmea
  at     interface 2  /dev/ttys006  /tmp/modem-at
  modem  interface 3  /dev/ttys007  /tmp/modem-modem
```

| Option | |
|--------|---|
| `--list` | list the supported modems which are attached |
| `--device VID:PID` | the modem to open, by USB ID in hex (default: the first supported modem) |
| `--usb BUS:ADDR` | the modem to open, by USB bus and address |
| `--link-dir DIR` | make symlinks `DIR/PREFIX-ROLE` to each port's pty |
| `--link-prefix PREFIX` | the symlink name prefix (default: `modem`) |
| `--verbose` | report traffic counts |

`kismet_usbserial` claims every serial interface of the modem, so the Kismet cell sources can't reach it over libusb while it runs; stop it before using the modem in Kismet.

## Compiling

libusb support for the cell modems, and `kismet_usbserial`, are built by default when libusb-1.0 is found.  They can be disabled by passing `--disable-usbserial` to `./configure`.  Without it, the cell sources still work with modems which have host serial ports.

## Permissions

On Linux, using a modem over libusb needs write access to its USB device (under `/dev/bus/usb/`); run the capture as root, or grant access to the device with a udev rule.  The Kismet packages install a rule which gives the `kismet` group access to Quectel modems:

```
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2c7c", MODE="0660", GROUP="kismet"
```

After 2026-10-R1, the packaged rules also cover Telit (`1bc7`), Sierra Wireless (`1199`), SIMCom (`1e0e`), Fibocom (`2cb7`), and Novatel / Inseego (`1410`) modems, and the FM350-GL by its full USB ID.  Qualcomm, Dell, Foxconn, and MediaTek also make devices other than modems, such as phones, keyboards, and Bluetooth and Wi-Fi adapters, so the packaged rules leave those vendors out; add a rule naming your modem's full USB ID to use one of them without root:

```
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="05c6", ATTR{idProduct}=="<pid>", MODE="0660", GROUP="kismet"
```

Taking an interface from its driver with `usb=force` needs no additional permission beyond access to the USB device.
