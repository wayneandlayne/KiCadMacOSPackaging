This is a set of scripts that Wayne and Layne, LLC uses to provide the nightly and periodic Mac OS X releases of KiCad.

Some of the things in here that "look weird" are so it works well in our Jenkins cluster.

I have changed my mind about how these scripts work together, but I am holding off refactoring until after the artifacts are released--or they'll never be posted!

Goals
=====
1) Users should be able to browse the included help without going inside a bundle.  This is important so they can do things like put the documentation on their tablets or print some of it out.

2) The help menu items should work, even if only Kicad.app is around.  (If you can see the help menu item, it should work!)

	To support this, the essential PDFs, in English, are included in Kicad.app/Contents/Shared\ Support/help.  The documentation search path is ~/Libraries/Application Support/kicad/help, /Libraries/Application Support/kicad/help, then inside the Kicad.app bundle at Contents/Shared\ Support/help.  The downloadable DMG has the documentation in all the languages, and it has users put the documentation in /Libraries/Application Support/kicad/help.

3) Github footprints should be default.

	To support this, KIGITHUB is set in Kicad.app.

4) Users should be able to easily get all the official footprints and switch to "local hard drive only mode." This is important because users may work offline.

	To support this, I have set up a kicad-support.dmg.

5) If the user downloaded our release from a website, it should be a "drag and drop" .dmg, and not a .pkg.  This is important because many users don't like downloaded .pkg installers.

Tests
=====

* To install Kicad, double click the kicad dmg.  Drag Kicad into Applications and kicad into Application Support per the background image.  Enter an administrator password if required.

Now, you should be able to 

* open eeschema, click the place button, choose a part, and see it placed

* open kicad, then open eeschema, then click the place button, choose a part, and see it placed.

* open pcbnew, click the place button, select a footprint, see it placed

* open kicad, then open eeschema, then click the place button, choose a part, and see it placed.

You can browse the help files at /Library/Application Support/kicad/help, so you can transfer the files to a mobile device or print them out.  The help inside the tools also use these files.

Additionally, you can browse the help for each tool even if the support files aren't in place.  You can test this by

1) closing any Kicad programs
2) moving /Library/Application Support/kicad and ~/Library/Application Support/kicad out of the way
3) opening each of the tools and opening the help via Help->Contents and Help->getting Started in KiCad.

You can install the footprints locally, so you don't use the Github plugin.  To test that, do the following:

* Download kicad-SOMETHING.dmg.  Double click it, and open it.  Drag the 

Future Goals
============
* Scripting support should be included.  This includes the actual scripting support, as well as documentation on how to use it, and any example scripts we want to include.
* The "stable" Kicad releases should be included on the Mac App Store.  This will require a .pkg and payment of a yearly fee.  Wayne and Layne can pay the fee, and I do not think the package is a technical difficulty.  This would mean that we can aim "normal users" at the Mac App Store to get the latest stable release, and they would get updates, and they wouldn’t have to do any “dragging and dropping”.

DMG Layout
==========
When a user first downloads Kicad, they probably don't have /Library/Application Support/kicad, but they will have /Library/Application Support.  They probably don't have ~/Library/Application Support/kicad.

OS X has a different drag-and-drop mentality than other OSes.  When you drag one directory onto another directory of the same name, the new directory completely replaces the old one.  There is no merge.

Because of this, I am trying to be careful here and thinking of everything in two different situations--a new user without anything from Kicad installed, and also a user updating their system.

We can either put our footprint and module and help files in ~/Library/Application Support/kicad, or in /Library/Application Support/kicad.  Neither one of these directories will exist on a new user's system.

I propose the DMG has a Kicad directory and a drop target of /Applications, with a background to imply dragging Kicad/ to /Applications, and a kicad/ directory with support contents with a drop target of /Library/Application Support.

This is one of the simplest ways I can think of doing it for the new users.  It does require a password for putting the support files in /Library/Application Support, but then there's an obvious place to direct users to put changed support files, (~/Library/Application Support/kicad/) where our default instructions wouldn't clobber them.  This is analogous to installing our files to /usr/local/ and letting users override them easily in their home directory.  In that case, users can install new OS packages without worrying that the modified files in their home directory will be clobbered.

There is nothing preventing a more savvy user with a different situation from ignoring the drop targets in our DMG and putting the applications whereever they want, and putting the support files in ~/Library/Application Support/kicad.  Thisis only a default configuration aimed at helping users who don't know what to do.



    <key>LSEnvironment</key>
    <dict>
        <key>KIGITHUB</key>
        <string>https://github.com/KiCad</string>
    </dict>

