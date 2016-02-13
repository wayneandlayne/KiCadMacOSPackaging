#!/bin/bash

set -e
set -x

BASE=`pwd`
I18N_DIR=i18n
I18N_GIT=https://github.com/KiCad/kicad-i18n.git
I18N_BUILD=build-i18n

if [ ! -d $I18N_DIR ]; then
	git clone $I18N_GIT $I18N_DIR
else
	cd $I18N_DIR
	git checkout master
	git pull
	cd -
fi

mkdir -p $I18N_BUILD
cd $I18N_BUILD
if [ -d output ]; then
    rm -r output;
fi
mkdir -p output
cmake -DCMAKE_INSTALL_PREFIX=output ../$I18N_DIR
make install
cd -


if [ -d support/internat ]; then
    rm -r support/internat
fi

mkdir -p support
mkdir -p support/share
cp -r $I18N_BUILD/output/share/kicad/internat support/share/
