#!/bin/bash
JSON=`cosmovisor status 2>&1`
NET_JSON=`curl -sS http://localhost:$LISTEN_RPC_PORT/net_info`
LATEST=`echo $JSON | jq -r '.SyncInfo.latest_block_time'`
PEERS=`echo $NET_JSON | jq -r '.result.n_peers'`
NOW=`date -u --iso-8601=ns`
echo "----- $NODE_MONIKER@$CHAIN_ID -----"
echo "Now:   $NOW"
echo "Block: $LATEST"
echo "Peers: $PEERS"
echo "-----Disk Use-----"
du -h --max-depth=0 $NODE_HOME 2> /dev/null
df -h $NODE_HOME
