#!/bin/bash

source ./config

rm -rf ./config_files
mkdir ./config_files
cd ./config_files

#1. Generate config.ini
echo "[NDBD DEFAULT]" > config.ini
echo "AutomaticThreadConfig=true" >> config.ini
echo "AutomaticMemoryConfig=true" >> config.ini
echo "MaxDMLOperationsPerTransaction=100000" >> config.ini
echo "MaxNoOfConcurrentOperations=100000" >> config.ini
echo >> config.ini
echo "NoOfReplicas=${NO_OF_REPLICAS}" >> config.ini
echo "PartitionsPerNode=4" >> config.ini

echo >> config.ini
echo "[NDB_MGMD]" >> config.ini
echo "HostName=${NDB_MGMD_PRI}" >> config.ini
echo "DataDir=${RUN_DIR}/ndb_mgmd/data" >> config.ini

echo >> config.ini
global_node_id=0
location_domain_id=0
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  echo "[NDBD]" >> config.ini
  node_ip="NDBMTD_PRI_$i"
  echo "HostName=${!node_ip}" >> config.ini
  nodeid=$((i + 1))
  global_node_id=$nodeid
  echo "NodeId=${nodeid}" >> config.ini
  echo "DataDir=${RUN_DIR}/ndbmtd/data" >> config.ini
  echo "FileSystemPath=${RUN_DIR}/ndbmtd/ndb_data" >> config.ini
  echo "FileSystemPathDD=${RUN_DIR}/ndbmtd/ndb_disk_columns" >> config.ini
  echo "LocationDomainId=${location_domain_id}
  location_domain_id=$((location_domain_id + 1))
  if test "x${location_domain_id} = "x${NUM_AZS} ; then
    location_domain_id=0
  fi
done

echo >> config.ini
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  echo "[MYSQLD]" >> config.ini
  node_ip="MYSQLD_PRI_$i"
  echo "HostName=${!node_ip}" >> config.ini
  nodeid=$((global_node_id + 1))
  echo "NodeId=${nodeid}" >> config.ini
  global_node_id=$nodeid
  echo "LocationDomainId=${location_domain_id}
  location_domain_id=$((location_domain_id + 1))
  if test "x${location_domain_id} = "x${NUM_AZS} ; then
    location_domain_id=0
  fi
done

echo >> config.ini

NUM_CLUSTER_CONN=2
for ((i=1; i<=RDRS_NUMS; i++)); do
  for ((j=1; j<=NUM_CLUSTER_CONN; j++)); do
    echo "[API]" >> config.ini
    echo "# RDRS" >> config.ini
    node_ip="RDRS_PRI_$i"
    echo "HostName=${!node_ip}" >> config.ini
    nodeid=$((global_node_id + 1))
    echo "NodeId=${nodeid}" >> config.ini
    global_node_id=$nodeid
    echo "LocationDomainId=${location_domain_id}
  done
  location_domain_id=$((location_domain_id + 1))
  if test "x${location_domain_id} = "x${NUM_AZS} ; then
    location_domain_id=0
  fi
done

NUM_RESERVED_CLUSTER_CONN=10
echo >> config.ini
for ((i=1; i<=NUM_RESERVED_CLUSTER_CONN; i++)); do
  echo "[API]" >> config.ini
done


#2. Generate my.cnf
echo "[mysqld]" > my.cnf
echo "ndbcluster" >> my.cnf
echo "user=root" >> my.cnf
echo "basedir=${WORKSPACE}/rondb" >> my.cnf
echo "datadir=${RUN_DIR}/mysqld/data" >> my.cnf
echo "log_error=${RUN_DIR}/mysqld/data/mysql-error.log" >> my.cnf
echo "log_error_verbosity=3" >> my.cnf

echo >> my.cnf
echo "[mysql_cluster]" >> my.cnf
echo "ndb-connectstring=${NDB_MGMD_PRI}" >> my.cnf

#3. Generate rdrs2.config
sed "s/localhost/${NDB_MGMD_PRI}/g" ../rdrs2.config.template > rdrs2.config
