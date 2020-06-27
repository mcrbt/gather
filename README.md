# gather


## Brief description

`gather` is a small *Bash* script for Linux operating systems intended to
collect all self-written scripts from the file system. Therefore it needs to be
able to distinguish between scripts that are shipped with a Linux distribution
or have been installed later along with, or as part of, a software package for
an official repository, and those written by the user, e.g. to automate tasks.


## Preamble

When installing software on Linux the relevant files are distributed to specific
file system locations. Executables may go to `/usr/bin/`, libraries may go to
`/usr/lib/`, configuration files may go somewhere under `/etc/`, license
documents, manual pages and other resources may go somewhere under
`/usr/share/`, and so on.
This is different from installing software on Windows or Mac operating systems
where all the files are installed to one single directory, e.g. under
`C:\Program Files (x86)\` on Windows. In this case installed software searches
for relevant files using paths relative to the executable.

Linux software is usually installed using a package manager, which moves files
of the software to their respective locations. However, sometimes required
software is not available in the official software repositories of a Linux
distribution. Linux software downloaded from a website often comes as a
"tar"-archive containing all required files. The user may use a specific file
system location for software downloaded by a browser to be installed installed
"the Windows way" (e.g. `/usr/local/prg`). The executable in that directory can
then be symbolically linked from `/usr/bin` or `/usr/local/bin`.
Executables of software written by the user is usually placed under
`/usr/local/bin` (or symbolically linked from there, respectively).


## Further remark

A better approach to the task `gather` tries to undertake may be to use the
package manager of the respective Linux distribution to check whether a specific
script is part of some package listed in the official (or even unofficial)
repositories. That could potentially be a costly operation but would then be up
to the package manager to perform it in reasonable time.
The result could be more reliable (although not 100% correct). Anyway this would
require the script to support numerous package managers and there are still new
ones evolving. Hence that approach is not really reasonable in terms of this
project.


## Operation

`gather` scans the `/usr/local/bin` directory, following symbolic links. If
an entry is a binary file (e.g. *ELF 64-bit*) that file is skipped. If a
symbolic link points to a subdirectory of a "single directory installation
location" (e.g. `/usr/local/prg`) this file is skipped, as well. All ASCII text
files are evaluated using the "file" command, manually by inspecting the
*interpreter line* at beginning of the file (e.g. `#!/usr/bin/perl`), or via its
filename extension.
All conforming files will be packed together as a `tar` archive, compressed with
the `xz` tool and moved to a specified archiving location.


## Configuration

The *archive directory*, as well as the root location for "single directory
installations" can be configured by editing the variables at the beginning of
the script `gather.sh` in the marked `CONFIGURATION SECTION`, namely `ARLOC` and
`SINGLE_INST_LOC`.

**Note**: "Configuration" should be done *before* running the script to make
it work properly.

`gather.sh` (or a symbolic link pointing to it) may reside under
`/usr/local/bin`, as well. If it shall not be included in the resulting archive
the "boolean" variable `INCLUDE_GATHER` can be altered. It can also be found in
the `CONFIGURATION SECTION` at the beginning of the script, as well. A value of
0 means `false` (i.e. *exclude* gather from the archive), any other value means
`true` (i.e. *include* gather in the archive).

Further configuration is not really intended, and should not be necessary.
However, the script can be adapted to meet the users needs and use cases, of
course.


## Installation

In order to install `gather` only three simple steps are necessary.

1. Clone this repository to a local directory on your system, using:

```
$ git clone https://github.com/mcrbt/gather.git
```

2. Either move/copy the script `gather.sh` (with or without filename extension)
   to `/usr/local/bin`, or create a symbolic link in `/usr/local/bin` or
   `$HOME/bin` to `gather.sh` in the cloning/installation directory.

3. Make the script `gather.sh` (not the symbolic link) executable, using:

```
$ chmod 755 gather.sh
```


As `/usr/local/bin` is contained in the environment variable `PATH` by default,
`gather` should then be accessible like any other command. If it shall reside
in `$HOME/bin` that directory should be contained in the `PATH` variable, as
well.

`gather` tests whether the user executing the script is `root`, where
`$HOME/bin` would evaluate to `/root/bin`.
To execute `gather` as non-privileged user the respective line
(roughly line 258) in `gather.sh` can be removed or commented:

```
#if [ ! $EUID -eq 0 ]; then echo "please run as root"; exit 1; fi
```


## Dependencies

As `gather` is a Bash script it naturally depends on the availability of various
system tools. Almost all of these tools should be present on any Linux
distribution by default. Here is the complete list of tools that must be
installed for `gather` to work:

`awk, basename, date, file, head, mkdir, mv, perl, readlink,
sed, sort, tar, wc, xz`

`gather` initially checks whether all the commands are installed on the system
and are accessible via the `PATH` environment variable. The command `which`
should also be in the list of dependencies, but as `which` is used to check for
all the other dependencies that would be pointless, somehow.


## Execution

Since `gather` has been moved/copied/symlinked to `/usr/local/bin` or
`$HOME/bin` (which should be contained in your system `PATH` variable) it should
simply be runnable via:

```
$ gather
```

or, in case the filename extension has not been stripped:

```
$ gather.sh
```


## Command line interface

`gather` does not take any options regarding its behaviour. Still the following
arguments are available:

```
gather [version | license | dependencies | help]

   version | -V | --version
      print version information

   license | -L | --license
      print GPLv3 license disclaimer

   dependencies | deps | -D | --deps | --dependencies
      print list of dependencies

   help | -h | --help | usage | -U | --usage
      print this usage information
```


## Copyright

Copyright &copy; 2020 Daniel Haase

`gather` is licensed under the **GNU General Public License**, version 3.


## License disclaimer

```
gather - gather all self-written scripts
Copyright (C) 2020  Daniel Haase

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/gpl-3.0.txt>.
```

[GPL (version 3)](https://www.gnu.org/licenses/gpl-3.0.txt)
