#!/bin/bash


#format
#. install.sh COIN PRIV_KEY IP NODE_IDX RPCIP
#. install.sh GOA 7eLpV9ZxqeEWLk3zUyPPoSdtJT9kZ8Wt7jHH9PT9SX2YK7QXCAn 2001:19f0:5001:25f0:5400:01ff:fea9:1ae2 0 127.0.0.1

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


CURRENT_FOLDER=$(pwd)
echo -e "${GREEN}Current folder:${NC} ${CURRENT_FOLDER}"

#include all functions
source ./functions.sh

if check_script_params $1 $2 $3 $4 $5; then
   exit 1
fi

COIN=$1
PRIV_KEY=$2
COIN_IP=$3
NODE_IDX=$4
COIN_FOLDER="/masternodes/node_${NODE_IDX}"
COIN_FOLDER_DATA="${COIN_FOLDER}/data"
COIN_SERVICE=node_$NODE_IDX.service

COIN_RPCIP=$5
COIN_RPCPORT=$(get_node_rpcport)
COIN_RPCUSER=
COIN_RPCPASSWORD=

#include coin config
source ${CURRENT_FOLDER}/coins-configs/${COIN}.sh



clear
echo -e "${GREEN}Coin:${NC} ${COIN}"
echo -e "${GREEN}Masternode private key:${NC} ${PRIV_KEY}"
echo -e "${GREEN}Masternode NODE IP:${NC} ${COIN_IP}"
echo -e "${GREEN}Masternode NODE IDX:${NC} ${NODE_IDX}"
echo -e "${GREEN}Masternode NODE FOLDER:${NC} ${COIN_FOLDER}"
echo -e "${GREEN}Masternode NODE DATA FOLDER:${NC} ${COIN_FOLDER_DATA}"
echo -e "${GREEN}Masternode NODE RPCIP:${NC} ${COIN_RPCIP}"
echo -e "${GREEN}Masternode NODE RPCPORT:${NC} ${COIN_RPCPORT}"


if [ "$( ps -ef | grep -v grep | grep -c ${COIN_FOLDER} )" -ge 1 ]
then
    echo_error "Node with index ${NODE_IDX} already deployed."
    exit 1
fi



check_system
prepare_system
prepare_coin_folder
compile_coin
setup_node
setup_node_sentinel

exit 0