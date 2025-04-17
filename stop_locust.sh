#!/bin/bash
source ./config
echo "Stopping locust"
for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/stop_locust.sh"
done
