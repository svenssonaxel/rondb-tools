#!/bin/bash

source ./config

session_name="rondb_benchmark"

if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    exit 0
fi

tmux new-session -d -s "$session_name"

#1. ndb_mgmd
name="mgmd"
node_ip=${NDB_MGMD_PUB}
tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${node_ip}"
tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}/ndb_mgmd" C-m

#2. ndbmtd
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  node_ip="NDBMTD_PUB_$i"
  name="ndbmtd_$i"
	tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip}"
  tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}/ndbmtd" C-m
done

#3. mysqld
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  node_ip="MYSQLD_PUB_$i"
  name="mysqld_$i"
	tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip}"
  tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}/mysqld" C-m
done

#4. rdrs
for ((i=1; i<=RDRS_NUMS; i++)); do
  node_ip="RDRS_PUB_$i"
  name="rdrs_$i"
	tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip}"
  tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}/rdrs" C-m
done

#5. locust
for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  name="locust_$i"
	tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip}"
  tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}; source ${RUN_DIR}/locust/bin/activate" C-m
done

#6. valkey

RONDIS_HOST=${RONDIS_LB:-${RDRS_PRI_1}}
for ((i=1; i<=VALKEY_NUMS; i++)); do
  node_ip="VAL_PUB_$i"
  name="valkey_$i"
	tmux new-window -t "$session_name" -n "${name}" "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip}"
  tmux send-keys -t "${session_name}:${name}" "cd ${RUN_DIR}; echo \"Run 'valkey-cli -h ${RONDIS_HOST}' to connect to the Rondis\"" C-m
done

tmux kill-window -t "${session_name}:0"

tmux attach-session -t "$session_name"
