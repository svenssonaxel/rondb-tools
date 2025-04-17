#!/bin/bash
source ./scripts/config

echo "${WORKSPACE}/rondb/bin/rdrs2 -c ./config_files/rdrs2.config"
${WORKSPACE}/rondb/bin/rdrs2 -c ./config_files/rdrs2.config > ${RUN_DIR}/rdrs/rdrs.log 2>&1 &
