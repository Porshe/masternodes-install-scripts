#!/bin/bash

function echo_error(){
    echo -e "${RED}$1${NC}"
}
check_script_params(){
    #check for coin params
    if [[ -z "$1" ]]; then
       echo_error "COIN param not set"
       return 0
    fi
    if [ ! -f "${CURRENT_FOLDER}/coins-configs/$1.sh" ]
    then
        echo_error "Config for coin \"$1\" not found"
        return 0
    fi

    #check for priv_key params
    if [[ -z "$2" ]]; then
       echo_error "Masternode PRIV_KEY param not set"
       return 0
    fi

    #check for IP params
    if [[ -z "$3" ]]; then
       echo_error "Masternode IP param not set"
       return 0
    fi

    #check for NODE_IDX params
    if [[ -z "$4" ]]; then
       echo_error "Masternode NODE IDX param not set"
       return 0
    fi

    #check for COIN_RPCIP params
    if [[ -z "$5" ]]; then
       echo_error "Masternode NODE RPCIP param not set"
       return 0
    fi

    return 1
}

check_wallet_script_params(){
    #check for coin params
    if [[ -z "$1" ]]; then
       echo_error "COIN param not set"
       return 0
    fi
    if [ ! -f "${CURRENT_FOLDER}/coins-configs/$1.sh" ]
    then
        echo_error "Config for coin \"$1\" not found"
        return 0
    fi

    #check for rpcport params
    if [[ -z "$2" ]]; then
       echo_error "COIN_RPCPORT param not set"
       return 0
    fi

    return 1
}


function detect_ubuntu() {
    if [[ $(lsb_release -d) == *16.04* ]]; then
        UBUNTU_VERSION=16
    elif [[ $(lsb_release -d) == *14.04* ]]; then
        UBUNTU_VERSION=14
    else
        echo_error "You are not running Ubuntu 14.04 or 16.04 Installation is cancelled."
        exit 1
    fi
}

function check_system() {
    detect_ubuntu
    if [[ $EUID -ne 0 ]]; then
        echo_error "$0 must be run as root."
        exit 1
    fi

#    if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
#        echo -e "${RED}$COIN_NAME is already installed.${NC}"
#        exit 1
#    fi
}

function prepare_system() {
    echo -e "Prepare the system to install ${GREEN}$COIN${NC} master node."
    apt-get update >/dev/null 2>&1
    apt-get install -y binutils >/dev/null 2>&1
}

#$1 - wallet|node folder
#$2 - wallet|node data folder
function prepare_coin_folder() {
    if [ -f "$COIN_FOLDER" ]
    then
        rm -f "$COIN_FOLDER/*"
    fi

    if [ ! -f "$COIN_FOLDER_DATA" ]
    then
        mkdir -p $COIN_FOLDER_DATA
        echo -e "${GREEN}Masternode foldder created:${NC}"
    fi
}

function progressfilt () {
  local flag=false c count cr=$'\r' nl=$'\n'
  while IFS='' read -d '' -rn 1 c
  do
    if $flag
    then
      printf '%c' "$c"
    else
      if [[ $c != $cr && $c != $nl ]]
      then
        count=0
      else
        ((count++))
        if ((count > 1))
        then
          flag=true
        fi
      fi
    fi
  done
}

function compile_error() {
    if [ "$?" -gt "0" ];
    then
        echo_error "Failed to compile $COIN. Please investigate."
        exit 1
    fi
}

function compile_coin() {
    echo -e "Prepare to download $COIN"
    TMP_FOLDER=$(mktemp -d)
    echo -e "Temp Folder: ${TMP_FOLDER}"
    cd $TMP_FOLDER
#    wget --progress=bar:force $COIN_REPO 2>&1 | progressfilt
    wget --progress=bar:force $COIN_REPO 2>&1
    tar xvzf $COIN_ZIP >/dev/null 2>&1
    rm -f $COIN_ZIP >/dev/null 2>&1
    coin_custom_comile
    compile_error
    cd $COIN_FOLDER
    rm -rf $TMP_FOLDER >/dev/null 2>&1
}

