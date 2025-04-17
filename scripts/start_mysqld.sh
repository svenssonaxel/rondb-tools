#!/bin/bash
source ./scripts/config

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [prepare rondis table ? 0 : 1]"
  exit 1
fi

prepare_rondis_tbl=$1

echo "${WORKSPACE}/rondb/bin/mysqld --defaults-file=./config_files/my.cnf --initialize-insecure"
${WORKSPACE}/rondb/bin/mysqld --defaults-file=./config_files/my.cnf --initialize-insecure

echo "${WORKSPACE}/rondb/bin/mysqld --defaults-file=./config_files/my.cnf&"
${WORKSPACE}/rondb/bin/mysqld --defaults-file=./config_files/my.cnf&

if [ $prepare_rondis_tbl -eq 1 ]; then
  WAITED=0
  MAX_WAIT=100
  while true; do
    ${WORKSPACE}/rondb/bin/mysqladmin ping -uroot --silent 2>/dev/null
    if [ $? -eq 0 ]; then
      break
    fi
    if [ $WAITED -ge $MAX_WAIT ]; then
      echo "Timeout waiting"
      exit 1
    fi
    sleep 1
    echo "Waiting for MySQL starts..."
    WAITED=$((WAITED + 1))
  done

  echo "Creating the procedure for creating rdrs benchmark table on MySQL ${MYSQLD_PUB_1}"
  ${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e "source ./scripts/benchmark_load.sql"
  echo "Creating the rondis tables table on MySQL ${MYSQLD_PUB_1}"
  ${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e "source ./scripts/create_rondis_tables.sql"
  ${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e "use benchmark;call CreateRondisTables(2)"
fi
