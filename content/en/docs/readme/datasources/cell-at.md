---
title: "Cell: AT modem"
description: ""
lead: ""
date: 2026-10-26T12:00:00-04:00
lastmod: 2026-10-26T12:00:00-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "cell-at-71b4566f558dc301b90c29e39956a886"
weight: 400
toc: true
---

Added: `2026-10`

Kismet can track cell towers with a USB or M.2 cellular modem.  The cell AT source (`cellat`) talks to the modem over its AT command port, polls the vendor engineering commands for the serving and neighbor cells, and reports each cell as a device in the `Cellular` phy.

A SIM card is not required; modems report the cells they can see without registering to a network.

## AT and DIAG

Kismet has two cell modem sources, and they can be used separately or together on the same modem.

### The AT source

The AT source (`cellat`) uses the modem's AT command port, the same port used to configure the modem or dial a data connection.  It sends the vendor's engineering commands on a schedule and parses the replies:

* The serving cell, with its full identity (MCC, MNC, TAC, cell ID, PCI, channel, and band) and signal (RSRP, RSRQ, SINR), every 2 seconds.
* The neighbor cells the modem reports, with their PCI, channel, and signal, every 5 seconds (Quectel modems).
* A full band scan, on the modems which have one (`AT+QSCAN` on Quectel 5G modems, `AT#CSURVC` on Telit), in the walking and stationary [scan strategies](#scan-strategies).

The AT source works with modems from several vendors, sends a few small commands a second, and changes nothing on the modem unless [band locking](#bandrat-lock) or the [modem GNSS](/docs/readme/gps/gps_cellmodem/) is turned on.  It only sees what the modem's engineering commands report, at the rate they are polled.

The AT source can also lock the modem to a band or radio technology, and use the modem's GNSS receiver as a Kismet GPS.

### The DIAG source

The [DIAG source](/docs/readme/datasources/cell-diag/) (`celldiag`) uses the Qualcomm diagnostic (DIAG) port, which only Qualcomm-based modems have.  It asks the modem to stream its internal log records and decodes them inside the capture tool:

* Every serving and neighbor cell measurement the modem's LTE and NR physical layer makes, as it makes them, instead of a poll every few seconds.
* The LTE RRC messages the modem receives, including the SIB1 broadcast by each cell, which gives the identity (MCC, MNC, TAC, cell ID) of cells the AT commands only report as a PCI and channel.
* The serving cell bandwidth and antenna count, and the modem's GNSS position reports.
* The security signalling, which raises the [cell security alerts](/docs/readme/datasources/cell-diag/#alerts) when a cell behaves like a cell-site simulator ("IMSI catcher").

The DIAG source sets the modem's diagnostic log mask while it runs (and clears it when it closes), some modems need an unlock code first, and the stream is much larger than the AT polling: the raw DIAG stream is stored in the kismetdb by default.  Only one program can use the DIAG port at a time.

### Using both

The AT and DIAG sources open different ports on the modem, so both can run at once; each claims only its own port.  Kismet merges their observations of the same cell into one device.

A typical setup for a Qualcomm modem is both sources: the AT source for the polled serving cell identity, the band scans, the band lock, and the GNSS, and the DIAG source for the dense measurements, the SIB1 identities, and the security alerts.  On a modem without a DIAG port, or when the size of the log matters, use the AT source alone.

```
kismet -c cellat-<imei>:gps=modem -c celldiag-<imei>
```

## Supported hardware

The AT source supports Quectel and Telit modems through their engineering commands:

* **Quectel RM500Q series** (5G NR and LTE, Qualcomm SDX55): RM500Q-AE, RM500Q-GL, RM502Q-AE, RM505Q-AE, RM510Q-GL, RG500Q-EA, and RG502Q-EA.  Serving cell (LTE, NR5G-SA, and NR5G-NSA), neighbor cells, and full band scans (`AT+QSCAN`).
* **Quectel RM520N-GL series** (5G NR and LTE, Qualcomm SDX62): RM520N-GL, RM520N-CN, RM530N-GL, RG520N-NA, RG520N-EB, RG520N-EU, RG520N-LA, RG520N-GT, and RG525F-NA.  Serving cell, neighbor cells, and full band scans.  The RM520N-GL is the reference modem for the DIAG source.
* **Quectel EG25-G series** (LTE Cat 4): EG25-G, EG25-GL, EC25-AF, EC25-AU, EC25-E, EG91, EG95, EM05-G, and EM05-CE.  Serving cell (LTE only) and neighbor cells.  These modems have no full band scan.
* **Telit LM960** (LTE Cat 18): LM960 and LM960A18.  Serving cell from `AT#RFSTS` and `AT#SERVINFO`, and the `AT#CSURVC` cell survey as the full scan.

The source also recognizes Sierra Wireless (EM9190, EM9291), SIMCom (SIM8202G-M2), and Orbic (RC400L) modems.

Modems are identified by their manufacturer (`AT+CGMI`), and the commands each one supports are probed when the source opens, instead of assumed from the model.

### Tested configurations

| Modem | Firmware | RAT |
|-------|----------|-----|
| Quectel RM500Q-AE | RM500QAEAAR11A21M4G | NR5G-SA, LTE |
| Quectel EG25-G | EG25GGBR07A08M2G | LTE |
| Telit LM960A18 | 32.01.110 (Generic) | LTE |

### Model notes

* **EG25-G / EC2x:** `AT+COPS=?` (operator scan) has been seen to hang the EG25-G until it is power cycled; Kismet never sends it.
* **RM520N-GL:** band configuration uses `AT+QNWPREFCFG`; `AT+QCFG="band"` returns an error on this firmware.
* **Telit LM960:** `AT#CSURVC` is used for the full scan; `AT#CSURV` is broken on the Generic and TMUS firmware.

## Adding the source

Cell sources are named by the modem's IMEI, which stays the same when the modem is re-plugged or its serial ports are renumbered.  To find the modems attached to the system:

```bash
$ kismet_cap_cell_at --list
```

This probes the serial ports which look like cell modems and lists each one by IMEI, model, and firmware:

```
cellat supported data sources:
    cellat-<imei> (Quectel EG25 IMEI:<imei>)
```

The modems are also listed in the Kismet web UI datasources panel.  A modem which does not report an IMEI can't be used.

Add the source on the command line:

```bash
$ kismet -c cellat-<imei>
```

or in `kismet_site.conf`:

```
source=cellat-<imei>:strategy=walking
```

The source type is `cellat`.  Multiple modems can be used at once; each runs in its own capture process, and cells seen by more than one modem are merged.

### Finding the AT port

The source scans the serial ports for the modem with the matching IMEI.  On Linux, only ports bound to a cellular serial driver (`option`, `qcserial`, `sierra`, or `cdc_acm` on a cellular vendor ID) are opened, and the DIAG and NMEA ports of known modems are skipped; a USB-UART bridge, GPS, or other serial device is never probed.  On a Quectel modem the AT port is usually the third interface (`ttyUSB2` when it is the only modem).

To use a specific port, set `atport=`; the IMEI is still checked, and a mismatch fails the open.  The `CELLAT_EXTRA_PORTS` and `CELLAT_SCAN_PORTS` environment variables add ports to the scan, or replace the scanned ports, as a space-separated list of paths or globs.  A port named in either is probed even if it doesn't look like a modem, which is needed for a modem behind a USB-UART bridge, or one reached over the network through a pty:

```bash
$ socat PTY,raw,echo=0,link=/tmp/modem-at TCP:192.0.2.1:5555 &
$ CELLAT_EXTRA_PORTS=/tmp/modem-at kismet -c cellat-<imei>
```

### macOS

macOS has no driver for the serial interfaces of these modems; Kismet reaches supported Quectel modems directly over libusb.  See [cell modems over libusb](/docs/readme/datasources/cell-usb/).

### Linux permissions

The capture tool needs read and write access to the modem's serial ports.  Run Kismet as root, or add the user to the group which owns the ports (usually `dialout`):

```bash
$ sudo usermod -aG dialout $USER
```

Log out and back in for the group change to take effect.  A modem reached over [libusb](/docs/readme/datasources/cell-usb/) needs access to the USB device instead.

## Scan strategies

The scan strategy sets how often each command runs:

| Strategy | Serving cell | Neighbor cells | Full band scan |
|----------|--------------|----------------|----------------|
| `driving` (default) | every 2s | every 5s | never |
| `walking` | every 2s | every 5s | every 300s |
| `stationary` | every 2s | every 5s | every 60s |
| `serving_only` | every 2s | never | never |

A full band scan is the only way to find cells on bands the modem isn't camped on, but it blocks the AT port, and so the serving and neighbor polls, for up to two minutes (`AT+QSCAN`) or three (`AT#CSURVC`).  The full scan interval is counted from the end of the previous scan.  Driving never runs a full scan, since at road speed a two minute gap covers kilometers.

A strategy which asks for a full scan on a modem without one still runs its serving and neighbor polls, and warns that the full scan won't run.  `wardrive` is accepted as the old name for `driving`.

The strategy can be changed while the source runs, from the source panel in the web UI or by setting `strategy=<name>` as the source channel through the [datasource API](/docs/api/datasources/).

## Band/RAT lock

A modem normally picks its own band and radio technology (RAT).  With `bandlock=true`, the source offers lock *channels* which hold the modem to one RAT, one band, or a set of bands:

| Channel | Locks to |
|---------|----------|
| `AUTO` | the modem settings as found when the source opened (the default) |
| `LTE` | LTE only, on every LTE band the modem had enabled |
| `NR5G` | NR standalone only, on every NR band the modem had enabled |
| `LTE-B<n>` | LTE band *n* only, such as `LTE-B66` |
| `NR-n<n>` | NR band *n* only, such as `NR-n41` |
| `LTE-B<n>+<m>...` | exactly that set of LTE bands, such as `LTE-B2+4+12+66` |

Quectel modems support all of these (`AT+QNWPREFCFG`; the EG25-G and EC2x use `AT+QCFG` and support `AUTO`, `LTE`, and the LTE bands).  Sierra, Telit, and SIMCom modems support only the `AUTO`, `LTE`, and `NR5G` RAT locks, where the modem lists them.  Only bands the modem had enabled can be locked.

The lock is set like a Wi-Fi channel: lock the source to a channel in the web UI or the datasource API, set `channel=LTE-B66` in the source definition to lock at open, or hop between locks to step through bands.  Each lock re-registers the modem, which costs a few seconds without service, so the web UI won't hop faster than one lock every 5 seconds.  The source is never hopped automatically, even when global channel hopping is on.

**Band locking is off by default because it changes the modem's saved settings.**  A lock is written to the modem's non-volatile configuration and survives a reboot of the modem:

* Nothing is written when the source opens.
* Before the first lock, the settings as found are saved to `~/.kismet/cellat-lock-<imei>.state` in the home directory of the user running the capture tool.  If this file can't be written, locking is refused.
* Setting `AUTO`, or closing the source, restores the saved settings and removes the file.
* If the capture tool was killed with a lock in place, the next open of that modem restores the settings from the file, even with `bandlock=false`.

## Modem GNSS

Quectel modems with a GNSS receiver can be used as a Kismet GPS with `gps=<name>`; see [GPS - Cell modem](/docs/readme/gps/gps_cellmodem/).

## Cell devices

Cells are tracked as devices in the `Cellular` phy:

* A cell with a full identity (MCC, MNC, TAC, and cell ID) is a `Cell` device, keyed on `<MCC><MNC>_<TAC>_<cell ID>`.
* A cell seen only as a PCI and channel, such as most neighbor reports, is a `Cell (Partial)` device, keyed on the RAT, PCI, and downlink frequency.  It becomes a full `Cell` once an observation with its full identity arrives.

The key uses the downlink frequency instead of the raw channel number, so a cell reported as different bands by different modems (LTE band 4 and band 66, for instance) is still one device.

The web UI shows the cell identity, the band and channel, the signal (RSRP, RSRQ, SINR), the range of RSRP seen, and the number of observations.  Cells are geotagged with the GPS location, and are included in the [WiGLE CSV](/docs/readme/logging/wiglecsv/) log.

## Logging

The source sends every AT command and its full response, a session record for each capture, and the decoded observations into the [kismetdb](/docs/readme/logging/kismetdb/) log; nothing is written to separate files.  See [kismetdb cell logs](/docs/readme/kismetdb/kismetdb_cell/) for the record types and the tools to extract them.

## AT source parameters

### Naming and description options

All data sources accept the [common naming and description](/docs/readme/datasources/datasources/#naming-and-describing-datasources) options.

Options which the AT source doesn't know are reported as a warning, so a misspelled option doesn't silently do nothing.

### Port options

{{<configopt atport "/path/to/tty" "usb:bus-addr:if">}}
Open this AT port instead of scanning for the modem.  The modem on the port must still have the IMEI in the source name.
{{</configopt>}}

{{<configopt usb auto force off>}}
How modems with no host serial driver are reached over [libusb](/docs/readme/datasources/cell-usb/).

* `auto` (default): use the interfaces of supported modems which no host driver has claimed.
* `force`: also take the interfaces from the host driver (such as `option` or `qcserial` on Linux) while the source runs; the driver gets them back when the source closes.
* `off`: don't use libusb.
{{</configopt>}}

### Scan options

{{<configopt strategy driving walking stationary serving_only>}}
The [scan strategy](#scan-strategies).  An unknown strategy fails the open.  This can be changed while the source runs.
{{</configopt>}}

### Band lock options

{{<configopt bandlock true false>}}
Offer the [band/RAT lock](#bandrat-lock) channels.  A lock changes the modem's saved settings until it is restored.  By default band locking is off.
{{</configopt>}}

{{<configopt channel channel>}}
Lock the modem to this channel when the source opens, such as `channel=LTE-B66`.  Requires `bandlock=true` and a modem which supports locking.
{{</configopt>}}

### GPS options

{{<configopt gps name true false>}}
Use the modem's GNSS as the Kismet GPS `name`; `true` names the GPS after the source.  Quectel modems only.  See [GPS - Cell modem](/docs/readme/gps/gps_cellmodem/).
{{</configopt>}}

{{<configopt gpsport "/path/to/tty" "usb:bus-addr:if">}}
The modem's NMEA port, when it isn't found automatically.
{{</configopt>}}

### Vendor options

{{<configopt sierracnd true false>}}
Sierra Wireless modems only: unlock the advanced AT commands (`AT!ENTERCND` with the default password) when the source opens.  Without it, a modem which keeps `AT!GSTATUS?` and `AT!LTEINFO?` locked reports less.
{{</configopt>}}

### Other options

{{<configopt enabled true false>}}
With `enabled=false`, the source is defined but idle: the modem port isn't opened.
{{</configopt>}}

{{<configopt clock_anchor_sec seconds>}}
How often the modem clock is read and paired with the host clock in the log, in seconds.  The default is 30; `0` reads it only at the start and end of the capture.  This can be changed while the source runs.
{{</configopt>}}

{{<configopt debug true false>}}
Extra per-poll messages, and extra detail in the session log.  Debug mode also reads the SIM IMSI and ICCID and logs them at debug level, so it is off by default.  Setting `KISMET_CELLAT_DEBUG=1` in the environment turns it on for every source.
{{</configopt>}}
