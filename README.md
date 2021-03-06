sfn [![Build Status](https://travis-ci.org/m1kc/sfn.svg?branch=master)](https://travis-ci.org/m1kc/sfn)
===

A small and fast utility to send files over network.



Various notes
-------------

* If you're running Arch Linux, you can install package `sfn` from AUR. However, it's slightly outdated (but I prefer the word "stable").
* It won't compile with gdc on Ubuntu (Mint, Debian, etc.) because libphobos there is too old.



Building and running
--------------------

Requirements:

* D compiler of your choice ([dmd](http://dlang.org/download.html), [ldc](https://github.com/ldc-developers/ldc) or [gdc](http://gdcproject.org/downloads/))
* make

If you already have all this, just type `make` (or `make ldc`, or `make gdc`) to build sources.

`make install` will install sfn to `/usr/bin/` (other destinations [are not supported yet](https://github.com/m1kc/sfn/issues/13)). `install` also accepts `DESTDIR` variable allows you to set root folder different from `/` (for example: `make DESTDIR=/tmp/mypkg install`).

If you need to rebuild the manpage (typically you don't), install ronn and run `make man`.

There also is experimental Ninja support. Try `ninja` and `ninja -t clean`.


Help
----

Usage:

    sfn --listen [options] [files to send]
    sfn --connect <address> [options] [files to send]

sfn will establish a connection, send all the files, receive all the files from another side and then exit.

`-l` and `-s` are aliases for `--listen`, `-c` is an alias for `--connect`.

Options:

* `--version`, `-v`: Show sfn version and exit.
* `--help`, `-h`: Show this text and exit.
* `--port`, `-p`: Use specified port. Defaults to 3214.
* `--prefix`, `-f`: Add prefix to received files' path and name. For example: `/home/user/downloads/`, `sfn-`, `/etc/file-`.
* `--no-external-ip`, `-n`: Don't perform external IP detection and reverse DNS lookup.
* `--zenity`, `-z`: Call zenity to select files using standard GTK dialog.
* `--no-integrity-check`, `-e`: Disable integrity check after transfer. This option was added for compatibility with older versions of sfn.



Related projects
----------------

* [siphon](https://github.com/solkin/siphon) &mdash; a bit outdated, but still compatible C implementation
