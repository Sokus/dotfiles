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

backup_files() {
	for path in $@; do
		path_exp=${path/#~/$HOME}
		if [ -e $path_exp ]; then
			if [ -z ${no_confirm+x } ]; then
				read -p "Backup $path_exp? [Y/n]: " answer
				case $answer in
					[yY] | [yY][eE][sS] | "" ) ;;
					[nN] | [nN][oO] | *)
						echo Ignored.; continue
				esac
			fi
			cp -r $path_exp $(basename $path)
		fi
	done
}

restore_files() {
	for path in $@; do
		path_exp=${path/#~/$HOME}
		if [ -e $(basename $path_exp) ]; then
			if [ ! -d $(dirname $path_exp) ]; then
				if [ -z ${no_confirm+x} ]; then
					read -p "Make directory $(dirname $path_exp)? [Y/n]: " answer
					case $answer in
						[yY] | [yY][eE][sS] | "") ;;
						[nN] | [nN][oO] | *)
							echo Ignored.; continue
					esac
				fi
				mkdir -p $(dirname $path_exp)
			fi

			if [ -z ${no_confirm+x} ]; then
				read -p "Restore $path_exp? [Y/n]: " answer
				case $answer in
					[yY] | [yY][eE][sS] | "") ;;
					[nN] | [nN][oO] | *)
						echo Ignored.; continue
				esac
			fi
			cp -r $(basename $path_exp) $path_exp
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

case $mode in
	backup)		backup_files $@;;
	restore) 	restore_files $@;;
esac
