#!/bin/bash -x

FINAL_DMG=kicad.dmg
NOW=`date +%Y%d%m-%H%M%S`
KICAD_REVNO=0

if [ "$#" -eq 1 ]; then
  KICAD_REVNO=`echo "$1" | grep '^[0-9]*$'`
  if [ -z "$KICAD_REVNO" ]; then
    echo "First argument represents KiCad bzr revno, and must be completely numeric."
    exit 1
  else
    FINAL_DMG=kicad-r$KICAD_REVNO.$NOW.dmg
  fi
else
  echo "First argument (KiCad bzr revno) missing."
  exit 1
fi

KICAD_APPS=./bin
PACKAGING_DIR=packaging
TEMPLATE=kicadtemplate.dmg
NEW_DMG=kicad.uncompressed.dmg

MOUNTPOINT=mnt

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
rm -r $MOUNTPOINT
mkdir -p $MOUNTPOINT
hdiutil attach $NEW_DMG -noautoopen -mountpoint $MOUNTPOINT

rm -r $MOUNTPOINT/Kicad
mkdir -p $MOUNTPOINT/Kicad
rsync -al ../$KICAD_APPS/* $MOUNTPOINT/Kicad/.
cp README.template $MOUNTPOINT/README
cp ../build.log $MOUNTPOINT/build.$NOW.log
mv ../build.log ../build.$NOW.log

#Update README
echo "" >> $MOUNTPOINT/README
echo "About This Build" >> $MOUNTPOINT/README
echo "================" >> $MOUNTPOINT/README
echo "KiCad revision: r$KICAD_REVNO" >> $MOUNTPOINT/README
echo "Packaged on $NOW" >> $MOUNTPOINT/README

if bzr revno; then
    echo "Packaging script revision: r`bzr revno`" >> $MOUNTPOINT/README
fi

if [ -f ../conf/build_revno ]; then
    echo "Build script revision: r`cat ../conf/build_revno`" >>$MOUNTPOINT/README
fi

if [ -f ../conf/cmake_settings ]; then 
    source ../conf/cmake_settings
    echo "CMake Settings: $CMAKE_SETTINGS" >> $MOUNTPOINT/README
fi

if [ -d ../docs ]; then
    cp -r ../docs/* docs/.
fi

cp $MOUNTPOINT/README ../ #So we can archive the generated README outside of the DMG as well

hdiutil detach $MOUNTPOINT
rm -r $MOUNTPOINT
rm $FINAL_DMG
hdiutil convert $NEW_DMG  -format UDZO -imagekey zlib-level=9 -o $FINAL_DMG
rm $NEW_DMG
rm $TEMPLATE #it comes from the tar bz2
mv $FINAL_DMG ../
