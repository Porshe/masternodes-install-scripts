#!/bin/bash

COIN_REPO='https://github.com/condominium/CondominiumCore/releases/download/v1.2.1.0/CDM-linux1210.zip'
COIN_ZIP='CDM-linux1210.zip'
COIN_SENTINEL_REPO='https://github.com/goacoincore/sentinel.git'
COIN_SENTINEL_CONF_PARAM='goacoin_conf'
CONFIG_FILE='condominium.conf'
COIN_PORT=33588
COIN_DAEMON="${COIN_FOLDER}/condominiumd"
COIN_CLI="${COIN_FOLDER}/condominium-cli"

function coin_custom_comile() {
    cp ./* $COIN_FOLDER
}