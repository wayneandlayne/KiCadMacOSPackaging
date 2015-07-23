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
