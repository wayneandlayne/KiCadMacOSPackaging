#!/bin/bash

set -e
set -x

if [ -d notes ]; then
	rm -r notes
fi
mkdir -p notes

if [ -d build ]; then
	rm -r build
fi

if [ -d build-docs ]; then
	rm -r build-docs
fi

if [ -d build-libs ]; then
	rm -r build-libs
fi

if [ -d bin ]; then
	rm -r bin
fi

if [ -d support ]; then
	rm -r support
fi

if [ -d extras ]; then
	rm -r extras
fi
