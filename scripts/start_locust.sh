#!/usr/bin/env bash
source ./scripts/include.sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [workers number]"
  exit 1
fi
WORKERS=$1;

source ${RUN_DIR}/locust/bin/activate

before-start locust
if [ ${NODEINFO_IDX} -eq 1 ]; then
  RDRS_HOST=${RDRS_LB:-"http://${RDRS_PRI_1}:5406"}
  (set -x
   taskset -c 0 locust -f ./scripts/locust_batch_read.py --host=${RDRS_HOST} \
           --table-size=100000 --batch-size=100 --master \
           > ${RUN_DIR}/locust_master.log 2>&1 &)
  sleep 2
  for ((i=1; i<=${WORKERS}; i++)); do
    (set -x
     taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker \
             --master-host=${BENCH_PRI_1} \
             > ${RUN_DIR}/locust_worker_cpu_${i}.log 2>&1 &)
  done
else
  for ((i=0; i<${WORKERS}; i++)); do
    (set -x
     taskset -c ${i} locust -f ./scripts/locust_batch_read.py --worker \
             --master-host=${BENCH_PRI_1} \
             > ${RUN_DIR}/locust_worker_cpu_${i}.log 2>&1 &)
  done
fi
after-start locust
