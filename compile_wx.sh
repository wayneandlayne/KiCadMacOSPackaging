#!/bin/bash

NUM_OF_CORES=7

WX_SRC_URL="http://downloads.sourceforge.net/project/wxwindows/3.0.2/wxWidgets-3.0.2.tar.bz2?r=http%3A%2F%2Fwww.wxwidgets.org%2Fdownloads%2F&ts=1412609411&use_mirror=superb-dca2"
WX_SRC_NAME=wxWidgets-3.0.2.tar.bz2
WX_SRC_ORIG_DIR=wx-src-orig

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
		patch -p0 < ../../kicad/patches/wxwidgets-3.0.0_macosx.patch || exit 1
		patch -p0 < ../../kicad/patches/wxwidgets-3.0.0_macosx_bug_15908.patch || exit 1 
		patch -p0 < ../../kicad/patches/wxwidgets-3.0.0_macosx_soname.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.2_macosx_yosemite.patch || exit 1
		patch -p0 < ../../kicad/patches/wxwidgets-3.0.0_macosx_scrolledwindow.patch || exit 1
		cd -
	fi	
}

check_wx_build() {
        mkdir -p wx
        cd wx
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
		      --with-macosx-version-min=10.7 \
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
        cd -
}

check_wx_build
