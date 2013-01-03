sfn [![Build Status](https://travis-ci.org/m1kc/sfn.png?branch=master)](https://travis-ci.org/m1kc/sfn)
===

A small and fast utility to send files over network.

Various notes
-------------

* If you're running Arch Linux, you can just install package `sfn`, we keep it pretty fresh.
* It won't compile on Ubuntu (Mint, etc.) because libphobos there is too old. Use [dmd](http://dlang.org/download.html).

Building and running
--------------------

Requirements:

* D compiler (dmd is recommended, gdc is officially supported too)
* make

If you already have all this, just type `make` (`make dmd`, `make gdc`) to build sources. `make install` will install sfn to `/usr/bin/` (other destinations are not supported yet). `install` also accepts `DESTDIR` variable allows you to set root folder different from `/` (for example: `make DESTDIR=/tmp/mypkg install`).

Help
----

Usage:

```
sfn --listen [options] [files to send]
sfn --connect <address> [options] [files to send]
```

sfn will establish a connection, send all the files, receive all the files from another side and then exit.

`-l` and `-s` are aliases for `--listen`, `-c` is an alias for `--connect`.

Options:

* `--version`, `-v`: Show sfn version and exit.
* `--help`, `-h`: Show this text and exit.
* `--port`, `-p`: Use specified port. Defaults to 3214.
* `--prefix`, `-f`: Add prefix to received files' path and name. For example: `/home/user/downloads/`, `sfn-`, `/etc/file-`.
* `--no-external-ip`, `-n`: Don't perform external IP detection and reverse DNS lookup.

Related projects
----------------

* [siphon](https://github.com/solkin/siphon) &mdash; a compatible C implementation
