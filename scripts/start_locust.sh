#!/usr/bin/env bash
source ./scripts/include.sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 ROWS WORKERS"
  exit 1
fi
LOCUST_TABLE_SIZE=$1
WORKERS=$2

source ${RUN_DIR}/locust/bin/activate

before-start locust
if [ ${NODEINFO_IDX} -eq 0 ]; then
  # Start master
  (set -x
   taskset -c 0 locust -f ./scripts/locust_batch_read.py --host=${RDRS_URI} \
           --batch-size=100 --table-size=$LOCUST_TABLE_SIZE \
           --database-name=benchmark --master \
           > ${RUN_DIR}/locust_master.log 2>&1 &)
  sleep 2
  # Start workers
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
