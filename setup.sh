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
	which brew
	if [ $? -ne 0 ]; then
		echo "It doesn't look like brew is installed."
		echo "You can probably use MacPorts or something, but this script uses brew."
		echo "To install brew, go to http://brew.sh and follow the simple instructions there."
		exit 1
	fi
}

check_brew_depends() {
	echo "Installing dependencies."
	check_brew
        if ! brew list gettext cmake doxygen wget glew cairo openssl > /dev/null; then
            brew install --build-bottle gettext swig pixman  cmake doxygen wget glew cairo openssl #build-bottle is so it builds for the oldest mac CPU supported by homebrew, which is probably ok for us

	# You also need git, but if you have brew, you have git.
        fi
}

check_compiler
check_brew
check_brew_depends
