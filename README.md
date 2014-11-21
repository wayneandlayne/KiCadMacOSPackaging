This is a set of scripts that Wayne and Layne, LLC uses to provide the nightly and periodic Mac OS X releases of KiCad.

Some of the things in here that "look weird" are so it works well in our Jenkins cluster.

Goals
=====
1) Users should be able to browse the included help without going inside a bundle.  This is important so they can do things like put the documentation on their tablets or print some of it out.
2) The help menu items should work, even if only Kicad.app is around.  (If you can see the help menu item, it should work!)

	To support this, the essential PDFs, in English, are included in Kicad.app/Contents/Shared\ Support/help.  The documentation search path is ~/Libraries/Application Support/kicad/help, /Libraries/Application Support/kicad/help, then inside the Kicad.app bundle at Contents/Shared\ Support/help.  The downloadable DMG has the documentation in all the languages, and it has users put the documentation in /Libraries/Application Support/kicad/help.

3) Github footprints should be default.

	To support this, KIGITHUB is set in Kicad.app.

4) Users should be able to easily get all the official footprints and switch to "local hard drive only mode." This is important because users may work offline.

	To support this, I have set up a kicad-footprints (TODO Find right name) .dmg.

5) If the user downloaded our release from a website, it should be a "drag and drop" .dmg, and not a .pkg.  This is important because many users don't like downloaded .pkg installers.

Future Goals
============
* Scripting support should be included.  This includes the actual scripting support, as well as documentation on how to use it, and any example scripts we want to include.
* The "stable" Kicad releases should be included on the Mac App Store.  This will require a .pkg and payment of a yearly fee.  Wayne and Layne can certainly pay the fee, and I do not think the package is a technical difficulty.  This would mean that we can aim "normal users" at the Mac App Store to get the latest stable release.

DMG Layout
==========
When a user first downloads Kicad, they probably don't have /Library/Application Support/kicad, but they will have /Library/Application Support.  They probably don't have ~/Library/Application Support/ and they almost certainly don't have ~/Library/Application Support/kicad.

