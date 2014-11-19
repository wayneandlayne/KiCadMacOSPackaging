#!/bin/bash

set -e
set -x

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
	PATCH_RESULTS=`bzr patch --help 2>&1`
	if echo $PATCH_RESULTS | grep 'ERROR: unknown command "patch"' > /dev/null; then
		echo "bzr patch doesn't appear to work."
		echo "Installing bzrtools to ~/.bazaar/plugins"
    		wget -O /tmp/bzrtools.tar.gz https://launchpad.net/bzrtools/stable/2.6.0/+download/bzrtools-2.6.0.tar.gz
    		mkdir -p ~/.bazaar/plugins/
		echo "Extracting bzrtools to bzr's plugins directory."
    		tar zxf /tmp/bzrtools.tar.gz -C ~/.bazaar/plugins/
		PATCH_RESULTS=`bzr patch --help 2>&1`
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

check_compiler
check_brew
check_brew_depends
check_bzrtools
