#!/bin/bash

NUM_OF_CORES=7

WX_SRC_URL="http://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2?r=http%3A%2F%2Fwww.wxpython.org%2Fdownload.php&ts=1425049283&use_mirror=iweb"
WX_SRC_NAME=wxPython-src-3.0.2.0.tar.bz2
WX_SRC_ORIG_DIR=wxpython-src-orig

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
		patch -p0 < ../../wx_patches/wxwidgets-3.0.0_macosx.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.0_macosx_bug_15908.patch || exit 1 
		patch -p0 < ../../wx_patches/wxwidgets-3.0.0_macosx_soname.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.2_macosx_yosemite.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.0_macosx_scrolledwindow.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.2_macosx_retina_opengl.patch || exit 1
		patch -p0 < ../../wx_patches/wxwidgets-3.0.2_macosx_magnify_event.patch || exit 1
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
		export MAC_OS_X_VERSION_MIN_REQUIRED=10.9
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
		      --with-macosx-version-min=10.9 \
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
        cd ..
}

check_wxpython_build() {
    cd wx
    if [ -d wx-bin/lib/python2.7/site-packages ]; then
        echo "Skipping building wxPython because lib/python2.7/sitepackages exists."
    else
            cd  wx-src/wxPython
    
            export MAC_OS_X_VERSION_MIN_REQUIRED=10.9
            # build params
            WXPYTHON_BUILD_OPTS="WX_CONFIG=`pwd`/../../wx-bin/bin/wx-config \
            BUILD_BASE=`pwd`/../../wx-build \
            UNICODE=1 \
            WXPORT=osx_cocoa"

            WXPYTHON_PREFIX="--prefix=`pwd`/../../wx-bin"
	    python setup.py build_ext $WXPYTHON_BUILD_OPTS
	if [ $? == 0 ]; then
    	# install
	    python setup.py install $WXPYTHON_PREFIX $WXPYTHON_BUILD_OPTS
	else
    	    cd -
       	    exit 1
        fi
    fi
    cd -
}


check_wx_build
check_wxpython_build
