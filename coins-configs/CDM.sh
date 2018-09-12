#!/bin/bash

COIN_REPO='https://cdmcoin.org/condominium_ubuntu.zip'
COIN_ZIP='condominium_ubuntu.zip'
COIN_SENTINEL_REPO='https://github.com/goacoincore/sentinel.git'
COIN_SENTINEL_CONF_PARAM='goacoin_conf'
CONFIG_FILE='condominium.conf'
COIN_PORT=33588
COIN_DAEMON="${COIN_FOLDER}/condominiumd"
COIN_CLI="${COIN_FOLDER}/condominium-cli"

function coin_custom_comile() {
#    cp ./linux1210/* $COIN_FOLDER
    cp ./condominium* $COIN_FOLDER
    chmod 755 $COIN_FOLDER/*
}