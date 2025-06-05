#!/bin/bash
source ./scripts/config

echo "${WORKSPACE}/rondb/bin/ndb_mgmd --initial -f ./config_files/config.ini --configdir=${RUN_DIR}/ndb_mgmd/config"
${WORKSPACE}/rondb/bin/ndb_mgmd --initial -f ./config_files/config.ini --configdir=${RUN_DIR}/ndb_mgmd/config
