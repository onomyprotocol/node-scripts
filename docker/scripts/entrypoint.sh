#!/bin/bash

export LISTEN_HOST=${LISTEN_HOST:-0.0.0.0}
export LISTEN_P2P_PORT=${LISTEN_P2P_PORT:-${EXPOSE_P2P_PORT:-26656}}
export LISTEN_RPC_PORT=${LISTEN_RPC_PORT:-${EXPOSE_RPC_PORT:-26657}}
export LISTEN_GRPC_PORT=${LISTEN_GRPC_PORT:-$EXPOSE_GRPC_PORT}
export LISTEN_GRPC_WEB_PORT=${LISTEN_GRPC_WEB_PORT:-$EXPOSE_GRPC_WEB_PORT}
export LISTEN_API_PORT=${LISTEN_API_PORT:-$EXPOSE_API_PORT}

export EXPOSE_P2P_PORT=${EXPOSE_P2P_PORT:-$LISTEN_P2P_PORT}
export NODE_MONIKER=${NODE_MONIKER:-$NODE_BINARY_NAME}

$SCRIPTS_HOME/instance-setup.sh

cosmovisor start --home "$NODE_HOME" &

if [ -z $COMPARE_NODES ]; then
  echo "No COMPARE_NODES set, not running cosmos-keepup.sh"
else
  cosmos-keepup.sh &
fi

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?