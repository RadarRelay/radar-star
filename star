#!/usr/bin/env bash

STAR_PKG_LOC="/usr/local/opt/star-pkg"
STAR_PKG_REPO="git@github.com:RadarRelay/star-pkg.git"

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

install () {
    mkdir $STAR_PKG_LOC
}

uninstall() {
    rm -rf $STAR_PKG_LOC
}

checkforupdate () {
    if [ -z ${STAR_NO_UPDATE+x} ]
    then
        if [ ! -d $STAR_PKG_LOC ]
        then
            echo "star-pkg isn't installed, installing from ${STAR_PKG_REPO}"
            git clone --depth 1 $STAR_PKG_REPO $STAR_PKG_LOC
        fi
        pushd $STAR_PKG_LOC
            git pull --quiet origin master
        popd
    else
        # VAR not set so don't attempt to update
        echo "Won't update"
    fi
}

usage () {
    echo "$0 usage:"
    echo "$0 <command>    execute the given command and arguments"
    echo "$0 uninstall    uninstall the star-pkg repository"
}

checkforupdate

if [ $# -eq 0 ]
then
    usage
elif [ $# -eq 1 ] && [ $1 == "uninstall" ]
then
    uninstall
    if [ $? -eq 0 ]
    then
        echo "Uninstalled star-pkg, please note that you'll need to uninstall this tool as well."
    else
        echo "Something went wrong trying to uninstall star-pkg"
    fi
elif [ $# -ge 1 ]
then
    if [ -f "$STAR_PKG_LOC/$1" ]
    then
        CMD=$1
        shift
        $STAR_PKG_LOC/$CMD $@
    else
        echo "I didn't know what to do with '$@'"
        exit 1
    fi
fi