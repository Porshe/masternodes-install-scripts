#!/bin/bash

#format
#. uninstall.sh NODE_IDX
#. uninstall.sh 0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ -z "$1" ]]; then
   echo_error "NODE_IDX param not set"
   return 0
fi


CURRENT_FOLDER=$(pwd)
echo -e "${GREEN}Current folder:${NC} ${CURRENT_FOLDER}"


NODE_IDX=$1
COIN_FOLDER="/masternodes/node_${NODE_IDX}"
COIN_FOLDER_DATA="${COIN_FOLDER}/data"
COIN_SERVICE=node_$NODE_IDX.service

clear
echo -e "${GREEN}Masternode NODE IDX:${NC} ${NODE_IDX}"
echo -e "${GREEN}Masternode NODE FOLDER:${NC} ${COIN_FOLDER}"
echo -e "${GREEN}Masternode NODE DATA FOLDER:${NC} ${COIN_FOLDER_DATA}"


crontab -l | grep -v "$COIN_FOLDER/sentinel" | crontab -

systemctl stop $COIN_SERVICE
systemctl disable $COIN_SERVICE
rm /etc/systemd/system/$COIN_SERVICE
systemctl daemon-reload
systemctl reset-failed

rm -rf $COIN_FOLDER

