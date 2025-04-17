#!/bin/bash
source ./config

bash ./stop_cluster.sh

echo "[Starting ndb_mgmd]"
ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${NDB_MGMD_PUB} "bash ~/scripts/start_mgmd.sh"

sleep 2
echo "[Starting ndbmtds]"
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  node_ip="NDBMTD_PUB_$i"
  nodeid=$((i + 1))
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/start_ndbd.sh ${nodeid}"
done

sleep 2
echo "[Starting mysqlds]"
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  prepare_rondis_tbl=0
  if [ $i -eq 1 ]; then
    prepare_rondis_tbl=1;
  fi
  node_ip="MYSQLD_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/start_mysqld.sh ${prepare_rondis_tbl}"
done

sleep 2
echo "[Starting rdrs]"
for ((i=1; i<=RDRS_NUMS; i++)); do
  node_ip="RDRS_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/start_rdrs.sh"
done
