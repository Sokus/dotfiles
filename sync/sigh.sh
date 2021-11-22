#!/bin/bash

echo_hint() { echo "Try 'sigh -h' for more information"; }
invalid_option() { echo "sigh: invalid option -- '$1'"; }

echo_help() {
	echo "Usage: sigh [OPTION]... FILE..."
	echo "  -b  make a backup of files existing on disk"
	echo "  -r  restore backups from current directory"
	echo "  -y  do not prompt for operations"
	echo "  -h  display this help and exit"
}

sync_files() {
	src_prefix=""
	dst_prefix=""
	case $mode in
		backup) dst_prefix=".";;
		restore) src_prefix=".";;
	esac
	for path in $@; do
		path_exp=${path/#~/$HOME}
		src="$src_prefix$path_exp"
		dst="$dst_prefix$path_exp"
		if [ -e $src ]; then
			if [ ! -d $(dirname $dst) ]; then
				if [ -z ${no_confirm+x} ]; then
					read -p "Make directory $(dirname $dst)? [Y/n]: " answer
					case $answer in
						[yY] | [yY][eE][sS] | "");;
						[nN] | [nN][oO] | *) echo Ignored.; continue;;
					esac
				fi
				mkdir -p $(dirname $dst)
			fi

			if [ -z ${no_confirm+x} ]; then
				read -p "Restore $src? [Y/n]: " answer
				case $answer in
					[yY] | [yY][eE][sS] | "");;
					[nN] | [nN][oO] | *) echo Ignored.; continue;;
				esac
			fi
			cp -r $src $dst
		else
			echo "Could not find $src."
		fi
	done
}

while getopts ":bryh" o; do
	case $o in
		b)	if [ ! -z ${mode+x} ]; then
				invalid_option $o 1>&2
				echo "sigh: mode already set to '$mode'" 1>&2
				exit 3
			fi
			mode="backup"
			;;
		r) 	if [ ! -z ${mode+x} ]; then
				invalid_option $o 1>&2
				echo "sigh: mode already set to '$mode'" 1>&2
				exit 3
			fi
			mode="restore"
			;;
		y) 	no_confirm=true;;
		h)	echo_help
			exit 0;;
		*)	invalid_option $OPTARG 1>&2
			echo "Try 'sigh -h' for more information." 1>&2
			exit 4
			;;
	esac
done
shift $((OPTIND-1))

if [ -z ${mode+x} ]; then
	echo "sigh: missing mode flag" 1>&2
	echo_hint 1>&2
	exit 1
fi

if [ $# -eq 0 ]; then
	echo "sigh: missing file arguments" 1>&2
	echo_hint 1>&2
	exit 2
fi

sync_files $@
