#!/bin/bash
source ./config

if [ $# -ne 1 ]; then
  echo "Usage: $0 <total_worker_number>"
  exit 1
fi

if [ $LOC_NUMS -lt 1 ]; then
  echo "No lucust deployed!"
  exit 1
fi

bash ./stop_locust.sh

WORKER_TOTAL=$1

declare -A HOST_CPU_MAP
TOTAL_CPU=0

echo "Collecting CPU info from locust hosts..."

for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  CPU_COUNT=$(ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "nproc")
  if [ $i -eq 1 ]; then
		CPU_COUNT=$((CPU_COUNT - 1))
  fi
  HOST_CPU_MAP[$node_ip]=$CPU_COUNT
  TOTAL_CPU=$((TOTAL_CPU + CPU_COUNT))
  echo "${!node_ip} has $CPU_COUNT CPU cores available."
done

if [ $WORKER_TOTAL -gt $TOTAL_CPU ]; then
  echo "Error: Total workers ($WORKER_TOTAL) exceed total CPU cores available across hosts ($TOTAL_CPU)"
  exit 1
fi

echo "Distributing $WORKER_TOTAL workers across hosts..."

declare -A HOST_WORKER_MAP
REMAINING_WORKERS=$WORKER_TOTAL

for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  HOST_CPUS=${HOST_CPU_MAP[$node_ip]}
  if [ $REMAINING_WORKERS -le 0 ]; then
    HOST_WORKER_MAP[$node_ip]=0
    continue
  fi

  WORKERS_FOR_HOST=$((HOST_CPUS < REMAINING_WORKERS ? HOST_CPUS : REMAINING_WORKERS))
  HOST_WORKER_MAP[$node_ip]=$WORKERS_FOR_HOST
  REMAINING_WORKERS=$((REMAINING_WORKERS - WORKERS_FOR_HOST))
done

for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  WORKER_COUNT=${HOST_WORKER_MAP[$node_ip]}
  if [ $WORKER_COUNT -eq 0 ]; then
    continue
  fi

  echo "Launching $WORKER_COUNT workers on ${!node_ip}..."
  START_MASTER=0
  if [ $i -eq 1 ]; then
    START_MASTER=1
  fi
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/start_locust.sh ${START_MASTER} ${WORKER_COUNT} > /dev/null 2>&1 &"
done

if [ $? -eq 0 ]; then
  echo "Type http://${LOC_PUB_1}:8089 in the browser to start the benchmark"
fi
