#!/bin/bash

set -e
set -x

BASE=`pwd`
DOCS_BUILD=build-docs

if [ ! -d $DOCS_BUILD/help ]; then
	echo "I am building docs on Linux and copying the files into $DOCS_BUILD."
        echo "Once you put the help files there, rerun this script."
	exit 1
fi

if [ -d support/help ]; then
    rm -r support/help
fi

mkdir -p support

cp -r $DOCS_BUILD//help support/

#copy the essential pdfs into the bundle
HELP_SRC=support/help/en
HELP_DST=bin/kicad.app/Contents/SharedSupport/help/en

if [ -d $HELP_DST ]; then
	rm -r $HELP_DST
fi

mkdir -p $HELP_DST

cp -r $HELP_SRC/* $HELP_DST/.