function get_node_rpcport(){
    echo $((60000 + ${NODE_IDX}))
}
function create_node_config() {

    if [[ ${#COIN_RPCIP} > 16 ]];
    then
        _RPC_BIND="[$COIN_RPCIP]:$COIN_RPCPORT"
    else
        _RPC_BIND="$COIN_RPCIP:$COIN_RPCPORT"
    fi
    if [[ ${#COIN_IP} > 16 ]];
    then
        _BIND="[$COIN_IP]:$COIN_PORT"
    else
        _BIND="$COIN_IP:$COIN_PORT"
    fi

    COIN_RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
    COIN_RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
    cat << EOF > $COIN_FOLDER_DATA/$CONFIG_FILE
rpcuser=$COIN_RPCUSER
rpcpassword=$COIN_RPCPASSWORD
rpcallowip=127.0.0.1
rpcallowip=10.7.96.0/24
rpcport=$COIN_RPCPORT
rpcbind=$_RPC_BIND
listen=1
server=1
daemon=1
masternode=1

logintimestamps=1
maxconnections=100

port=$COIN_PORT
bind=$_BIND
externalip=$_BIND
masternodeprivkey=$PRIV_KEY
EOF
}

function create_wallet_config() {
    COIN_RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
    COIN_RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
    cat << EOF > $COIN_FOLDER_DATA/$CONFIG_FILE
rpcuser=$COIN_RPCUSER
rpcpassword=$COIN_RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$COIN_RPCPORT
rpcbind=$COIN_RPCIP
listen=1
server=1
daemon=1
masternode=0

txindex=1
addressindex=1

logintimestamps=1
maxconnections=50

port=$COIN_PORT
bind=$COIN_IP:$COIN_PORT
EOF
}

function create_wallet_cli_scripts() {
    cat << EOF > $COIN_FOLDER/wallet-cli.sh
#!/bin/bash

$COIN_CLI -conf=$COIN_FOLDER_DATA/$CONFIG_FILE -datadir=$COIN_FOLDER_DATA "\$@"
EOF
    chmod +x $COIN_FOLDER/wallet-cli.sh
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow ssh >/dev/null 2>&1
  ufw allow $COIN_PORT >/dev/null 2>&1
  ufw allow $COIN_RPCPORT >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function important_information() {
    echo
    echo -e "================================================================================"
    echo -e "$COIN Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
    echo -e "Configuration file is: ${RED}$COIN_FOLDER_DATA/$CONFIG_FILE${NC}"

    echo -e "RPC_PORT: ${RED}$COIN_RPCPORT${NC}"
    echo -e "RPC_USER: ${RED}$COIN_RPCUSER${NC}"
    echo -e "RPC_PASSWORD: ${RED}$COIN_RPCPASSWORD${NC}"

    if (( $UBUNTU_VERSION == 16 )); then
        echo -e "Start: ${RED}systemctl start $COIN_SERVICE${NC}"
        echo -e "Stop: ${RED}systemctl stop $COIN_SERVICE${NC}"
        echo -e "Status: ${RED}systemctl status $COIN_SERVICE${NC}"
    else
        echo -e "Start: ${RED}/etc/init.d/$COIN_SERVICE start${NC}"
        echo -e "Stop: ${RED}/etc/init.d/$COIN_SERVICE stop${NC}"
        echo -e "Status: ${RED}/etc/init.d/$COIN_SERVICE status${NC}"
    fi
    echo -e "VPS_IP:PORT ${RED}$COIN_IP:$COIN_PORT${NC}"
    echo -e "MASTERNODE PRIVATEKEY is: ${RED}$PRIV_KEY${NC}"
    if [[ -n $SENTINEL_REPO  ]]; then
        echo -e "${RED}Sentinel${NC} is installed in ${RED}$COIN_FOLDER_DATA/sentinel${NC}"
        echo -e "Sentinel logs is: ${RED}$COIN_FOLDER_DATA/sentinel.log${NC}"
    fi
    echo -e "Check if $COIN is running by using the following command:\n${RED}ps -ef | grep $COIN_DAEMON | grep -v grep${NC}"
    echo -e "================================================================================"
}

function configure_systemd() {
    cat << EOF > /etc/systemd/system/$COIN_SERVICE
[Unit]
Description=$COIN_SERVICE service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$COIN_FOLDER_DATA/$COIN.pid

ExecStart=$COIN_DAEMON -daemon -conf=$COIN_FOLDER_DATA/$CONFIG_FILE -datadir=$COIN_FOLDER_DATA
ExecStop=$COIN_CLI -conf=$COIN_FOLDER_DATA/$CONFIG_FILE -datadir=$COIN_FOLDER_DATA stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 5
  systemctl start $COIN_SERVICE
  systemctl enable $COIN_SERVICE >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_SERVICE"
    echo -e "systemctl status $COIN_SERVICE"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function configure_startup() {
    cat << EOF > /etc/init.d/$COIN_SERVICE
#! /bin/bash
### BEGIN INIT INFO
# Provides: $COIN
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: $COIN: $COIN_SERVICE
# Description: This file starts and stops $COIN: $COIN_SERVICE MN server
#
### END INIT INFO

case "\$1" in
 start)
   $COIN_DAEMON -daemon
   sleep 5
   ;;
 stop)
   $COIN_CLI stop
   ;;
 restart)
   $COIN_CLI stop
   sleep 10
   $COIN_DAEMON -daemon
   ;;
 *)
   echo "Usage: $COIN_SERVICE {start|stop|restart}" >&2
   exit 3
   ;;
esac
EOF
    chmod +x /etc/init.d/$COIN_SERVICE >/dev/null 2>&1
    update-rc.d $COIN_SERVICE defaults >/dev/null 2>&1
    /etc/init.d/$COIN_SERVICE start >/dev/null 2>&1
    if [ "$?" -gt "0" ]; then
        sleep 5
        /etc/init.d/$COIN_SERVICE start >/dev/null 2>&1
    fi
}


function setup_node() {
    create_node_config
    create_wallet_cli_scripts
    enable_firewall

    important_information
    if (( $UBUNTU_VERSION == 16 )); then
        configure_systemd
    else
        configure_startup
    fi
}


function setup_wallet() {
    create_wallet_config
    create_wallet_cli_scripts

    important_information
    if (( $UBUNTU_VERSION == 16 )); then
        configure_systemd
    else
        configure_startup
    fi
}