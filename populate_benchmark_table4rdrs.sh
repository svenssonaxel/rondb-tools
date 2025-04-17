#!/bin/bash
source ./config

if [ $MYSQLD_NUMS -lt 1 ]; then
  echo "At least 1 MySQL required"
  exit 1
fi

MAX_WAIT=60
WAITED=0


while true; do
		ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${MYSQLD_PUB_1} "${WORKSPACE}/rondb/bin/mysqladmin ping -uroot --silent" 2>/dev/null

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

#echo "Installing procedure on MySQL ${MYSQLD_PUB_1}"
#ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${MYSQLD_PUB_1} "${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e \"source ./scripts/benchmark_load.sql\""
#ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${MYSQLD_PUB_1} "${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e \"use benchmark;source ./scripts/create_rondis_tables.sql\""
#ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${MYSQLD_PUB_1} "${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e \"use benchmark;call CreateRondisTables(2)\""
echo "Calling precedure to populate rdrs benchmark table"
ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${MYSQLD_PUB_1} "${WORKSPACE}/rondb/bin/mysql -h127.0.0.1 -P3306 -uroot -e \"use benchmark;call generate_table_data('bench_tbl', 10, 100000, 1000)\""
