#!/usr/bin/env bash
source ./scripts/include.sh

before-start mysqld
(set -x
 $bin/mysqld --defaults-file=./config_files/my.cnf --initialize-insecure
 $bin/mysqld --defaults-file=./config_files/my.cnf &)
after-start mysqld

if [ $NODEINFO_IDX -eq 1 ]; then
  WAITED=0
  MAX_WAIT=100
  while true; do
    if $bin/mysqladmin ping -uroot --silent 2>/dev/null; then
      break
    fi
    if [ $WAITED -ge $MAX_WAIT ]; then
      echo "Timeout waiting"
      exit 1
    fi
    echo "Waiting for MySQL to start..."
    sleep 5
    WAITED=$((WAITED + 1))
  done
  echo "Creating the procedure for creating rdrs benchmark table" \
       "on MySQL ${MYSQLD_PUB_1}"
  $mysql -e "source ./scripts/benchmark_load.sql"
  echo "Creating the rondis tables table on MySQL ${MYSQLD_PUB_1}"
  $mysql -e "source ./scripts/create_rondis_tables.sql"
  $mysql -e "use benchmark;call CreateRondisTables(2)"
fi
