#!/bin/bash

NUM_OF_CORES=3

WX_SRC_URL="http://downloads.sourceforge.net/project/wxwindows/3.0.2/wxWidgets-3.0.2.tar.bz2?r=http%3A%2F%2Fwww.wxwidgets.org%2Fdownloads%2F&ts=1412609411&use_mirror=superb-dca2"
WX_SRC_NAME=wxWidgets-3.0.2.tar.bz2
WX_SRC_ORIG_DIR=wx-src-orig

#TODO: add licensing
#TODO: add command line arguments
#TODO: stop hardcoding the mirror
#TODO: don't update from KiCad upstream everytime
#TODO: add command line arguments

print_banner() {
	echo "This script helps you follow the instructions at https://bazaar.launchpad.net/~kicad-product-committers/kicad/product/view/head:/Documentation/compiling/mac-osx.txt to build KiCad for OS X."
	echo "Soon, there will be 'stable releases', so it'll be easier to just download binaries if you have no interest in building them."
	sleep 1
}


check_compiler() {
	echo "Looking for XCode's CLI compiler."
	if [ ! -e /Library/Developer/CommandLineTools/usr/bin/clang ]; then
		echo "Unable to detect XCode's CLI compiler.  Click Install on the popup to install it from Apple."
		xcode-select --install
	fi
}

check_brew() {
	if [ ! -e /usr/local/bin/brew ]; then
		echo "It doesn't look like brew is installed."
		echo "You can probably use MacPorts or something, but this script uses brew."
		echo "To install brew, go to http://brew.sh and follow the simple instructions there."
		exit 1
	fi
}

check_brew_depends() {
	echo "Installing dependencies."
	check_brew
	brew install bzr cmake doxygen wget
	brew install glew cairo
	brew install openssl
}

check_bzrtools() {
	echo "Testing for bzrtools (patch command)"
	PATCH_RESULTS=`bzr patch 2>&1`
	if echo $PATCH_RESULTS | grep 'ERROR: unknown command "patch"' > /dev/null; then
		echo "bzr patch doesn't appear to work."
		echo "Installing bzrtools to ~/.bazaar/plugins"
    		wget -O /tmp/bzrtools.tar.gz https://launchpad.net/bzrtools/stable/2.6.0/+download/bzrtools-2.6.0.tar.gz
    		mkdir -p ~/.bazaar/plugins/
		echo "Extracting bzrtools to bzr's plugins directory."
    		tar zxf /tmp/bzrtools.tar.gz -C ~/.bazaar/plugins/
		PATCH_RESULTS=`bzr patch 2>&1`
		if echo $PATCH_RESULTS | grep 'ERROR: unknown command "patch"' > /dev/null; then
			echo "bzr patch still doesn't appear to work.  Exiting!"
			exit 1
		else
			echo "bzr patch installed."
		fi
	else
		echo "bzr patch appears to work."
	fi
}


check_wx_download() {
	if [ ! -f $WX_SRC_NAME ]; then
		echo "Downloading $WX_SRC_NAME"
		wget -O $WX_SRC_NAME $WX_SRC_URL
	else
		echo "Skipping $WX_SRC_NAME download because it is already here."
	fi
}

check_wx_orig() {
	if [ ! -d $WX_SRC_ORIG_DIR ]; then
		check_wx_download
		echo "Extracting $WX_SRC_NAME into $WX_SRC_ORIG_DIR"
		mkdir $WX_SRC_ORIG_DIR
		cd $WX_SRC_ORIG_DIR
		tar xf ../$WX_SRC_NAME
		outerdir=`ls -1`
		mv */* .
		rm -r $outerdir
		cd -
	else
		echo "Skipping the extraction of $WX_SRC_NAME into $WX_SRC_ORIG_DIR as $WX_SRC_ORIG_DIR exists."
	fi
}

check_wx_patched() {
	if [ -d wx-src ]; then
		echo "Skipping the patching of wx-src because wx-src exists."
	else
		check_wx_orig
		cp -r $WX_SRC_ORIG_DIR wx-src
		cd wx-src
		patch -p0 < ../kicad/patches/wxwidgets-3.0.0_macosx.patch
		patch -p0 < ../kicad/patches/wxwidgets-3.0.0_macosx_bug_15908.patch
		patch -p0 < ../kicad/patches/wxwidgets-3.0.0_macosx_soname.patch
		patch -p0 < ../patches/patch-webview_webkit.mm.diff
		cd -
	fi	
}

check_wx_build() {
	if [ -d wx-bin ]; then
		echo "Skipping building wx-build because wx-bin exists."
	else
		check_wx_patched
		if [ -d wx-build ]; then
			rm -r wx-build
		fi
		mkdir wx-build
		cd wx-build
		../wx-src/configure \
		      --prefix=`pwd`/../wx-bin \
		      --with-opengl \
		      --enable-aui \
		      --enable-utf8 \
		      --enable-html \
		      --enable-stl \
		      --with-libjpeg=builtin \
		      --with-libpng=builtin \
		      --with-regex=builtin \
		      --with-libtiff=builtin \
		      --with-zlib=builtin \
		      --with-expat=builtin \
		      --without-liblzma \
		      --with-macosx-version-min=10.5 \
		      --enable-universal-binary=i386,x86_64 \
		      CPPFLAGS="-stdlib=libstdc++" \
		      LDFLAGS="-stdlib=libstdc++" \
		      CC=clang \
		      CXX=clang++
		make -j$NUM_OF_CORES
		if [ $? == 0 ]; then 
			mkdir ../wx-bin
			make install
			cd -
		else
			cd -
			exit 1
		fi
	fi	
}

check_kicad() {
	if [ ! -d kicad ]; then
		echo "Checking out KiCad source.  This is going to take a while."
		bzr branch lp:kicad
	fi
	cd kicad
	echo "Updating KiCad"
	bzr pull
	echo -n "Getting the current revision: "
	REVNO=`bzr revno`
	echo "$REVNO"
	echo "Cleaning source tree."
	bzr clean-tree --verbose --force --ignored --unknown --detritus
	cd -
}

print_banner
check_compiler
#check_brew
#check_brew_depends
check_bzrtools
check_kicad
check_wx_build
