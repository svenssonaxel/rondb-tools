#!/bin/bash
source ./scripts/config

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [node id]"
  exit 1
fi

NODE_ID=$1
echo "${WORKSPACE}/rondb/bin/ndbmtd --initial --ndb-nodeid=${NODE_ID} --ndb-connectstring=${NDB_MGMD_PRI}:1186"
${WORKSPACE}/rondb/bin/ndbmtd --initial --ndb-nodeid=${NODE_ID} --ndb-connectstring=${NDB_MGMD_PRI}:1186
