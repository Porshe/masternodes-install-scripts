#!/bin/bash

COIN_REPO='https://github.com/Mero-HH/mero/archive/v1.0.1.tar.gz'
COIN_ZIP='v1.0.1.tar.gz'
CONFIG_FILE='mero.conf'
COIN_PORT=14550
COIN_DAEMON="${COIN_FOLDER}/merod"
COIN_CLI="${COIN_FOLDER}/mero-cli"

function coin_custom_comile() {
    add-apt-repository ppa:bitcoin/bitcoin -y
    apt-get update
    apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
    apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
    apt-get install -y libdb4.8-dev libdb4.8++-dev
    cd ./mero-1.0.1
    ./autogen.sh
    ./configure --disable-tests --disable-gui-tests
    make
    cd src
    strip merod
    strip mero-cli
    strip mero-tx
    cp merod $COIN_FOLDER
    cp mero-cli $COIN_FOLDER
    cp mero-tx $COIN_FOLDER
    cd ./../..
}