export LISTEN_HOST=${LISTEN_HOST:-0.0.0.0}
export LISTEN_P2P_PORT=${LISTEN_P2P_PORT:-${EXPOSE_P2P_PORT:-26656}}
export LISTEN_RPC_PORT=${LISTEN_RPC_PORT:-${EXPOSE_RPC_PORT:-26657}}

export LISTEN_GRPC_PORT=${LISTEN_GRPC_PORT:-$EXPOSE_GRPC_PORT}
export LISTEN_GRPC_WEB_PORT=${LISTEN_GRPC_WEB_PORT:-$EXPOSE_GRPC_WEB_PORT}
export LISTEN_API_PORT=${LISTEN_API_PORT:-$EXPOSE_API_PORT}

export EXPOSE_P2P_PORT=${EXPOSE_P2P_PORT:-$LISTEN_P2P_PORT}
export NODE_MONIKER=${NODE_MONIKER:-$NODE_BINARY_NAME}

export SEEDS_P2P_PORT=${SEEDS_P2P_PORT:-26656}
export SEEDS_RPC_PORT=${SEEDS_RPC_PORT:-26657}
