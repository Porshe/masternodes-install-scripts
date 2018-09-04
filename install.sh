#!/bin/bash

#format
#. install.sh COIN PRIV_KEY IP NODE_IDX
#. install.sh GOA 7eLpV9ZxqeEWLk3zUyPPoSdtJT9kZ8Wt7jHH9PT9SX2YK7QXCAn 2001:19f0:5001:25f0:5400:01ff:fea9:1ae2 0

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
NODE_IP=$3
NODE_IDX=$4
NODE_FOLDER="/masternodes/node_${NODE_IDX}"
NODE_FOLDER_DATA="${NODE_FOLDER}/data"

NODE_RPCIP=$5
NODE_RPCPORT=$(get_node_rpcport)
NODE_RPCUSER=
NODE_RPCPASSWORD=

#include coin config
source ${CURRENT_FOLDER}/coins-configs/${COIN}.sh



clear
echo -e "${GREEN}Coin:${NC} ${COIN}"
echo -e "${GREEN}Masternode private key:${NC} ${PRIV_KEY}"
echo -e "${GREEN}Masternode NODE IP:${NC} ${NODE_IP}"
echo -e "${GREEN}Masternode NODE IDX:${NC} ${NODE_IDX}"
echo -e "${GREEN}Masternode NODE FOLDER:${NC} ${NODE_FOLDER}"
echo -e "${GREEN}Masternode NODE DATA FOLDER:${NC} ${NODE_FOLDER_DATA}"
echo -e "${GREEN}Masternode NODE RPCIP:${NC} ${NODE_RPCIP}"
echo -e "${GREEN}Masternode NODE RPCPORT:${NC} ${NODE_RPCPORT}"


if [ ! "$(ps -ef | grep ${NODE_FOLDER} | grep -v grep)" -ge 1 ]
then
    echo_error "Node with index ${NODE_IDX} already deployed."
    exit 1
fi


check_system
prepare_system
prepare_node_folder
compile_node
setup_node

exit 0