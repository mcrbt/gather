#!/bin/bash
##
## gather - gather all self-written scripts
## Copyright (C) 2020  Daniel Haase
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##

TITLE="gather"
VERSION="1.3.1"
AUTHOR="Daniel Haase"
CRYEARS="2020"
COPYRIGHT="copyright (c) $CRYEARS $AUTHOR"
DATE=$(TZ=Europe/Berlin date +%y%m%d)

## START OF CONFIGURATION SECTION

## archiving location
ARLOC="/home/daniel/arv/scripts/"

## install location for single directory software (Windows style)
SINGLE_INST_LOC="/usr/local/prg"

## include this script "gather.sh" in the resulting archive
## if $INCLUDE_GATHER equals 0 the script is not included; otherwise it is
INCLUDE_GATHER=1

## END OF CONFIGURATION SECTION

ARGS="$@"
scripts=""

## print version information
function version
{
	echo "$TITLE version $VERSION"
	echo "$COPYRIGHT"
}

## print GPLv3 license disclaimer
function license
{
	echo ""
	echo "gather - gather all self-written scripts"
	echo "Copyright (C) $CRYEARS  $AUTHOR"
	echo ""
	echo "This program is free software: you can redistribute it and/or modify"
	echo "it under the terms of the GNU General Public License as published by"
	echo "the Free Software Foundation, either version 3 of the License, or"
	echo "(at your option) any later version."
	echo ""
	echo "This program is distributed in the hope that it will be useful,"
	echo "but WITHOUT ANY WARRANTY; without even the implied warranty of"
	echo "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
	echo "GNU General Public License for more details."
	echo ""
	echo "You should have received a copy of the GNU General Public License"
	echo "along with this program.  If not, see <https://www.gnu.org/licenses/>."
	echo ""
}

## print usage information
function usage
{
	echo ""
	version
	echo ""
	echo "usage:  $TITLE [version | license | dependencies | help]"
	echo ""
	echo "   version | -V | --version"
	echo "      print version information"
	echo ""
	echo "   license | -L | --license"
	echo "      print GPLv3 license disclaimer"
	echo ""
	echo "   dependencies | deps | -D | --deps | --dependencies"
	echo "      print list of depandancies"
	echo ""
	echo "   help | -h | --help | usage | -U | --usage"
	echo "      print this usage information"
	echo ""
}

## print dependencies
function dependencies
{
	echo "$TITLE depends on the following POSIX tools:"
	echo "   awk, basename, date, file, head, mkdir, mv, perl,"
	echo "   readlink, sed, sort, tar, wc, xz"
}

