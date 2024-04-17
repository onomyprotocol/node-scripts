#!/bin/bash

# This script polls COMPARE_NODES and compares to localhost, restarting service when local node gets too far behind others
# This is intended to automatically recover from issues where the node freezes for unknown reasons

NODE_POLL_INTERVAL_SECONDS=${NODE_POLL_INTERVAL_SECONDS:-2}
NODE_RESTART_HEIGHT_DIFF=${NODE_RESTART_HEIGHT_DIFF:-3}
NODE_RESTART_CMD=${NODE_RESTART_CMD:-echo "No NODE_RESTART_CMD defined"}
SERVICE_NAME="$NODE_MONIKER@$CHAIN_ID"
IFS=', ' read -r -a COMPARE_NODES_LIST <<< "$COMPARE_NODES"

function getHeight() {
  echo `curl $1/status 2> /dev/null | jq -r .result.sync_info.latest_block_height`;
}

function getHeightDiff() {
  thisHeight=`getHeight "http://localhost:$LISTEN_RPC_PORT"`
  heightDiff=0;
  for url in "${COMPARE_NODES_LIST[@]}"; do
    otherHeight=`getHeight "$url"`;
    diff="$((otherHeight-thisHeight))";
    if (( diff > heightDiff )); then
      heightDiff=$diff
    fi
  done
  echo $heightDiff
}

function waitToCatchup() {
  while [ `getHeightDiff` -gt 0 ]
  do
    sleep $NODE_POLL_INTERVAL_SECONDS
  done
  now=`date -u --iso-8601=s`
  msg="$SERVICE_NAME caught up $now"
  echo $msg
  discord.sh --text "$msg"
}

function restartNode() {
  now=`date -u --iso-8601=s`
  msg="RESTARTING $SERVICE_NAME $now"
  echo $msg

  $NODE_RESTART_CMD
  waitToCatchup
}

function pollHeightDiff() {
  HEIGHT_DIFF=`getHeightDiff`;

  if (( HEIGHT_DIFF > NODE_RESTART_HEIGHT_DIFF)); then
    now=`date -u --iso-8601=s`
    msg="$SERVICE_NAME height diff: $HEIGHT_DIFF $now"
    echo $msg
    discord.sh --text "$msg"
    restartNode
  fi
  sleep $NODE_POLL_INTERVAL_SECONDS
}

waitToCatchup
while true
do
  pollHeightDiff
done
