#!/bin/bash

set -eu

: ${PREFIX:=''}

ARCH=$(dpkg --print-architecture)
SOURCENAME=atomixcloud.list
APTSOURCEDIR=$PREFIX/etc/apt/sources.list.d
APTSOURCELIST=$APTSOURCEDIR/$SOURCENAME
REPOSITORY=https://atomixcloud.github.io/ppa

echo "Source : $REPOSITORY"
echo "Arch   : $ARCH"

if [ -e $HOME/.termux ] || [ $(id -u) -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

if ! [ -d $APTSOURCEDIR ]; then
    $SUDO mkdir -p $APTSOURCEDIR
fi

curl -sSL --compressed "$REPOSITORY/utils/aptkey.gpg" | $SUDO apt-key add -
echo "deb $REPOSITORY stable main" | $SUDO tee $APTSOURCELIST
$SUDO apt update

exit 0
