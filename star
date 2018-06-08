#!/usr/bin/env bash

STAR_PKG_LOC="/usr/local/opt/star-pkg"
STAR_BIN_LOC="$STAR_PKG_LOC/bin"
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
            git clone $STAR_PKG_REPO $STAR_PKG_LOC
        fi
        pushd $STAR_PKG_LOC
            if [ ! -z ${STAR_BETA+x} ]
            then
                git checkout -q beta
                git pull --quiet origin beta
            else
                git checkout -q master
                git pull --quiet origin master
            fi
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

recursiveexec () {
    if [ "$1" == "" ]
    then
        echo "I couldn't find a command called '$INIT_CMD'"
        exit 2
    fi
    if [ -f "$CUR_BIN_LOC/$1" ]
    then
        CMD=$1
        shift
        $CUR_BIN_LOC/$CMD $@
    elif [ -d "$CUR_BIN_LOC/$1" ]
    then
        CUR_BIN_LOC="$CUR_BIN_LOC/$1"
        shift
        recursiveexec $@
    else
        echo "I didn't know what to do with '$@'"
        exit 1
    fi
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
    INIT_CMD=$1
    CUR_BIN_LOC=$STAR_BIN_LOC
    recursiveexec $@
fi