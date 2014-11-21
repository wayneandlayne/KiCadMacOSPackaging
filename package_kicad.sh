#!/bin/bash

set -x
set -e

FINAL_DMG=kicad.dmg
FINAL_DMG_DEST=../dmg
NOW=`date +%Y%d%m-%H%M%S`
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
    echo "First argument represents KiCad bzr revno, and must be completely numeric."
    exit 1
fi

FINAL_DMG=kicad-r$KICAD_REVNO.$NOW.dmg


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
hdiutil attach $NEW_DMG -noautoopen -mountpoint $MOUNTPOINT

if [ -e $MOUNTPOINT/Kicad ]; then
    rm -r $MOUNTPOINT/Kicad
fi
mkdir -p $MOUNTPOINT/Kicad
rsync -al ../$KICAD_APPS/* $MOUNTPOINT/Kicad/. #must preserve symlinks

#copy in support files
mkdir -p $MOUNTPOINT/kicad
cp -r ../$SUPPORT/* $MOUNTPOINT/kicad/.

cp README.template $MOUNTPOINT/README
if [ -e ../notes/build.log ]; then
    cp ../notes/build.log ../notes/build.$NOW.log
    cp ../notes/build.$NOW.log $MOUNTPOINT/build.$NOW.log
fi

#Update README
echo "" >> $MOUNTPOINT/README
echo "About This Build" >> $MOUNTPOINT/README
echo "================" >> $MOUNTPOINT/README
echo "Packaged on $NOW" >> $MOUNTPOINT/README
echo "KiCad revision: r$KICAD_REVNO" >> $MOUNTPOINT/README

if [ -f ../notes/cmake_settings ]; then 
    echo "KiCad CMake Settings: `cat ../notes/cmake_settings`" >> $MOUNTPOINT/README
fi

if [ -f ../notes/kicad_patches ]; then
    echo "KiCad patched with following patches:" >> $MOUNTPOINT/README
    cat ../notes/kicad_patches >> $MOUNTPOINT/README
fi

if [ -f ../notes/docs_revno ]; then
    echo "Docs revision: r`cat ../notes/docs_revno`" >> $MOUNTPOINT/README
fi

if [ -f ../notes/docs_revno ]; then
    echo "Libraries revision: r`cat ../notes/libs_revno`" >> $MOUNTPOINT/README
fi

if [ -f ../notes/build_revno ]; then
    echo "Build script revision: r`cat ../notes/build_revno`" >> $MOUNTPOINT/README
fi

if bzr revno; then
    echo "Packaging script revision: r`bzr revno`" >> $MOUNTPOINT/README
fi

cp $MOUNTPOINT/README ../notes/ #So we can archive the generated README outside of the DMG as well



hdiutil detach $MOUNTPOINT
rm -r $MOUNTPOINT
if [ -e $FINAL_DMG ] ; then
    rm -r $FINAL_DMG
fi

#set it so it autoopens on download/mount
hdiutil attach $NEW_DMG -noautoopen -mountpoint /Volumes/KiCad
bless /Volumes/Kicad --openfolder /Volumes/KiCad
hdiutil detach /Volumes/Kicad


#compress it
#hdiutil convert $NEW_DMG  -format UDBZ -imagekey -o $FINAL_DMG #bzip2 based is a little bit smaller, but opens much, much slower.  
hdiutil convert $NEW_DMG  -format UDZO -imagekey zlib-level=9 -o $FINAL_DMG #This used zlib, and bzip2 based (below) is slower but more compression
rm $NEW_DMG
rm $TEMPLATE #it comes from the tar bz2


mkdir -p $FINAL_DMG_DEST
mv $FINAL_DMG $FINAL_DMG_DEST/.
