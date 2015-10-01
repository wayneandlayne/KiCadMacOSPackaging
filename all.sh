#!/bin/bash

set -e
set -x

./setup.sh
./update_kicad.sh
./compile_wx.sh
./compile_kicad.py
./install_kicad.sh
./install_docs.sh
./install_libraries.sh
./update_install_translations.sh
./package_kicad.sh
./package_extras.sh
#cd bin/kicad.app/Contents/MacOS/
#open kicad
