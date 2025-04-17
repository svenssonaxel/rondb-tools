#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 [start master ? 0: 1] [workers number]"
  exit 1
fi

source ./scripts/config

RDRS_HOST=${RDRS_LB:-"http://${RDRS_PRI_1}:5406"}

START_MASTER=$1;
WORKERS=$2;

source ${RUN_DIR}/locust/bin/activate

if [ ${START_MASTER} -eq 1 ]; then
  echo "taskset -c 0 locust -f ./scripts/locust_batch_read.py --host=${RDRS_HOST} --table-size=10000 --batch-size=100 --master"
  taskset -c 0 locust -f ./scripts/locust_batch_read.py --host=${RDRS_HOST} --table-size=10000 --batch-size=100 --master &
  sleep 2
  for ((i=1; i<=${WORKERS}; i++)); do
    echo "taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker --master-host=${LOC_PRI_1}"
    taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker --master-host=${LOC_PRI_1} &
  done
else
  for ((i=0; i<${WORKERS}; i++)); do
    echo "taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker --master-host=${LOC_PRI_1}"
    taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker --master-host=${LOC_PRI_1} &
  done
fi
