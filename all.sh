#!/bin/bash

set -e
set -x

#./setup.sh
#./update_kicad.sh
#./compile_wx.sh
./compile_kicad.sh
./install_kicad.sh
./install_docs.sh
./install_libraries.sh
./package_kicad.sh
./package_extras.sh

