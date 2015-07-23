#!/bin/bash

set -e
set -x

#./setup.sh
./update_kicad_from_bzr.sh
./update_docs_from_bzr.sh
./compile_wx.sh
./compile_kicad.py
./install_kicad.sh
./install_docs.sh
./install_libraries.sh
./package_kicad.sh
./package_extras.sh
#cd bin/kicad.app/Contents/MacOS/
#open kicad
