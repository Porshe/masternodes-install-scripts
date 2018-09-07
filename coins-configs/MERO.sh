#!/bin/bash

COIN_REPO='https://github.com/Mero-HH/mero/archive/v1.0.1.tar.gz'
COIN_ZIP='v1.0.1.tar.gz'
CONFIG_FILE='mero.conf'
COIN_PORT=14550
COIN_DAEMON="${COIN_FOLDER}/merod"
COIN_CLI="${COIN_FOLDER}/mero-cli"

function coin_custom_comile() {
    export DEBCONF_FRONTEND=noninteractive
    add-apt-repository ppa:bitcoin/bitcoin -y >/dev/null 2>&1
    apt-get update -y >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade >/dev/null 2>&1
    apt-get dist-upgrade -y >/dev/null 2>&1

    apt-get install -y autoconf >/dev/null 2>&1
    apt-get install -y libgmp3-dev libboost-all-dev libminiupnpc-dev >/dev/null 2>&1
    apt-get install -y libminiupnpc-dev >/dev/null 2>&1
    apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils >/dev/null 2>&1
    apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev >/dev/null 2>&1
    apt-get install -y libdb4.8-dev libdb4.8++-dev >/dev/null 2>&1
    apt-get install -y libzmq3-dev >/dev/null 2>&1
    cd ./mero-1.0.1
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