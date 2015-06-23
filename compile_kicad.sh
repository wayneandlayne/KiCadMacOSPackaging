#!/bin/bash

set -e
set -x

NUM_OF_CORES=6
source cmake_settings
SRC=kicad
REVNO=`bzr revno`

run_cmake() {
	mkdir -p build
	cd build
	cmake "${CMAKE_CONFIG[@]}" ../$SRC
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

if [ -f notes/cmake_settings ]; then
  rm notes/cmake_settings
fi

#for i in ${CMAKE_CONFIG[@]}; do
#   echo '${i}' >> notes/cmake_settings
#done

echo "${CMAKE_CONFIG[@]}" > notes/cmake_settings

echo "$REVNO" > notes/build_revno