## test if command $1 is available on the system (i.e. is in $PATH)
## returns 0 on success, exits with code 2 on failure
function check_command
{
	local C=$1
	if [ $# -eq 0 ] || [ -z $C ]; then return 0; fi
	which $C &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$C\" not found"; exit 2; fi
	return 0
}

## handle command line arguments $@
## returns 0 on success, exits otherwise
function command_line
{
	local ARGS="$@"
	local ARG="$1"

	if [ $# -eq 0 ] || [ -z $ARGS ]; then return 0 ## success; continue usual operation
	elif [ $# -ne 1 ] || [ -z $ARG ]; then
		usage
		exit 3
	else
		if [ "$ARG" == "version" ] || [ "$ARG" == "-V" ] || [ "$ARG" == "--version" ]; then
			version
			exit 0
		elif [ "$ARG" == "license" ] || [ "$ARG" == "-L" ] || [ "$ARG" == "--license" ]; then
			license
			exit 0
		elif [ "$ARG" == "dependencies" ] || [ "$ARG" == "deps" ] || [ "$ARG" == "-D" ]; then
			dependencies
			exit 0
		elif [ "$ARG" == "--deps" ] || [ "$ARG" == "--dependencies" ]; then
			dependencies
			exit 0
		elif [ "$ARG" == "help" ] || [ "$ARG" == "-h" ] || [ "$ARG" == "--help" ]; then
			usage
			exit 0
		elif [ "$ARG" == "usage" ] || [ "$ARG" == "-U" ] || [ "$ARG" == "--usage" ]; then
			usage
			exit 0
		else
			usage
			exit 3
		fi
	fi
}

## test if file $1 is a self-written script
## returns 0 on success, 1 on failure
function is_conform
{
	local NAME="$1"

	## validate function parameter
	if [ $# -eq 0 ] || [ -z $NAME ]; then return 1; fi
	if [ ! -e $NAME ]; then echo "file \"$NAME\" not found"; return 1; fi

	## exclude this script if so configured at the beginning of this file
	if [ $INCLUDE_GATHER -eq 0 ]; then
		if [[ "$NAME" == *"gather"* ]]; then return 1; fi
	fi

	local type=$(file $NAME | awk '{print $2}')

	## excludes symbolic links to manually installed software
	if [[ $NAME == "$SINGLE_INST_LOC"* ]]; then return 1; fi

	## only accept executable scripts
	#if [ ! -x $NAME ]; then return 1; fi

	if [ "$type" == "ELF" ]; then return 1 ## exclude binary executables
	elif [ "$type" == "ASCII" ]; then ## manually decide plain text ascii file
		local ext=${NAME##*.}
		local inter=$(head -n 1 < $NAME)

		## accept if a valid interpreter is specified
		if [[ $inter == "#!"* ]]; then
			local ploc=""
			type=$(echo $inter | awk '{print $1}')
			type=${inter:2}

			## if "interpreter" is "env", test next argument
			if [ "$(basename $type)" == "env" ]; then
				type=$(echo $inter | awk '{print $2}')
			fi

			ploc=$(which $(basename $type) &> /dev/null)

			## test if interpreter is installed and executable
			if [ "$type" == "$ploc" ]; then return 0
			else return 1; fi
		fi

		## test for OpenEuphoria script (eui)
		if [[ $inter == *"euphoria"* ]] || [[ $inter == *"eui" ]]; then return 0; fi

		## accept several filename extensions
		case "$ext" in
			"bash" | "csh" | "fish" | "ksh" | "ps1" | "sh" | "tcsh" | "zsh") ## shell scripts
				return 0
				;;
			"ex" | "e" | "jl" | "js" | "pl" | "purs" | "py" | "rb" | "tcl") ## other scripting languages
				return 0
				;;
			*) ## discard all other filename extensions
				return 1
				;;
		esac
	elif [ "$type" == "a" ]; then ## interpreter line found for unknown language
		type=$(file $NAME | awk '{print $3}')
		local ploc=$(which $type &> /dev/null)

		## test if interpreter is installed and executable
		if [ "$(basename $type)" == "$ploc" ]; then return 0
		else return 1; fi
	elif [ "$type" == "Bourne-Again" ]; then return 0 ## Bourne Again shell script (bash)
	elif [ "$type" == "C" ]; then return 0 ## C shell script (csh)
	elif [ "$type" == "Korn" ]; then return 0 ## Korn shell script (ksh)
	elif [ "$type" == "Node.js" ]; then return 0 ## Javascript file (node)
	elif [ "$type" == "Paul" ]; then ## probably a Z shell script (zsh)
		type=$(file $NAME | awk '{print $2 $3 $4}')
		if [ "$type" == "Paul Falstad's zsh" ]; then return 0 ## actually a Z shell script (zsh)
		else return 1; fi
	elif [ "$type" == "Perl" ]; then return 0 ## Perl script (perl)
	elif [ "$type" == "POSIX" ]; then return 0 ## POSIX shell script (sh)
	elif [ "$type" == "Python" ]; then return 0 ## Python 2 or Python 3 script (python)
	elif [ "$type" == "Ruby" ]; then return 0 ## Ruby script (ruby)
	elif [ "$type" == "Tcl/Tk" ]; then return 0 ## Tcl/Tk script (wish)
	elif [ "$type" == "Tcl" ]; then return 0 ## Tcl script (tclsh)
	elif [ "$type" == "Tenex" ]; then return 0 ## Tenex C shell script (tcsh)
	else return 1; fi
}

## handle command line arguments
command_line "$ARGS"

## check dependencies
check_command "awk"
check_command "basename"
check_command "date"
check_command "file"
check_command "head"
check_command "mkdir"
check_command "mv"
check_command "perl"
check_command "readlink"
check_command "sed"
check_command "sort"
check_command "tar"
check_command "wc"
check_command "xz" ## used by tar for compression

## exit with code 1 if user is not root
if [ ! $EUID -eq 0 ]; then echo "please run as root"; exit 1; fi

## create archiving directory if it does not exist
if [ ! -d "$ARLOC" ]; then mkdir -p "$ARLOC"; fi


##
## BEGIN MAIN OPERATION
##

## collect all relevant scripts from /usr/local/bin
for f in /usr/local/bin/*; do
	loc=$(readlink -f $f)
	if ! is_conform $loc; then continue; fi
	scripts="$loc $scripts"
done

## format script array for tar command
scripts=$(echo $scripts | sed 's/ /\n/g' | sort -u | perl -pe 'tr/\n/ /')

if [ -f "${ARLOC}/scripts${DATE}.txz" ]; then
	echo "file \"scripts${DATE}.txz\" already exists"
	read -p "replace it? [Y/n] " reply

	if [ ! -z "$reply" ] && [ "$reply" != "y" ] && [ "$reply" != "Y" ] \
	&& [ "$reply" != "yes" ] && [ "$reply" != "Yes" ] && [ "$reply" != "YES" ]; then
		echo "no scripts archived"
		exit 0
	fi
fi

## create archive
tar cJf "scripts${DATE}.txz" --exclude-backups --transform='s/.*\///g' $scripts &> /dev/null

## move archive to respective location
mv "scripts${DATE}.txz" $ARLOC

## count number of archived scripts and print it out
count=$(echo "$scripts" | wc -w)
echo "$count scripts archived"

## exit successfully
exit 0
