#!/bin/bash
#package_extras.sh

set -x
set -e

FINAL_DMG=kicad.dmg
FINAL_DMG_DEST=../dmg
NOW=`date +%Y%m%d-%H%M%S`
REVNO=abc 
EXTRAS=extras
PACKAGING_DIR=extras_packaging
TEMPLATE=kicad-extras-template.dmg
NEW_DMG=kicad-extras-template.uncompressed.dmg
MOUNTPOINT=mnt

if [ "$#" -eq 1 ]; then
  REVNO=$1
elif [ -e notes/libs_revno ]; then
  REVNO=`cat notes/libs_revno`
fi
  
if [ -z "$REVNO" ]; then
    echo "First argument represents bzr revno, and must be completely numeric."
    exit 1
fi

FINAL_DMG=kicad-extras.$NOW-c4osx.dmg

cd $PACKAGING_DIR
tar xf $TEMPLATE.tar.bz2
cp $TEMPLATE $NEW_DMG
if [ -e $MOUNTPOINT ]; then
    rm -r $MOUNTPOINT
fi
mkdir -p $MOUNTPOINT
hdiutil attach $NEW_DMG -noautoopen -mountpoint $MOUNTPOINT

if [ -e $MOUNTPOINT/modules ]; then
    rm -r $MOUNTPOINT/modules
fi

cp -r ../$EXTRAS/* $MOUNTPOINT/.


#support/modules is in the base package
#extras/modules is in the extras package
#packages3d is going to move, probably, after 4.0.0, but
#right now, due to OSX packaging stuff, we put it parallel to
#modules, not inside modules

#this causes a problem with defaults, and changing the default
#was ugly, so we're going to do something way, way uglier here
# we are going to make modules, and put a symlink to ../packages3d there
# and we are going to do it inside of extras/modules too.
cd $MOUNTPOINT/modules/
ln -s ../packages3d
cd -


#update background
cp background.png $MOUNTPOINT/.
#rehide background file
SetFile -a V $MOUNTPOINT/background.png

cp README.template $MOUNTPOINT/README.txt

#Update README
echo "" >> $MOUNTPOINT/README.txt
echo "About This Build" >> $MOUNTPOINT/README.txt
echo "================" >> $MOUNTPOINT/README.txt
echo "Packaged on $NOW" >> $MOUNTPOINT/README.txt
echo "Github libraries copied on: r$REVNO" >> $MOUNTPOINT/README.txt

if [ -f ../notes/build_revno ]; then
    echo "Build script revision: r`cat ../notes/build_revno`" >> $MOUNTPOINT/README.txt
fi

if bzr revno; then
    echo "Packaging script revision: r`bzr revno`" >> $MOUNTPOINT/README.txt
fi


hdiutil detach $MOUNTPOINT
rm -r $MOUNTPOINT
if [ -e $FINAL_DMG ] ; then
    rm -r $FINAL_DMG
fi

#set it so it autoopens on download/mount
hdiutil attach $NEW_DMG -noautoopen -mountpoint /Volumes/KiCad\ Extras
bless /Volumes/KiCad\ Extras --openfolder /Volumes/KiCad\ Extras
hdiutil detach /Volumes/KiCad\ Extras

#compress it
#hdiutil convert $NEW_DMG  -format UDBZ -imagekey -o $FINAL_DMG #bzip2 based is a little bit smaller, but opens much, much slower.  
hdiutil convert $NEW_DMG  -format UDZO -imagekey zlib-level=9 -o $FINAL_DMG #This used zlib, and bzip2 based (below) is slower but more compression
rm $NEW_DMG
rm $TEMPLATE #it comes from the tar bz2


mkdir -p $FINAL_DMG_DEST
mv $FINAL_DMG $FINAL_DMG_DEST/.
