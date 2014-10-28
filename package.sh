#!/bin/bash -x

FINAL_DMG=kicad.dmg

if [ "$#" -eq 1 ]; then
  ARG1_NUMBERS=`echo "$1" | grep '^[0-9]*$'`
  if [ -z "$ARG1_NUMBERS" ]; then
    echo "First argument represents bzr revno, and must be completely numeric."
    exit 1
  else
    FINAL_DMG=kicad-r$ARG1_NUMBERS.`date +%Y%d%m-%H%M%S`.dmg
  fi
fi

KICAD_APPS=./bin
PACKAGING_DIR=packaging
TEMPLATE=kicadtemplate.dmg
NEW_DMG=kicad.uncompressed.dmg

MOUNTPOINT=mnt

if [ ! -d $KICAD_APPS ]; then
   echo "Kicad apps directory doesn't appear to exist."
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
cp -r ../$KICAD_APPS/* $MOUNTPOINT/Kicad/.
cp README.template $MOUNTPOINT/README

#Update README
echo "" >> $MOUNTPOINT/README
echo "Build details" >> $MOUNTPOINT/README
echo "=============" >> $MOUNTPOINT/README
echo "Packaged on `date`" >> $MOUNTPOINT/README

hdiutil detach $MOUNTPOINT
rm -r $MOUNTPOINT
rm $FINAL_DMG
hdiutil convert $NEW_DMG  -format UDZO -imagekey zlib-level=9 -o $FINAL_DMG
rm $NEW_DMG
rm $TEMPLATE #it comes from the tar bz2
