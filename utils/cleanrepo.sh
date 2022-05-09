#!/bin/bash

TOPDIR=$PWD/..

rm -rvf $TOPDIR/dists/stable/InRelease \
        $TOPDIR/dists/stable/Release \
        $TOPDIR/dists/stable/Release.gpg \
        $TOPDIR/dists/stable/main/*/Packages \
        $TOPDIR/dists/stable/main/*/Packages.gz
