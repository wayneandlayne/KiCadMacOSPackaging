#!/bin/bash

set -x
set -e

FINAL_DMG=kicad.dmg
FINAL_DMG_DEST=../dmg
NOW=`date +%Y%m%d-%H%M%S`
KICAD_REVNO=abc 
KICAD_APPS=./bin
SUPPORT=./support
PACKAGING_DIR=packaging
TEMPLATE=kicadtemplate.dmg
NEW_DMG=kicad.uncompressed.dmg
MOUNTPOINT=mnt

if [ "$#" -eq 1 ]; then
  KICAD_REVNO=$1
elif [ -e notes/kicad_revno ]; then
  KICAD_REVNO=`cat notes/kicad_revno`
fi
  
if [ -z "$KICAD_REVNO" ]; then
    echo "First argument represents KiCad revno, and must be completely numeric."
    exit 1
fi

FINAL_DMG=kicad-$NOW.$KICAD_REVNO-c4osx.dmg


if [ ! -d $KICAD_APPS ]; then
   echo "KiCad apps directory doesn't appear to exist."
   exit 1
fi

if [ ! -d $KICAD_APPS/Kicad.app ]; then
   echo "Kicad.app doesn't appear to exist in the $KICAD_APPS directory"
   exit 1
fi

cd $PACKAGING_DIR
tar xf $TEMPLATE.tar.bz2
cp $TEMPLATE $NEW_DMG
if [ -e $MOUNTPOINT ]; then
    rm -r $MOUNTPOINT
fi
mkdir -p $MOUNTPOINT
hdiutil resize -size 5G $NEW_DMG
hdiutil attach $NEW_DMG -noautoopen -mountpoint $MOUNTPOINT

if [ -e $MOUNTPOINT/Kicad ]; then
    rm -r $MOUNTPOINT/Kicad
fi
mkdir -p $MOUNTPOINT/Kicad
rsync -al ../$KICAD_APPS/* $MOUNTPOINT/Kicad/. #must preserve symlinks

#update background
cp background.png $MOUNTPOINT/.
#rehide background file
SetFile -a V $MOUNTPOINT/background.png

#copy in support files
mkdir -p $MOUNTPOINT/kicad
cp -r ../$SUPPORT/* $MOUNTPOINT/kicad/.


#support/modules is in the base package
#extras/modules is in the extras package
#packages3d is going to move, probably, after 4.0.0, but
#right now, due to OSX packaging stuff, we put it parallel to
#modules, not inside modules

#this causes a problem with defaults, and changing the default
#was ugly, so we're going to do something way, way uglier here
# we are going to make modules, and put a symlink to ../packages3d there
# and we are going to do it inside of extras/modules too.
mkdir -p $MOUNTPOINT/kicad/modules
cd $MOUNTPOINT/kicad/modules
ln -s ../packages3d
echo "KiCad uses footprints from Github.  These have been packaged for offline use, and can be added using the kicad-extras dmg at https://download.kicad-pcb.org/osx" > README
cd -

cp README.template $MOUNTPOINT/README.txt
if [ -e ../notes/build.log ]; then
    cp ../notes/build.log ../notes/build.$NOW.log
    cp ../notes/build.$NOW.log $MOUNTPOINT/build.$NOW.log
fi

#Update README
echo "" >> $MOUNTPOINT/README.txt
echo "About This Build" >> $MOUNTPOINT/README.txt
echo "================" >> $MOUNTPOINT/README.txt
echo "Packaged on $NOW" >> $MOUNTPOINT/README.txt
echo "KiCad revision: r$KICAD_REVNO" >> $MOUNTPOINT/README.txt

if [ -f ../notes/cmake_settings ]; then 
    echo "KiCad CMake Settings: `cat ../notes/cmake_settings`" >> $MOUNTPOINT/README.txt
fi

if [ -f ../notes/kicad_patches ]; then
    echo "KiCad patched with following patches:" >> $MOUNTPOINT/README.txt
    cat ../notes/kicad_patches >> $MOUNTPOINT/README.txt
fi

if [ -f ../notes/docs_revno ]; then
    echo "Docs revision: r`cat ../notes/docs_revno`" >> $MOUNTPOINT/README.txt
fi

if [ -f ../notes/docs_revno ]; then
    echo "Libraries revision: r`cat ../notes/libs_revno`" >> $MOUNTPOINT/README.txt
fi

if [ -f ../notes/build_revno ]; then
    echo "Build script revision: r`cat ../notes/build_revno`" >> $MOUNTPOINT/README.txt
fi

if bzr revno; then
    echo "Packaging script revision: r`bzr revno`" >> $MOUNTPOINT/README.txt
fi

cp $MOUNTPOINT/README.txt ../notes/README #So we can archive the generated README outside of the DMG as well



hdiutil detach $MOUNTPOINT
rm -r $MOUNTPOINT
if [ -e $FINAL_DMG ] ; then
    rm -r $FINAL_DMG
fi

#set it so it autoopens on download/mount
hdiutil attach $NEW_DMG -noautoopen -mountpoint /Volumes/KiCad
bless /Volumes/KiCad --openfolder /Volumes/KiCad
#umount /Volumes/KiCad
hdiutil detach /Volumes/KiCad

#compress it
#hdiutil convert $NEW_DMG  -format UDBZ -imagekey -o $FINAL_DMG #bzip2 based is a little bit smaller, but opens much, much slower.  
hdiutil convert $NEW_DMG  -format UDZO -imagekey zlib-level=9 -o $FINAL_DMG #This used zlib, and bzip2 based (above) is slower but more compression
rm $NEW_DMG
rm $TEMPLATE #it comes from the tar bz2


mkdir -p $FINAL_DMG_DEST
mv $FINAL_DMG $FINAL_DMG_DEST/.
