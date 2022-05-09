#!/bin/bash

set -eu

TOPDIR=$PWD/..
ARCHS=( amd64 aarch64 )

usage() {
	echo "Update repository's package index"
	echo "Usage: $(basename $0) <architecture>"
	echo "Options:"
	echo "    Architecture: amd64 and aarch64"
	echo "    -a  --all  -- Update index for all architectures"
	echo "    -h  --help -- Show this help menu"
	exit 0
}

update_all_distros() {
	for ARCH in "${ARCHS[@]}"
	do
		update_distro $ARCH
	done
}

update_distro() {
	ARCHNAME=$1
	apt-ftparchive packages --arch $ARCHNAME pool/ > dists/stable/main/binary-$ARCHNAME/Packages
	gzip -9kf dists/stable/main/binary-$ARCHNAME/Packages
}

update_release() {
	cd dists/stable/
	cat $TOPDIR/utils/release.conf  > Release
	apt-ftparchive release . >> Release
	gpg --clearsign -o InRelease Release
	gpg -abs -o Release.gpg Release
}

#main()
if [ $# -lt 1 ]; then
	echo "$(basename $0): invalid arguments !!!"
	echo "Try with '--help' for more info."
	exit 1
fi

cd $TOPDIR

GETOPTS=$(getopt -o ah --long all,help -- "$@")
[[ "$?" != "0" ]] && usage

eval set -- "$GETOPTS"
while :
do
	case "$1" in
		-a | --all)
			update_all_distros;
			update_release;
			exit $?
			;;
		-h | --help)
			usage;
			;;
		--) shift; break ;; #End of the arguments
		*) echo "Unexpected option: '$1'."; break;
	esac
done

ARCHS=( $@ )
for ARCH in "${ARCHS[@]}"
do
	update_distro $ARCH
done

update_release;

exit 0
