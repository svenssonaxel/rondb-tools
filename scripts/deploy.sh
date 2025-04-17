#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 [tarball name] [role] [skip_fetch_tarball_if_possible ? 0 : 1]"
  exit 1
fi

source ./scripts/config
TARBALL_NAME=${1}
TARBALL_SOURCE=https://repo.hops.works/master/${TARBALL_NAME}
echo "RonDB tarball source: ${TARBALL_SOURCE}"

# 1. check the role
case "$2" in
  ndb_mgmd)
    echo "Deploying ndb_mgmd"
    ;;
  ndbmtd)
    echo "Deploying ndbmtd"
    ;;
  mysqld)
    echo "Deploying mysqld"
    ;;
  rdrs)
    echo "Deploying rdrs"
    ;;
  locust)
    echo "Deploying locust"
    ;;
  valkey)
    echo "Deploying valkey"
    ;;
  sysbench)
    echo "Deploying sysbench"
    ;;
  *)
    echo "Unknown role: $2"
    exit 1
    ;;
esac

# 2. Install RonDB
TARBALL=${TARBALL_NAME%%.tar.gz}
SKIP_FETCH_TARBALL=1
SKIP_FETCH_TARBALL_AND_ENV=2
skip=$3
can_skip_tarball=0
if [ $skip -eq $SKIP_FETCH_TARBALL ] || [ $skip -eq $SKIP_FETCH_TARBALL_AND_ENV ]; then
  if [ -d "${WORKSPACE}/${TARBALL}" ]; then
    can_skip_tarball=1;
  fi
fi

if [ $can_skip_tarball -eq 0 ]; then
  rm -rf ${WORKSPACE}
  mkdir -p ${WORKSPACE}
  cd ${WORKSPACE}
  wget $TARBALL_SOURCE
  tar xvf ${TARBALL_NAME}
  ln -s ${TARBALL} rondb
elif [ $can_skip_tarball ] && [ $skip -eq $SKIP_FETCH_TARBALL_AND_ENV ]; then
  exit
fi

# 3. Start the role service
case "$2" in
  ndb_mgmd)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/ndb_mgmd/data
    mkdir -p ${RUN_DIR}/ndb_mgmd/config
    ;;
  ndbmtd)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/ndbmtd/data
    mkdir -p ${RUN_DIR}/ndbmtd/ndb_data
    mkdir -p ${RUN_DIR}/ndbmtd/ndb_disk_columns
    ;;
  mysqld)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/mysqld/data
    ;;
  rdrs)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/rdrs
    ;;
  locust)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/locust
    sudo apt update
    sudo apt install python3 python3-venv -y
    python3 -m venv ${RUN_DIR}/locust
    source ${RUN_DIR}/locust/bin/activate
    pip install --upgrade pip
    pip install locust
    ;;
  valkey)
    # Notice:
    # Don't remove RUN_DIR if valkey stays with locust
    sudo apt update
    sudo apt install valkey-tools -y
    ;;
  sysbench)
    # Notice:
    # Don't remove RUN_DIR if sysbench stays with locust
    ;;
esac
