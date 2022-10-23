---
title: "Exploring"
description: ""
lead: ""
date: 2022-10-17T09:24:46-04:00
lastmod: 2022-10-17T09:24:46-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "exploring-0e13d560009b0080b7a35e11c18593b5"
weight: 30
toc: true
---

The easiest way to explore the REST system, aside from the docs, is to query the JSON endpoints directly.  Remember that as of `2019-04-git` you will need to have a valid login to explore the server setup.  

You can use `curl` or `python` to quickly grab output and format the JSON to be easily human readable:

```
$ curl http://user:password@localhost:2501/datasource/all_sources.json | python -mjson.tool

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 36274  100 36274    0     0   761k      0 --:--:-- --:--:-- --:--:--  770k
[
    {
        "kismet.datasource.capture_interface": "wlp3s0mon",
        "kismet.datasource.channel": "",
        "kismet.datasource.channels": [
            "1",
            "1HT40+",
            "2",
            "3",
            "4",
            "5",
            "6",
            "6HT40-",
            "6HT40+",
            "7",
            "8",
            "9",
            "10",
            "11",
            "11HT40-"
        ],
        "kismet.datasource.definition": "wlp3s0",
        "kismet.datasource.dlt": 127,
        "kismet.datasource.error": 0,
        "kismet.datasource.error_reason": "",
        "kismet.datasource.hop_channels": [
....
```

Similarly, POST data can also be sent via `curl`; for example to test creating an alert via the dynamic alerts endpoint:

```bash
$ curl -d 'json={"name": "JSONALERT", "description": "Dynamic alert added at runtime", "throttle": "10/min", "burst": "1/sec"}' http://username:password@localhost:2501/alerts/definitions/define_alert.cmd
```

which passes the parameters in the `json=` variable, and the login and password in the URI (username:password in this example).

## Exploring websockets

One of the easiest tools to interact with websockets for exploration is [websocat](https://github.com/vi/websocat) which gives a netcat-style interface to websockets.

```bash
$ websocat 'ws://host:2501/eventbus/events.ws?user=username&password=password'
```

Entering the subscribe command:

```
{"SUBSCRIBE": "TIMESTAMP"}
``` 

will enroll this websocket with the eventbus, and stsart returning events like:

```
{"TIMESTAMP": {"kismet.system.timestamp.usec": 671986,"kismet.system.timestamp.sec": 1603120458}}
{"TIMESTAMP": {"kismet.system.timestamp.usec": 672945,"kismet.system.timestamp.sec": 1603120459}}
```

Beyond `websocat`, websockets can be explored in a Javascript environment (like `jsc`, `node`, or a browser console), with Python, or with almost any other language with modern web client libraries.


## What do all the fields mean?

More information about each field can be found in the `/system/tracked_fields.html` URI, simply by visiting `http://username:password@localhost:2501/system/tracked_fields.html` in your browser.  

This endpoint shows a table of every registered field, the type of data the fields holds, and the description of the field.

### Additional pretty-printed output

For even more information, almost every REST endpoint can be requested using the `{foo}.prettyjson` format; this JSON output is styled for ease of readability and includes additional metadata to help understand the format; for example:

```
$ curl http://username:password@localhost:2501/system/status.prettyjson
 {
 "description.kismet.device.packets_rrd": "string, RRD of total packets seen",
 "kismet.device.packets_rrd":
  {
  "description.kismet.common.rrd.last_time": "uint64_t, last time udpated",
  "kismet.common.rrd.last_time": 1506473162,
...
 "description.kismet.system.battery.percentage": "int32_t, remaining battery percentage",
 "kismet.system.battery.percentage": 96,

 "description.kismet.system.battery.charging": "string, battery charging state",
 "kismet.system.battery.charging": "discharging",

 "description.kismet.system.battery.ac": "uint8_t, on AC power",
 "kismet.system.battery.ac": 0,

 "description.kismet.system.battery.remaining": "uint32_t, battery remaining in seconds",
 "kismet.system.battery.remaining": 0,

 "description.kismet.system.timestamp.sec": "uint64_t, system timestamp, seconds",
 "kismet.system.timestamp.sec": 1506473162,
 }
}
```

For each defined field, Kismet will include a metadata field, `description.whatever.field.name`, which gives the type (for instance, uint32_t for a 32bit unsigned int), and the description, for instance 'battery remaining in seconds'.

While the `prettyjson` format is well suited for learning about Kismet and developing tools to interface with the REST API, the `json` format should be used for final code; it is significantly faster than `prettyjson` and is optimized for processing time and space.

`prettyjson` should work with nearly all REST endpoints which return JSON records, but will *NOT* work with `ekjson`-only endpoints (which are relatively rare, and documented accordingly below in the REST docs).

