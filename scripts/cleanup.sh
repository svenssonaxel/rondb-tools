#!/bin/bash
source ./scripts/config

#1. Stop servers
ps -ef | grep 'ndb_mgmd' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'ndbmtd' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'mysqld' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'rdrs' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'sysbench' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'locust' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9
ps -ef | grep 'valkey' | grep -v 'grep' | awk '{print $2}' | xargs -r kill -9

#2. cleanup directories
rm -rf ${RUN_DIR}/ndb_mgmd/data/*
rm -rf ${RUN_DIR}/ndb_mgmd/config/*
rm -rf ${RUN_DIR}/ndbmtd/data/*
rm -rf ${RUN_DIR}/ndbmtd/ndb_data/*
rm -rf ${RUN_DIR}/ndbmtd/ndb_disk_columns/*
rm -rf ${RUN_DIR}/mysqld/data/*
rm -rf ${RUN_DIR}/rdrs/*
rm -rf /home/${USER}/uploads
