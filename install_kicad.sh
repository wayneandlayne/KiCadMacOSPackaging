#!/bin/bash

set -e
set -x

if [ -d bin ]; then
	rm -r bin
fi

cd build
make install
cd - 

#cleanup after kicad
mkdir -p support
mv bin/freeroute.jnlp support/
mv bin/demos support/
rm -r bin/doc #we do not have scripting support yet
