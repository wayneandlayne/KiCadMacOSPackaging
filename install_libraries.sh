#!/bin/bash

set -e
set -x

BASE=`pwd`
LIBS_DIR=libraries
LIBS_BZR=lp:~kicad-product-committers/kicad/library
LIBS_BUILD=build-libs

if [ ! -d $LIBS_DIR ]; then
	bzr branch $LIBS_BZR $LIBS_DIR
fi

cd $LIBS_DIR
#check to make sure the DIR is really a checkout of BZR

if ! bzr info | grep "branch" | grep "://bazaar.launchpad.net/~kicad-product-committers/kicad/library/$"; then
    echo "$LIBS_DIR is not a KiCad docs checkout.  Exiting."
    exit 1
fi

echo "Cleaning tree."
bzr clean-tree --verbose --force --ignored --unknown --detritus
REVNO=`bzr revno`
echo "At r$REVNO"

mkdir -p $BASE/notes
echo "$REVNO" > $BASE/notes/libs_revno

cd -

mkdir -p $LIBS_BUILD
cd $LIBS_BUILD
if [ -d output ]; then
    rm -r output;
fi
mkdir -p output
cmake -DCMAKE_INSTALL_PREFIX=output ../$LIBS_DIR 
make install
cd -

mkdir -p support

cp -r $LIBS_BUILD/output/Library/Application\ Support/kicad/* support/
