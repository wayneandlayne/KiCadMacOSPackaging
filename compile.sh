#!/bin/bash

NUM_OF_CORES=3
source cmake_settings

run_cmake() {
	mkdir -p build
	cd build
	cmake $CMAKE_SETTINGS ../kicad
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
