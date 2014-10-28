#!/bin/bash

NUM_OF_CORES=3

#TODO: add licensing
#TODO: add command line arguments
#TODO: stop hardcoding the mirror
#TODO: don't update from KiCad upstream everytime
#TODO: add command line arguments

print_banner() {
	echo "This script builds KiCad from source on OS X.  This script helps you follow the instructions at https://bazaar.launchpad.net/~kicad-product-committers/kicad/product/view/head:/Documentation/compiling/mac-osx.txt to build KiCad for OS X."
	echo "Soon, there will be 'stable releases', so it'll be easier to just download binaries if you have no interest in building them."
	sleep 1
}


run_cmake() {
	mkdir -p build
	cd build
	cmake ../kicad \
		-DCMAKE_C_COMPILER=`which clang` \
		-DCMAKE_CXX_COMPILER=`which clang++` \
		-DwxWidgets_CONFIG_EXECUTABLE=../wx-bin/bin/wx-config \
		-DKICAD_SCRIPTING=OFF \
		-DKICAD_SCRIPTING_MODULES=OFF \
		-DKICAD_SCRIPTING_WXPYTHON=OFF \
		-DCMAKE_INSTALL_PREFIX=../bin \
		-DCMAKE_BUILD_TYPE=Release
	cd -
}

build_kicad() {
	echo "Building KiCad."
	mkdir -p build
	cd build
	make -j$NUM_OF_CORES
	if [ $? != 0 ]; then
		echo "Trying to rebuild one more time, without parallelism."
		make
		if [ $? != 0 ]; then
			echo "Build error while compiling KiCad.  Exiting."
			cd -
			exit 1
		fi
	fi
	#if you got here, make returned exit code 0
	mkdir -p ../bin
	make install
	cd -
}

run_cmake
build_kicad
