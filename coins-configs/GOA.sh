#!/bin/bash

COIN_REPO='https://github.com/goacoincore/goacoin/releases/download/v0.12.2.2/goacoin-daemon-0.12.2.2-linux64.tar.gz'
COIN_ZIP='goacoin-daemon-0.12.2.2-linux64.tar.gz'
COIN_SENTINEL_REPO='https://github.com/goacoincore/sentinel.git'
COIN_SENTINEL_CONF_PARAM='goacoin_conf'
CONFIG_FILE='goacoin.conf'
COIN_PORT=1947
COIN_DAEMON="${COIN_FOLDER}/goacoind"
COIN_CLI="${COIN_FOLDER}/goacoin-cli"

function coin_custom_comile() {
    cp * $COIN_FOLDER
}