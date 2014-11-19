#!/bin/bash

set -e
set -x

if [ -d bin ]; then
	rm -r bin
fi

cd build
make install
cd - 
