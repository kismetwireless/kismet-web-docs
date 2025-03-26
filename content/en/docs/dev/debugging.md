---
title: "Debugging"
description: ""
lead: ""
date: 2023-04-15T10:06:22-04:00
lastmod: 2023-04-15T10:06:22-04:00
images: []
menu:
  docs:
    parent: ""
    identifier: "debugging-3c5bbcc29239559f6d5ad34187b8f3c2"
weight: 10
toc: true
---

Kismet (especially in beta) is in a state of rapid development - this means that bad things can creep into the code.  Sorry about that!

If you're interested in helping debug problems with Kismet, here's the most useful way to do so:

1. Compile Kismet from source (per the quick start guide above)

2. Install Kismet (typically via `sudo make suidinstall`)

3. Run Kismet, *FROM THE SOURCE DIRECTORY*, in `gdb`:

  ```bash
  $ gdb ./kismet
  ```

  This loads a copy of Kismet with all the debugging info intact; the copy of Kismet which is installed system-wide usually has this info removed; the installed version is 1/10th the size, but also lacks a lot of useful information which we need for proper debugging.

4. Tell GDB to ignore the PIPE signal

   ```
   (gdb) handle SIGPIPE nostop noprint pass
   ```

   This tells GDB not to intercept the SIGPIPE signal (which can be generated, among other times, when a data source has a problem)

5. Configure GDB to log to a file

  ```
  (gdb) set logging on
  ```

  This saves all the output to `gdb.txt`

5. Run Kismet - *in debug mode*

  ```
  (gdb) run --debug [any other options]
  ```

  This turns off the internal error handlers in Kismet; they'd block gdb from seeing what happened.  You can specify any other command line options after --debug; for instance:

  ````
  (gdb) run --debug -n -c wlan1
  ````

6.  Wait for Kismet to crash

7.  Collect a backtrace
   ```
   (gdb) bt
   ```

   This shows where Kismet crashed.

8.  Collect thread info
   ```
   (gdb) info threads
   ```

   This shows what other threads were doing, which is often critical for debugging.

9.  Collect per-thread backtraces
   ```
   (gdb) thread apply all bt full
   ```

   This generates a dump of all the thread states

10. Send us the gdb log and any info you have about when the crash occurred; dragorn@kismetwireless.net or swing by IRC or the Discord channel (info available about these on the website, https://www.kismetwireless.net)

## Advanced debugging

If you're familiar with C++ development and want to help debug even further, Kismet can be compiled using the ASAN memory analyzer; to rebuild it with the analyzer options:

```
    $ make clean
    $ CC=clang CXX=clang++ ./configure --enable-asan
```

ASAN has a performance impact and uses significantly more RAM, but if you are able to recreate a memory error inside an ASAN instrumented Kismet, that will be very helpful.
