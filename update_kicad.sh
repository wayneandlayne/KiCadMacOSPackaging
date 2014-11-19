#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=../kicad/kicad

if [ ! -d $SRC ]; then
	mkdir -p $SRC
	cd $SRC
	bzr branch lp:kicad
	cd -
fi

cd $SRC
#check to make sure the SRC is actually a kicad checkout!
if ! bzr info | grep "checkout of branch: bzr+ssh://bazaar.launchpad.net/+branch/kicad/$"; then
    echo "$SRC is not a KiCad checkout.  Exiting."
    exit 1
fi

echo "Cleaning tree."
bzr clean-tree --verbose --force --ignored --unknown --detritus
REVNO=`bzr revno`
echo "At r$REVNO"

mkdir -p $BASE/notes
echo "$REVNO" > $BASE/notes/kicad_revno

if [ -e $BASE/notes/kicad_patches ]; then
	rm $BASE/notes/kicad_patches
fi

if [ -e $BASE/kicad_patches ]; then
	for patch in `find $BASE/kicad_patches -type f`; do
		echo "Applying $patch"
		patch -p0 < $BASE/kicad_patches/$patch
		echo "$patch" >> $BASE/notes/kicad_patches
	done
fi

cd -

