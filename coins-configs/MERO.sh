#!/bin/bash

COIN_REPO='https://github.com/Mero-HH/mero/archive/v1.0.2.tar.gz'
COIN_ZIP='v1.0.2.tar.gz'
CONFIG_FILE='mero.conf'
COIN_PORT=14550
COIN_DAEMON="${COIN_FOLDER}/merod"
COIN_CLI="${COIN_FOLDER}/mero-cli"

function coin_custom_comile() {
    cd ./mero-1.0.2
    ./autogen.sh >/dev/null 2>&1
    ./configure --disable-tests --disable-gui-tests >/dev/null 2>&1

    make >/dev/null 2>&1
    if [ "$?" -gt "0" ];
    then
        echo_error "Failed to make $COIN. Please investigate."
        exit 1
    fi

    cd src
    strip merod
    strip mero-cli
    strip mero-tx
    cp merod $COIN_FOLDER
    cp mero-cli $COIN_FOLDER
    cp mero-tx $COIN_FOLDER
    cd ./../..
}