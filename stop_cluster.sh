#!/bin/bash
source ./config

echo "Stopping cluster"
#1. ndb_mgmd
ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${NDB_MGMD_PUB} "bash ~/scripts/cleanup.sh"

#2. ndbmtd
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  node_ip="NDBMTD_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/cleanup.sh"
done

#3. mysqld
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  node_ip="MYSQLD_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/cleanup.sh"
done

#4. rdrs
for ((i=1; i<=RDRS_NUMS; i++)); do
  node_ip="RDRS_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/cleanup.sh"
done

#5. locust
for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/cleanup.sh"
done
