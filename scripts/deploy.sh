#!/usr/bin/env bash
source ./scripts/include.sh

# 1. check the role
case "$NODEINFO_ROLE" in
  ndb_mgmd|ndbmtd|mysqld|rdrs|prometheus|grafana|bench)
    echo "Deploying $NODEINFO_ROLE"
    ;;
  *)
    echo "Unknown role: $NODEINFO_ROLE"
    exit 1
    ;;
esac

# 2. Install RonDB
TARBALL=${TARBALL_NAME%%.tar.gz}

if need_rondb; then
    rm -rf ${WORKSPACE}
    mkdir -p ${WORKSPACE}
    cd ${WORKSPACE}
    tar xzf /tmp/${TARBALL_NAME}
    ln -s ${TARBALL} rondb
fi

# 3. Start the role service
case "$NODEINFO_ROLE" in
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
    sudo apt-get update -y
    sudo apt-get install -y libjsoncpp-dev
    ;;
  prometheus)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/prometheus
    sudo apt-get update -y
    sudo apt-get install -y prometheus
    ;;
  grafana)
    rm -rf ${RUN_DIR}
    mkdir -p ${RUN_DIR}/grafana
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | \
        sudo tee /etc/apt/sources.list.d/grafana.list
    sudo apt-get update -y
    sudo apt-get install -y grafana
    ;;
  bench)
    rm -rf ${RUN_DIR}
    # locust
    mkdir -p ${RUN_DIR}/locust
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-venv -y
    python3 -m venv ${RUN_DIR}/locust
    source ${RUN_DIR}/locust/bin/activate
    pip install --upgrade pip
    pip install locust
    # valkey
    sudo apt-get update -y
    sudo apt-get install -y redis-tools
    # sysbench
    ;;
esac
