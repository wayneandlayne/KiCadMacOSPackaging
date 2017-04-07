#!/bin/bash

#most of this is from kicad's script, but mangled for our needs

set -x
set -e

BASE=`pwd`
WORKING_TREES=$BASE/libraries/github


listcontains()
{
    local list=$1
    local item=$2
    local ret=1
    local OIFS=$IFS

    # omit the space character from internal field separator.
    IFS=$'\n'

    for word in $list; do
        if [ "$word" == "$item" ]; then
            ret=0
            break
        fi
    done

    IFS=$OIFS
    return $ret
}

NOW=`date +%Y%m%d-%H%M%S`

mkdir -p $BASE/notes
echo "$NOW" > $BASE/notes/libs_revno

    if [ ! -d "$WORKING_TREES" ]; then
        mkdir -p "$WORKING_TREES"
    fi
    cd $WORKING_TREES

    if [ $(echo | sed -r '' &>/dev/null; echo $?) -eq 0 ]; then
        SED_EREGEXP="-r"
    elif [ $(echo | sed -E '' &>/dev/null; echo $?) -eq 0 ]; then
        SED_EREGEXP="-E"
    else
        echo "Your sed command does not support extended regular expressions. Cannot continue."
        exit 1
    fi

    # Use github API to list repos for org KiCad, then subset the JSON reply for only
    # *.pretty repos

    PRETTY_REPOS=`curl -s "https://api.github.com/orgs/KiCad/repos?per_page=99&page=1" \
        "https://api.github.com/orgs/KiCad/repos?per_page=99&page=2" 2> /dev/null \
        | grep full_name | grep pretty \
        | sed $SED_EREGEXP 's:.+ "KiCad/(.+)",:\1:'`

    #echo "PRETTY_REPOS:$PRETTY_REPOS"

    PRETTY_REPOS=`echo $PRETTY_REPOS | tr " " "\n" | sort`

    if [ ! -e "$WORKING_TREES/library-repos" ]; then
        mkdir -p "$WORKING_TREES/library-repos"
    fi

    for repo in kicad-library $PRETTY_REPOS; do
        # echo "repo:$repo"

        if [ ! -e "$WORKING_TREES/library-repos/$repo" ]; then

            # Preserve the directory extension as ".pretty".
            # That way those repos can serve as pretty libraries directly if need be.

            echo "installing $WORKING_TREES/library-repos/$repo"
            git clone "https://github.com/KiCad/$repo" "$WORKING_TREES/library-repos/$repo"
        else
            echo "updating $WORKING_TREES/library-repos/$repo"
            cd "$WORKING_TREES/library-repos/$repo"
            #In 2015, there ws a Buttons_Switches_SMD.pretty repo that was completely empty
            #didn't have a single branch (not even master) or commit, and git pull fails on that
            git fetch
            if git branch --list | grep master; then
            	git pull
            else
                echo "Warning: Repo $repo doesn't seem to have any upstream work."
            fi
        fi
    done



    echo "Checking for orphaned repos"

    cd $WORKING_TREES/library-repos

    if [ $? -ne 0 ]; then
        echo "Directory $WORKING_TREES/library-repos does not exist."
        echo "The option --remove-orphaned-libraries should be used only after you've run"
        echo "the --install-or-update at least once."
        exit 2
    fi

    for mylib in *.pretty; do
        echo "checking local lib: $mylib"

        if ! listcontains "$PRETTY_REPOS" "$mylib"; then
            echo "Removing orphaned local library $WORKING_TREES/library-repos/$mylib"
            rm -rf "$mylib"
        fi
    done


echo "success updating libraries from github"

cd $BASE

KICAD_LIBRARIES_REPO=$BASE/libraries/github/library-repos/kicad-library

LIBS_BUILD=build-libs

mkdir -p $LIBS_BUILD
cd $LIBS_BUILD
if [ -d output ]; then
    rm -r output;
fi
mkdir -p output
cmake -DCMAKE_INSTALL_PREFIX=output $KICAD_LIBRARIES_REPO
make install

cd $BASE
mkdir -p support

#copy everything into support
cp -r $LIBS_BUILD/output/* support/

#modules is special
if [ -d support/modules/packages3d ]; then
    if [ -d support/packages3d ]; then
        rm -r support/packages3d
    fi
    mv support/modules/packages3d support/
fi

rm -r support/modules

if [ -d extras/modules ]; then
    rm -rf extras/modules
fi

mkdir -p extras/modules

#copy in github footprints into extras/modules
ditto $WORKING_TREES/library-repos extras/modules

#copy in the fp-table-lib for local libraries
cp $KICAD_LIBRARIES_REPO/template/fp-lib-table.for-pretty extras/fp-lib-table
