#!/bin/bash

#format
#. install.sh COIN RPCPORT
#. install.sh GOA 10000

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


CURRENT_FOLDER=$(pwd)
echo -e "${GREEN}Current folder:${NC} ${CURRENT_FOLDER}"

#include all functions
source ./functions.sh

if check_wallet_script_params $1 $2; then
   exit 1
fi

COIN=$1
COIN_IP="127.0.0.1"
COIN_FOLDER="/wallets/${COIN}"
COIN_FOLDER_DATA="${COIN_FOLDER}/data"
COIN_SERVICE=wallet_$COIN.service

COIN_RPCIP="127.0.0.1"
COIN_RPCPORT=$2
COIN_RPCUSER=
COIN_RPCPASSWORD=

#include coin config
source ${CURRENT_FOLDER}/coins-configs/${COIN}.sh



clear
echo -e "${GREEN}Coin:${NC} ${COIN}"
echo -e "${GREEN}Wallet IP:${NC} ${COIN_IP}"
echo -e "${GREEN}Wallet FOLDER:${NC} ${COIN_FOLDER}"
echo -e "${GREEN}Wallet DATA FOLDER:${NC} ${COIN_FOLDER_DATA}"
echo -e "${GREEN}Wallet RPCIP:${NC} ${COIN_RPCIP}"
echo -e "${GREEN}Wallet RPCPORT:${NC} ${COIN_RPCPORT}"


if [ "$( ps -ef | grep -v grep | grep -c ${COIN_FOLDER} )" -ge 1 ]
then
    echo_error "Wallet with ${COIN} already deployed."
    exit 1
fi


check_system
prepare_system
prepare_coin_folder
compile_coin
setup_wallet

exit 0