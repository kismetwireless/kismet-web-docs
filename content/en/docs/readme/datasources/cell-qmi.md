---
title: "Cell: QMI and MBIM"
description: ""
lead: ""
date: 2026-11-27T18:00:00-05:00
lastmod: 2026-11-27T18:00:00-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "cell-qmi-868f1d59333a5c9ee3f8ead22a03c800"
weight: 403
toc: true
---

Added: after `2026-10-R1`

The cell QMI source (`cellqmi`) reads a cellular modem's serving and neighbor cells over its QMI control node, or over MBIM's own services when the modem's MBIM function carries no QMI.  Each cell becomes a device in the `Cellular` phy, the same devices the [cell AT](/docs/readme/datasources/cell-at/) and [cell DIAG](/docs/readme/datasources/cell-diag/) sources create; a cell seen by several sources is one device, and lists `qmi` in its seen-via sources.

Unlike the AT and DIAG sources, the QMI source can share the modem with ModemManager: it joins ModemManager's proxy as one more client instead of taking the port.

## Supported hardware

Any modem with a QMI or MBIM control node:

* `cdc-wdmN`: USB modems on the `qmi_wwan` or `cdc_mbim` drivers.
* `wwanNqmiM` and `wwanNmbimM`: modems on the kernel WWAN subsystem.
* `mhi_QMIN` and `mhi_MBIMN`: PCIe modems on Quectel's MHI driver.

On an MBIM node, the source uses QMI inside MBIM when the modem offers it (most Qualcomm modems), and otherwise MBIM's own services (Intel XMM, MediaTek T700).  MBIM's own services report less: the LTE serving cell and neighbors where the modem supports the base stations query, and only the serving cell's identity and signal on an Intel XMM7360.

## Adding the source

Name the control node:

```bash
$ kismet -c cdc-wdm0:type=cellqmi
$ kismet -c cellqmi:device=/dev/wwan0qmi0
```

A `device=` path may be a link, such as a `/dev/serial/by-id` or udev name, but it must end at a QMI or MBIM control node in `/dev`; anything else is refused, with or without `framing=`.

The control node is readable only by root, so the capture tool runs as root: `make suidinstall` and the packages install `kismet_cap_cell_qmi` setuid-root, for members of the `kismet` group.  It reads which programs have the node open, then drops its other privileges before talking to the modem.

## Sharing the modem

With `open=auto` (the default) the source picks how to reach the node:

1. **Proxy:** libqmi's `qmi-proxy` or libmbim's `mbim-proxy` (started by ModemManager) is running and nothing else holds the node.  The source joins the proxy as one more client.
2. **Refuse:** another program holds the node directly (uqmi, a vendor connection manager).  The source names that program and does not open the node, because a second reader would take that program's replies.
3. **Direct:** no proxy and no other program.  The source opens the node itself.

The source never starts a proxy.  It uses one only if the process listening on the proxy's name runs as root: while ModemManager isn't running, any local user could listen on that name and feed the source fake cells.  Such a listener is refused, with its uid and pid; stop it, or set `open=direct`.

The proxies only accept root clients, which is another reason the tool is installed setuid-root.

The source never resets the modem's QMI clients, and releases its client ID when it closes.  Neither the modem nor the proxies reclaim the IDs of a client which died, and each service only has a few, so a direct open also records its client ID in `~/.kismet/cellqmi-<node>.cid`; if the tool is killed, the next direct open of the same node releases that ID and says so in the Kismet messages.

## Cell devices

Each poll reads the modem's system info, cell location and signal info:

* LTE serving cell: PLMN, TAC, cell ID, PCI and EARFCN, with RSRP, RSRQ, RSSI and SNR.
* LTE neighbors: PCI and EARFCN, with RSRP, RSRQ and RSSI.
* NR serving cell: PLMN, TAC, cell ID, PCI and NR-ARFCN, with RSRP, RSRQ and SNR.

EARFCNs above 65535 (band 65 and others) wrap in the modem's 16-bit fields; the source only reports an EARFCN that a 32-bit field confirms, and leaves out a neighbor it can't identify.

## QMI source parameters

| option | default | |
|---|---|---|
| `device=<path>` | | the control node, when the source is named `cellqmi` |
| `interval=<ms>` | 2000 | poll period, at least 500 |
| `open=auto\|proxy\|direct` | auto | how the node is reached; see [sharing the modem](#sharing-the-modem) |
| `framing=qmux\|mbim` | from the node's driver | when the driver can't be read |
| `backend=auto\|qmi\|mbim` | auto | on an MBIM node: QMI inside MBIM when offered, otherwise MBIM's own services; `qmi` or `mbim` insists on one |
