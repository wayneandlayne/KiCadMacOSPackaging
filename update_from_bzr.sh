#!/bin/bash

set -e
set -x

BASE=`pwd`
SRC=kicad

if [ ! -d $SRC ]; then
	bzr branch lp:kicad $SRC
fi

cd $SRC
#check to make sure the SRC is actually kicad
if ! bzr info | grep "parent branch: bzr+ssh://bazaar.launchpad.net/+branch/kicad/$"; then
    if ! bzr info | grep "parent branch: http://bazaar.launchpad.net/~kicad-product-committers/kicad/product/$"; then
        echo "$SRC is not KiCad?.  Exiting."
        exit 1 
    fi
fi

echo "Cleaning tree."
bzr clean-tree --verbose --force --ignored --unknown --detritus
bzr revert

echo "Pulling new revisions."
bzr pull

REVNO=`bzr revno`
echo "At r$REVNO"

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

DOCS_DIR=doc
DOCS_BZR=lp:~kicad-developers/kicad/doc
DOCS_BUILD=build-docs

if [ ! -d $DOCS_DIR ]; then
	bzr branch $DOCS_BZR $DOCS_DIR
fi

cd $DOCS_DIR
#check to make sure the DOCS_DIR is really a checkout of $DOCS_BZR

if ! bzr info | grep "branch" | grep "://bazaar.launchpad.net/~kicad-developers/kicad/doc/$"; then
    echo "$DOCS_DIR is not a KiCad docs checkout.  Exiting."
    exit 1
fi

echo "Cleaning tree."
bzr clean-tree --verbose --force --ignored --unknown --detritus
bzr revert
REVNO=`bzr revno`
echo "At r$REVNO"

mkdir -p $BASE/notes
echo "$REVNO" > $BASE/notes/docs_revno
