#!/bin/bash

set -eu

TOPDIR=$PWD/..
ARCHS=( amd64 aarch64 )

usage() {
	cat <<-USAGE
	Update Package and Release files of mentioned architectures.
	Usage: $(basename $0) <architecture>
	Options:
	    -a  --all  -- Update index for all architectures
	    -h  --help -- Show this help menu
	               -- Running script without arguments will update details 
	                  for all supported architectures (amd64 and aarch64).
	Example:
	 $ updaterepo.sh                 # Update release files for all architectures (similar to --all)
	 $ updaterepo.sh amd64           # Update release files for AMD64 architecture
	 $ updaterepo.sh amd64 aarch64   # Update release files for AMD64 and ARM64 architectures
	USAGE

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
	DIRPKGFILE=dists/stable/main/binary-$ARCHNAME

	if [ "$ARCHNAME" != "${ARCHS[0]}" ] && [ "$ARCHNAME" != "${ARCHS[1]}" ] ; then
		echo "Invalid architecture '$ARCHNAME' !!!"
		exit 1
	fi

	if [ ! -d $DIRPKGFILE ]; then
		echo "Invalid path '$DIRPKGFILE': file not exist"
		exit 1
	fi

	echo "Updating repository for '$ARCHNAME' ..."
	apt-ftparchive packages --arch $ARCHNAME pool/ > $DIRPKGFILE/Packages
	gzip -9kf $DIRPKGFILE/Packages
}

update_release() {
	cd dists/stable/
	cat $TOPDIR/utils/release.conf  > Release
	apt-ftparchive release . >> Release

	[[ -f InRelease ]] && rm -f InRelease
	[[ -f Release.gpg ]] && rm -f Release.gpg

	gpg --clearsign -o InRelease Release
	gpg -abs -o Release.gpg Release
}

#------------------------------
# Main procedure starts here
#------------------------------

cd $TOPDIR

if [ $# -lt 1 ]; then
	update_all_distros;
	update_release;
	exit 0
fi

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

ARGV=( $@ )
for ARG in "${ARGV[@]}"
do
	update_distro $ARG
done

update_release;

exit 0
