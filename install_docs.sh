#!/bin/bash

set -e
set -x

BASE=`pwd`
DOCS_DIR=doc
DOCS_BZR=lp:~kicad-developers/kicad/doc
DOCS_BUILD=build-docs

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

