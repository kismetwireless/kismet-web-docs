---
title: "Serialization"
description: ""
lead: ""
date: 2022-10-23T17:54:50-04:00
lastmod: 2022-10-23T17:54:50-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "serialization-fbfdbed25d0374092c87ad0e92f60577"
weight: 50
toc: true
---

Kismet can export data as several different formats; generally these formats are indicated by the type of endpoint being requested (such as foo.json)

## JSON

Kismet will export objects in traditional JSON format suitable for consumption in javascript or any other language with a JSON interpreter.

## TJSON

Some JSON processing systems use the period (`.`) as a separator for trees and paths, while Kismet uses it as part of the name space of the field.

Using the `.tjson` extension on any REST endpoint will return normal JSON records, but all field names will be changed so that the `.` separator is swapped for `_`; for example `kismet.device.base` will become `kismet_device_base`, and `sensor.device.last_record` would become `sensor_device_last_record`.

## EKJSON

"EK" JSON is modeled after the Elastic Search JSON format, where a complete JSON object is found on each line of the output.

Kismet supports ekjson on any REST endpoint which returns a vector/list/array of results.

*Added 2019-10*
To be compatible with the ELK interpretation of field names, Kismet now permutes all field names in `ekjson` output, replacing all instances of `.` with `_`.

## ITJSON

*Added 2019-10*

"IT" or "Iterative" JSON is a variant of JSON optimized for large vector/array data sets.  Instead of containing the entire output in a JSON array, each element of the array is sent on its own newline.

*All non-ELK use of previous ekjson endpoints should now use itjson endpoints*.  The ekjson serialization now modifies field names.

Kismet supports itjson on any REST endpoint which returns a vector/list/array of results.

The itjson results must be parsed *as a stream* instead of *as a traditional JSON object*.  Attempting to parse an itjson response as traditional JSON will result in syntax errors.

## PRETTYJSON

"Pretty" JSON is optimized for human readability and includes metadata fields describing what Kismet knows about each field in the JSON response.  For more information, see the previous section, `Exploring the REST system`.

"Pretty" JSON should only be used for learning about Kismet and developing; for actual use of the REST API standard "JSON" or "EKJSON" endpoints should be used as they are significantly faster and optimized.
