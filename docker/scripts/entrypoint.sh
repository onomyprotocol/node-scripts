#!/bin/bash

source $SCRIPTS_HOME/init-env.sh

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