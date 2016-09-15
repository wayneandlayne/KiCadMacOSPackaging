#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=kicad

if [ ! -d $SRC ]; then
    git clone https://git.launchpad.net/kicad 
fi

cd kicad

echo "Cleaning tree."
git clean -fd
git reset --hard HEAD

echo "Pulling new revisions."
git checkout master
git pull

REVNO=`git rev-parse --short HEAD`
echo "At r$REVNO"
cd -

mkdir -p $BASE/notes
echo "$REVNO" > $BASE/notes/kicad_revno

if [ -e $BASE/notes/kicad_patches ]; then
	rm $BASE/notes/kicad_patches
fi

if [ -e $BASE/kicad_patches ]; then
	for patch in `find $BASE/kicad_patches -type f -name \*.patch`; do
		echo "Applying $patch"
		patch -p0 < $patch
		echo "`basename $patch`" >> $BASE/notes/kicad_patches
	done
fi

if [ -e $BASE/kicad_downloads ]; then
	mkdir -p .downloads-by-cmake
	cp -r $BASE/kicad_downloads/* .downloads-by-cmake/. || true #ignore failure
fi

cd -
