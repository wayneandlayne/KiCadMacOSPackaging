#!/bin/bash

NUM_OF_CORES=6
source cmake_settings
SRC=kicad

run_cmake() {
	mkdir -p build
	cd build
	cmake $CMAKE_SETTINGS ../$SRC
	cd -
}

build_kicad() {
	echo "Building KiCad."
	mkdir -p build
	cd build
	make -j$NUM_OF_CORES || exit 1
        cd -
}

run_cmake
build_kicad
echo "$CMAKE_SETTINGS" > notes/cmake_settings
