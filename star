#!/usr/bin/env bash

STAR_PKG_LOC="/usr/local/opt/star-pkg"
STAR_BIN_LOC="$STAR_PKG_LOC/bin"
STAR_PKG_REPO="git@github.com:RadarRelay/star-pkg.git"
STAR_DOT_DIR=~/.star

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

install () {
    mkdir $STAR_PKG_LOC
    git clone $STAR_PKG_REPO $STAR_PKG_LOC

}

uninstall() {
    rm -rf $STAR_PKG_LOC
}

checkdotdir () {
    if [[ ! -d $STAR_DOT_DIR ]]
    then
        mkdir -p $STAR_DOT_DIR
        chmod 700 $STAR_DOT_DIR
    fi
}

checkforupdate () {
    if [ -z ${STAR_NO_UPDATE+x} ]
    then
        if [ ! -d $STAR_PKG_LOC ]
        then
            echo "star-pkg isn't installed, installing from ${STAR_PKG_REPO}"
            install
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
    if [ -f "$STAR_CUR_BIN_LOC/$1" ]
    then
        CMD=$1
        shift
        # Execute command while setting environment variables
        STAR_PKG_LOC=$STAR_PKG_LOC \
            STAR_CUR_BIN_LOC=$STAR_CUR_BIN_LOC \
            $STAR_CUR_BIN_LOC/$CMD $@
    elif [ -d "$STAR_CUR_BIN_LOC/$1" ]
    then
        STAR_CUR_BIN_LOC="$STAR_CUR_BIN_LOC/$1"
        shift
        recursiveexec $@
    else
        echo "I didn't know what to do with '$@'"
        exit 1
    fi
}

checkdotdir
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
    STAR_CUR_BIN_LOC=$STAR_BIN_LOC
    recursiveexec $@
fi