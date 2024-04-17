#!/bin/bash

###########################################################
# Cosmos SDK Node initialization/configuration script
###########################################################

NODE_CONFIG_DIR="$NODE_HOME/config"
NODE_CONFIG_TOML="$NODE_CONFIG_DIR/config.toml"
NODE_CONFIG_GENESIS="$NODE_CONFIG_DIR/genesis.json"
NODE_APP_CONFIG_TOML="$NODE_CONFIG_DIR/app.toml"

mkdir -p $NODE_HOME
mkdir -p $NODE_HOME/bin
mkdir -p $NODE_HOME/cosmovisor/genesis/bin

cp --update=none $SCRIPTS_HOME/bin/* $NODE_HOME/bin/
cp --update=none $SCRIPTS_HOME/cosmovisor/genesis/bin/* $NODE_HOME/cosmovisor/genesis/bin/

IS_INITIAL_SETUP=false

if [ -f "$NODE_CONFIG_TOML" ]; then
  echo "$NODE_CONFIG_TOML exists"
else
  echo "Creating $NODE_MONIKER node config with chain-id=$CHAIN_ID..."
  echo "$NODE_BINARY_NAME init $NODE_MONIKER --home \"$NODE_HOME\" --chain-id $CHAIN_ID"

  $NODE_BINARY_NAME init $NODE_MONIKER --home "$NODE_HOME" --chain-id $CHAIN_ID 
  # If no config exists, we will init it but not touch afterwards
  LEAVE_TOML_ALONE=false

  if [ -z "$CHAIN_GENESIS_URL" ]; then
    echo "No CHAIN_GENESIS_URL is set"
  else
    echo "Fetching genesis from $CHAIN_GENESIS_URL"
    curl --no-progress-meter -L $CHAIN_GENESIS_URL > $NODE_CONFIG_GENESIS
  fi

  IS_INITIAL_SETUP=true
fi

function getConfig() {
  crudini --get $@ | sed 's/^"//;s/"$//'
}

function setConfig() {
  if [ "$LEAVE_TOML_ALONE" = true ]; then
    echo "NOT setting $@"
  else
    echo "Setting $@"
    crudini --set $@
  fi
}

###########################################################
# config.toml p2p seeds
###########################################################
EXISTING_SEEDS=$(getConfig $NODE_CONFIG_TOML p2p seeds)
if [ -z "$EXISTING_SEEDS" ]; then
  if [ -z "$SEED_HOSTS" ]; then
    echo "No SEED_HOSTS"
  else
    echo "Fetching node ids from $SEED_HOSTS"
    CHAIN_SEEDS=
    for seedIP in ${SEED_HOSTS//,/ } ; do
      wget $seedIP:26657/status? -O $NODE_HOME/seed_status.json
      seedID=$(jq -r .result.node_info.id $NODE_HOME/seed_status.json)

      if [[ -z "${seedID}" ]]; then
        echo "Something went wrong, can't fetch $seedIP info: "
        cat $NODE_HOME/seed_status.json
        exit 1
      fi

      rm $NODE_HOME/seed_status.json

      CHAIN_SEEDS="$CHAIN_SEEDS$seedID@$seedIP:26656,"
    done
    setConfig $NODE_CONFIG_TOML p2p seeds "\"$CHAIN_SEEDS\""
  fi
else
  echo "Existing $NODE_CONFIG_TOML p2p seeds $EXISTING_SEEDS"
fi

###########################################################
# config.toml p2p persistent_peers/unconditional_peer_ids
###########################################################
EXISTING_PERSISTENT_PEERS=$(getConfig $NODE_CONFIG_TOML p2p persistent_peers)
if [ -z "$EXISTING_PERSISTENT_PEERS" ]; then
  if [ ! -z "$PERSISTENT_PEER_HOSTS" ]; then
    echo "Fetching node ids from $PERSISTENT_PEER_HOSTS"
    PERSISTENT_PEERS=
    PERSISTENT_PEER_IDS=
    for peerHost in ${PERSISTENT_PEER_HOSTS//,/ } ; do
      wget $peerHost:26657/status? -O $NODE_HOME/persistent_peer_status.json
      peerID=$(jq -r .result.node_info.id $NODE_HOME/persistent_peer_status.json)

      if [[ -z "${peerID}" ]]; then
        echo "Something went wrong, can't fetch $peerHost info: "
        cat $NODE_HOME/persistent_peer_status.json
        exit 1
      fi

      rm $NODE_HOME/persistent_peer_status.json

      PERSISTENT_PEERS="$PERSISTENT_PEERS$peerID@$peerHost:26656,"
      PERSISTENT_PEER_IDS="$PERSISTENT_PEER_IDS$peerID,"
    done
    setConfig $NODE_CONFIG_TOML p2p persistent_peers "\"$PERSISTENT_PEERS\""
    setConfig $NODE_CONFIG_TOML p2p unconditional_peer_ids "\"$PERSISTENT_PEER_IDS\""
  fi
else
  echo "Existing $NODE_CONFIG_TOML p2p persistent_peers \"$EXISTING_PERSISTENT_PEERS\""
fi

###########################################################
# config.toml p2p
###########################################################
if [ "$NODE_P2P_ADDR_BOOK_STRICT" = true ] ; then
  setConfig $NODE_CONFIG_TOML p2p addr_book_strict true
else
  setConfig $NODE_CONFIG_TOML p2p addr_book_strict false
fi

if [ -z "$EXTERNAL_IP" ]; then
  setConfig $NODE_CONFIG_TOML p2p external_address "\"\""
else
  setConfig $NODE_CONFIG_TOML p2p external_address "\"tcp://$EXTERNAL_IP:$EXPOSE_P2P_PORT\""
fi

if [ "$NODE_SEED_MODE" = true ]; then
  setConfig $NODE_CONFIG_TOML p2p seed_mode true
else
  setConfig $NODE_CONFIG_TOML p2p seed_mode false
fi

if [ "$NODE_P2P_PEX" = false ]; then
  setConfig $NODE_CONFIG_TOML p2p pex false
else
  setConfig $NODE_CONFIG_TOML p2p pex true
fi

###########################################################
# config.toml statesync
###########################################################
if [ "$NODE_STATESYNC" = true ]; then
  setConfig $NODE_CONFIG_TOML statesync enable true
else
  setConfig $NODE_CONFIG_TOML statesync enable false
fi

if [ -z "$NODE_STATESYNC_RPC_SERVERS" ]; then
  setConfig $NODE_CONFIG_TOML statesync rpc_servers "\"\""
else
  setConfig $NODE_CONFIG_TOML statesync rpc_servers "\"$NODE_STATESYNC_RPC_SERVERS\""
fi

if [ -z "$NODE_STATESYNC_TRUST_HEIGHT" ]; then
  setConfig $NODE_CONFIG_TOML statesync trust_height 0
else
  setConfig $NODE_CONFIG_TOML statesync trust_height $NODE_STATESYNC_TRUST_HEIGHT
fi

if [ -z "$NODE_STATESYNC_TRUST_HASH" ]; then
  setConfig $NODE_CONFIG_TOML statesync trust_hash "\"\""
else
  setConfig $NODE_CONFIG_TOML statesync trust_hash "\"$NODE_STATESYNC_TRUST_HASH\""
fi

###########################################################
# config.toml rosetta
###########################################################
setConfig $NODE_CONFIG_TOML rosetta enable false

#######################################
# config.toml rpc
#######################################
setConfig $NODE_CONFIG_TOML rpc laddr "\"tcp://$LISTEN_HOST:$LISTEN_RPC_PORT\""
if [ -z "$RPC_CORS_ALLOWED_ORIGINS" ]; then
  setConfig $NODE_CONFIG_TOML rpc cors_allowed_origins "\"\""
else
  setConfig $NODE_CONFIG_TOML rpc cors_allowed_origins "$RPC_CORS_ALLOWED_ORIGINS"
fi

###########################################################
# app.toml api
###########################################################
if [ -z "$LISTEN_API_PORT" ]; then
  setConfig $NODE_APP_CONFIG_TOML api enable false
else
  setConfig $NODE_APP_CONFIG_TOML api enable true
  setConfig $NODE_APP_CONFIG_TOML api address "\"tcp://$LISTEN_HOST:$LISTEN_API_PORT\""
  if [ "$NODE_API_SWAGGER" = true ]; then
    setConfig $NODE_APP_CONFIG_TOML api swagger true
  else
    setConfig $NODE_APP_CONFIG_TOML api swagger false
  fi
fi

###########################################################
# app.toml grpc
###########################################################
if [ -z "$LISTEN_GRPC_PORT" ]; then
  setConfig $NODE_APP_CONFIG_TOML grpc enable false
else
  setConfig $NODE_APP_CONFIG_TOML grpc enable true
  setConfig $NODE_APP_CONFIG_TOML grpc address "\"$LISTEN_HOST:$LISTEN_GRPC_PORT\""
fi

###########################################################
# app.toml grpc-web
###########################################################
if [ -z "$LISTEN_GRPC_WEB_PORT" ]; then
  setConfig $NODE_APP_CONFIG_TOML grpc-web enable false
else
  setConfig $NODE_APP_CONFIG_TOML grpc-web enable true
  setConfig $NODE_APP_CONFIG_TOML grpc-web address "\"$LISTEN_HOST:$LISTEN_GRPC_WEB_PORT\""
fi

echo "Completed updating config from environment"

if [ "$IS_INITIAL_SETUP" = true ]; then
  if [ -z "$CHAIN_SNAPSHOT_URL" ]; then
    echo "No CHAIN_SNAPSHOT_URL to download"
  else
    cd $NODE_HOME
    echo "Downloading snapshot: $CHAIN_SNAPSHOT_URL"
    curl --no-progress-meter -L $CHAIN_SNAPSHOT_URL | lz4 -d | tar -xf -
  fi

  if [ -z "$CHAIN_ADDRBOOK_URL" ]; then
    echo "No CHAIN_ADDRBOOK_URL to download"
  else
    cd $NODE_HOME
    echo "Downloading addrbook: $CHAIN_ADDRBOOK_URL"
    curl --no-progress-meter  -L -o $NODE_CONFIG_DIR/addrbook.json $CHAIN_ADDRBOOK_URL
  fi
fi
