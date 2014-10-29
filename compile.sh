#!/bin/bash

NUM_OF_CORES=3
CMAKE_SETTINGS="-DCMAKE_C_COMPILER=`which clang` -DCMAKE_CXX_COMPILER=`which clang++` -DwxWidgets_CONFIG_EXECUTABLE=../wx-bin/bin/wx-config -DKICAD_SCRIPTING=OFF -DKICAD_SCRIPTING_MODULES=OFF -DKICAD_SCRIPTING_WXPYTHON=OFF -DCMAKE_INSTALL_PREFIX=../bin -DCMAKE_BUILD_TYPE=Release"

run_cmake() {
	mkdir -p build
	cd build
	cmake ../kicad $CMAKE_SETTINGS
	cd -
}

build_kicad() {
	echo "Building KiCad."
	mkdir -p build
	cd build
	make -j$NUM_OF_CORES || exit 1
}

run_cmake
build_kicad
mkdir -p conf
echo "$CMAKE_SETTINGS" > conf/cmake_settings
