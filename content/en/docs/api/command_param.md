---
title: "API parameters"
description: ""
lead: ""
date: 2022-10-17T09:24:24-04:00
lastmod: 2022-10-17T09:24:24-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "command_param-89accec3ab8b597633c4d98f369f925f"
weight: 40
toc: true
---

Kismet command parameters are (usually) sent via `HTTP POST`.  Additional endpoints may accept other HTTP verbs in the future such as `PUT`, and will be marked as such in the API documentation.

Parameters can be sent as either a HTTP form-encoded post, where the parameters should be encoded as a form variable named `json`, or as a JSON document sent as a JSON content type.

Parameters sent as a form element should be sent using the `x-www-form-encoded` content type; if your environment does not set this by default, you may need to specify

```javascript
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
```

as part of the requests you send.

Parameters sent as JSON content should be sent as type `application/json`:

```javascript 
Content-Type: application/json; charset=UTF-8
```

## Generating commands

A simple Javascript generator might look similar to:

```javascript
var json = {
    "cmd": "lock",
    "channel": "6",
    "uuid": "aaa:bbb:cc:dd:ee:ff:gg"
};

var postdata = "json=" + JSON.stringify(json);

$.post("/some/endpoint", data = postdata, dataType = "json");
```

Similarly, commands can be sent from the command line:
```bash
curl -d 'json={"cmd": "lock", "channel": 6}' http://user@host:2501/some/endpoint
```

To send parameters as a JSON object directly:

```bash 
curl --data '{"cmd":"lock", "source_uuid":"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"}' -H 'Content-Type: application/json' http://user@host:2501/some/endpoint
```

Commands are encoded as dictionaries to allow flexibility across calling platforms, as well as forward-compatibility as endpoints evolve.  Adding additional keys to an options dictionary should not cause an older version of the server code to return an error.

Dictionary key values are case sensitive.

## Timestamps

Kismet allows both absolute and relative timestamps in almost all APIs which accept a timestamp value; those APIs which only work with an absolute timestamp will be denoted specially.

An absolute timestamp value is a Unix timestamp in seconds since the timestamp epoch.  All positive timestamp values are interpreted as absolute, epochal timestamps.  Epochal timestamps are in UTC, and are converted to local time based on the time zone of the interpreting system (such as the web browser).

A relative timestamp is calculated automatically by the Kismet server as relative from *now*.  All negative timestamp values are interpreted as relative timestamps, and interpreted as (*now* - *timestamp*).

Relative timestamps are useful for fetching events from the past *N* seconds, without needing to know the current timestamp of the server.

## Field simplification

Most Kismet endpoints which return records will also accept a field simplification as part of the command dictionary.  Field simplifications allow the reduction of the data being returned, analogous to `select a, b, c` instead of `select *` in SQL.

Simplifying fields, especially when performing very large queries, reduces the CPU and memory requiremets of Kismet *and* the client by reducing the amount of data being serialized, transmitted, and deserialized.  Users of the REST API are *strongly* encouraged to make use of field simplification whenever plausible.

Field simplification objects take the format of a vector/array containing multiple field definitions:

```python
[
    field1,
    ...
    fieldN
]
```

where a field may be a single element string, defining a field name or a field path, such as:

* `'kismet.device.base.channel'`
* `'kismet.device.base.signal/kismet.common.signal.last_signal'`

*or* a field may be a two-element array, consisting of a field name or path, and a target name the field will be aliased as, for example:

* `['kismet.device.base.channel', 'base.channel']`
* `['kismet.device.base.signal/kismet.common.signal.last_signal', 'base.last.signal']`

Fields will be returned in the device as their final path name:  that is, from the above example, the device would contain:

`['kismet.device.base.channel', 'kismet.common.signal.last_signal']`

And from the second example, it would contain:

`['base.channel', 'base.last.signal']`

When requesting multiple fields from different paths with the same name - for instance, multiple signal paths provide the `kismet.common.signal.last_signal` - it is important to provide an alias.  Fields which resolve to the same name will only be present in the results once, and the order is undefined.

### Unknown fields

Requesting a field which does not exist, or a path which cannot be resolved, will return a field of the requested name containing an integer `0`; for safety, consumers of the API should handle this gracefully.

## Regex filters

Some endpoints in Kismet take a regex object.  These endpoints use a common format, which allows for multiple regular expressions to be mapped to multiple fields.  A device is considered to match if *any* of the regular expression terms are true.

If the Kismet server was compiled *without* libpcre support, passing a regular expression to an endpoint will cause the endpoint to return an error.

```python
[
    [ multifield, regex ],
    ...
    [ multifield, regex ]
]
```

### `multifield`

`multifield` is a standard field path, but it will be automatically expanded to match all values if a vector or value-map field is encountered in the path.  For example, the multifield path:

`'dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid'`

will be expanded to include all `dot11.advertisedssid` objects in the `advetised_ssid_map` dictionary, and will apply to the `dot11.advertisedssid.ssid` field in each.  Similarly, vectors, intmaps, doublemaps, macmaps, and so forth will be expanded, allowing matching against nested fields.

The field is expected to resolve as a string:  if it is not a string, the regex will be considered to not match.

### `regex`

`regex` is a simple string containing a PCRE-compatible regular expression.

### Example

For example, to match on SSIDs, a regex object might be:

```python
regex = [
    [ 'dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid', '^SomePrefix.*' ],
    [ 'dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid', '^Linksys$' ]
]
```

For extracting over curl, a similar example:

```bash
$ curl -d \
'json={"regex": [["dot11.device/dot11.device.advertised_ssid_map/dot11.advertisedssid.ssid", "^Linksys$"]]}' \
http://user:password@server:2501/devices/views/phydot11_accesspoints/devices.json
```

### Array of regex pairs

Notice that the regex field takes an *array* of field/regex pairs!  For a single regex match, the nested array is still required:

```
json={"regex": [ ["field", "match"] ]}
```

*not*

```
json={"regex": ["broken", "example"]}
```


