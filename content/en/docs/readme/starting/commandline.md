---
title: "Command line options"
description: ""
lead: ""
date: 2022-08-23T13:29:59-04:00
lastmod: 2022-08-23T13:29:59-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "commandline-10f0db5095bd24cd6c4ba502ef4b73d5"
weight: 20
toc: true
---

Kismet loads the bulk of configuration from the configuration files, however it also accepts a number of command line options which take precedence and allow for speedy changes to common configuration options.

## Kismet command line options

### Core Kismet options 

{{<argument no-ncurses>}}
By default, Kismet uses a small ncurses-based wrapper to remind users to visit the web-based UI.  When running Kismet in a script or as a service, it's probably desireable to disable this and use pure text output.
{{</argument>}}


{{<argument debug>}}
Enable debug mode, primarily for running under GDB.  Debug mode disables the internal crash and backtrace code, turns off the ncurses wrapper, and sets up some other state for easier debugging.
{{</argument>}}


{{<argument no-line-wrap>}}
Kismet line-wraps messages on the terminal to make them more readable.  When running in a script or as a service, it may be more useful to have a complete status message on a single line. 
{{</argument>}}


{{<argument no-plugins>}}
Turn off loading plugins.  Mostly useful when debugging if a plugin is causing a crash.
{{</argument>}}

### Logging options 

{{<argumentshort n no-logging>}}
Turn off all logging for this run.
{{</argumentshort>}}


{{<argumentshort t log-title title>}}
Set the log title for this run; this populates the title field of the log template.
{{</argumentshort>}}


{{<argumentshort p log-prefix prefix-directory>}}
Use an alternate log prefix for this run, this logs files to a different location.
{{</argumentshort>}}


{{<argumentshort T log-types "type1,type2,...,typeN">}}
Set what type of logs are generated for this run.
{{</argumentshort>}}

### Configuration options

{{<argument homedir path>}}
Use an alternate home directory path instead of the users `${HOME}`.
{{</argument>}}


{{<argument confdir path>}}
Use an alternative configuration directory instead of the value Kismet was compiled with.
{{</argument>}}


{{<argument override flavor>}}
Use an override config file.  [Learn about config overrides here](/docs/readme/configuring/configfiles/#configuration-override-and-flavors).
{{</argument>}}
