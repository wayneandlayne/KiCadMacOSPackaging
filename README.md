KiCadMacOSPackaging
===================

This is a set of scripts that provide the nightly and periodic Mac OS X releases of KiCad.

Some of the things in here that "look weird" are so it works well in our Jenkins cluster.

This has lived in bzr over at https://code.launchpad.net/~adamwolf/+junk/kicad-mac-packaging for a while, but is being moved here to Github.

Usage
=====

tktktk

Goals
=====
1) Users should be able to browse the included help without going inside a bundle.  This is important so they can do things like put the documentation on their tablets or print some of it out.

2) The help menu items should work, even if only Kicad.app is around.  (If you can see the help menu item, it should work!)

3) Github footprints should be default.

4) Users should be able to easily get all the official footprints and switch to "local hard drive only mode." This is important because users may work offline.

5) If the user downloaded our release from a website, it should be a "drag and drop" .dmg, and not a .pkg.  This is important because many users don't like downloaded .pkg installers.

Future Goals
============
* Write a good usage section here, and link to the KiCad Jenkins that builds this, if that is public.
* This script should be linted and built on a fresh MacOS VM before PRs here are accepted.
* Scripting support (like the interactive internal terminal) should be revamped to have Python included in the bundle, per Apple.  This is in progress.
* Scripting support (like pcbnew.so) should work.  Metacollin made some amazing progress on this and that needs to be included.
* When this script started, homebrew did an OK job at building dependencies that are distributable.  Now, they explicitly say *not* to use brew to build distributable packages.  We should build all our dependencies, or provide an option to do that.  This is in progress.
* It should be easy to use this to test different builds and provide them to users.  This is in progress.
