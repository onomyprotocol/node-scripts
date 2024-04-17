# Onomy/ONEX Node Setup Scripts

Docker setup scripts for cosmos based blockchains

## Install

    git clone https://github.com/onomyprotocol/node-scripts.git
    cd node-scripts
    cp examples/onomy-mainnet-full-node.env ./.env
    # Edit .env to your liking
    docker-compose up -d
    # To watch node catch up:
    watch -t docker exec <NODE_CONTAINER_NAME> syncinfo.sh

## ENV Variable Documentation

TODO