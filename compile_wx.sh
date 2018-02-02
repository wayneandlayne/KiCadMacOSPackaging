#!/bin/bash

NUM_OF_CORES=7

WX_SRC_URL="http://downloads.sourceforge.net/project/wxpython/wxPython/3.0.2.0/wxPython-src-3.0.2.0.tar.bz2?r=http%3A%2F%2Fwww.wxpython.org%2Fdownload.php&ts=1425049283&use_mirror=iweb"
WX_SRC_NAME=wxPython-src-3.0.2.0.tar.bz2
WX_SRC_ORIG_DIR=wxpython-src-orig
WX_FORK_DIR=wxWidgets
WX_FORK_BRANCH=kicad/macos-wx-3.0


check_wx_download() {
	if [ ! -f $WX_SRC_NAME ]; then
		echo "Downloading $WX_SRC_NAME"
		wget -O $WX_SRC_NAME $WX_SRC_URL
	else
		echo "Skipping $WX_SRC_NAME download because it is already here."
	fi

        if [ ! -d $WX_FORK_DIR ]; then
                echo "Downloading the wxwidgets fork"
		git clone --recurse-submodules -b $WX_FORK_BRANCH https://github.com/KiCad/wxWidgets.git
	else
		cd $WX_FORK_DIR
		git fetch
		if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
			echo "Updating the wxwidgets fork"
			git pull origin $WX_FORK_BRANCH
			cd -
			rm -r wx-bin
		else
			echo "No update of wxwidgets fork"
			cd -
		fi
        fi
}

check_wx_orig() {
	if [ ! -d $WX_SRC_ORIG_DIR ]; then
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

check_wxpython_mashing() {
        cd $WX_FORK_DIR
        if [ ! -d wxPython ]; then
                cp -r ../$WX_SRC_ORIG_DIR/wxPython .
        fi
        rm -r ../$WX_SRC_ORIG_DIR
        cd -
}

check_wx_build() {
        mkdir -p wx
        cd wx
	check_wx_download
	if [ -d wx-bin ]; then
		echo "Skipping building wx-build because wx-bin exists."
	else
                check_wx_orig
                check_wxpython_mashing
		if [ -d wx-build ]; then
			rm -r wx-build
		fi
		mkdir wx-build
		cd wx-build
		export MAC_OS_X_VERSION_MIN_REQUIRED=10.9
		../$WX_FORK_DIR/configure \
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
            cd $WX_FORK_DIR/wxPython

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
