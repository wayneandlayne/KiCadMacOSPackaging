#!/bin/bash

set -e
set -x

BASE=`pwd`
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

cd -

mkdir -p $DOCS_BUILD
cd $DOCS_BUILD
if [ -d output ]; then
    rm -r output;
fi
mkdir -p output
cmake -DCMAKE_INSTALL_PREFIX=output ../$DOCS_DIR 
make install
cd -


if [ -d support/help ]; then
    rm -r support/help
fi
if [ -d support/internat ]; then
    rm -r support/internat
fi

mkdir -p support

cp -r $DOCS_BUILD/output/share/doc/kicad/help support/
cp -r $DOCS_BUILD/output/share/kicad/internat support/


#copy a few of the essential pdfs into the bundle
HELP_SRC=support/help/en
HELP_DST=bin/kicad.app/Contents/SharedSupport/help/en

if [ -d $HELP_DST ]; then
	rm -r $HELP_DST
fi

mkdir -p $HELP_DST

cp -r $HELP_SRC/* $HELP_DST/.

