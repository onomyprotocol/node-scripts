#!/bin/bash

###########################################################
# Cosmos SDK Binary/Cosmovisor Docker Image Setup
###########################################################

mkdir -p $NODE_HOME
mkdir -p $NODE_HOME/contracts
mkdir -p $NODE_HOME/logs
mkdir -p $NODE_HOME/cosmovisor/upgrades

mkdir -p $SCRIPTS_HOME/bin
mkdir -p $SCRIPTS_HOME/cosmovisor/genesis/bin

echo "Fetching: $NODE_BINARY_URL"
NODE_BINARY_PATH=$SCRIPTS_HOME/cosmovisor/genesis/bin/$NODE_BINARY_NAME
curl --no-progress-meter -L -o $NODE_BINARY_PATH $NODE_BINARY_URL
chmod +x $NODE_BINARY_PATH

COSMOVISOR_BINARY_URL=${COSMOVISOR_BINARY_URL:-https://github.com/onomyprotocol/onomy-sdk/releases/download/cosmovisor-v1.0.1/cosmovisor}
echo "Fetching: $COSMOVISOR_BINARY_URL"
COSMOS_BINARY_PATH=$SCRIPTS_HOME/bin/cosmovisor
curl --no-progress-meter -L -o $COSMOS_BINARY_PATH $COSMOVISOR_BINARY_URL
chmod +x $COSMOS_BINARY_PATH

ulimit -S -n 65536

echo "---- $NODE_BINARY_NAME binaries installed ----"
