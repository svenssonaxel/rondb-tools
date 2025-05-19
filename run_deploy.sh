#!/bin/bash
source ./config

echo "Deployment preview:"
echo "--------------------------------------------------"
echo "ndb_mgmd       -> ${NDB_MGMD_PRI} / ${NDB_MGMD_PUB}"
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  node_pri_ip="NDBMTD_PRI_$i"
  node_pub_ip="NDBMTD_PUB_$i"
  echo "ndbmtd [$i]     -> ${!node_pri_ip} / ${!node_pub_ip}"
done
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  node_pri_ip="MYSQLD_PRI_$i"
  node_pub_ip="MYSQLD_PUB_$i"
  echo "mysqld [$i]     -> ${!node_pri_ip} / ${!node_pub_ip}"
done
for ((i=1; i<=RDRS_NUMS; i++)); do
  node_pri_ip="RDRS_PRI_$i"
  node_pub_ip="RDRS_PUB_$i"
  echo "rdrs [$i]     -> ${!node_pri_ip} / ${!node_pub_ip}"
done
for ((i=1; i<=LOC_NUMS; i++)); do
  node_pri_ip="LOC_PRI_$i"
  node_pub_ip="LOC_PUB_$i"
  echo "locust [$i]     -> ${!node_pri_ip} / ${!node_pub_ip}"
done
for ((i=1; i<=VALKEY_NUMS; i++)); do
  node_pri_ip="LOC_PRI_$i"
  node_pub_ip="LOC_PUB_$i"
  echo "valkey [$i]     -> ${!node_pri_ip} / ${!node_pub_ip}"
done
echo "--------------------------------------------------"

case "$1" in
  1)
    echo "Deploy without reinstalling tarball"
    ;;
  2)
    echo "Deploy without reinstalling tarball and env"
    ;;
  *)
    echo "Deploy from stratch"
esac

echo
echo "Press any key to continue..."
read -n 1 -s

bash ./generate_config_files.sh

NO_SKIP=0
SKIP_FETCH_TARBALL=1
SKIP_FETCH_TARBALL_AND_ENV=2
skip=$NO_SKIP

if [ $# -eq 1 ]; then
  if [ $1 -eq $SKIP_FETCH_TARBALL ] || [ $1 -eq $SKIP_FETCH_TARBALL_AND_ENV ]; then
    skip=$1;
  fi
fi

# 1. ndb_mgmd
echo "Deploy ndb_mgmd"
#scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${NDB_MGMD_PUB}:~
#scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${NDB_MGMD_PUB}:~/scripts/config
#scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${NDB_MGMD_PUB}:~
rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${NDB_MGMD_PUB}:~
rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${NDB_MGMD_PUB}:~/scripts/config
rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${NDB_MGMD_PUB}:~
echo "rsync done"
ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${NDB_MGMD_PUB} "bash ~/scripts/deploy.sh ${TARBALL_NAME} ndb_mgmd ${skip}"

# 2. ndbmtd
for ((i=1; i<=NDBMTD_NUMS; i++)); do
  node_ip="NDBMTD_PUB_$i"
  echo "Deploy ndbmtd $i"

  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${!node_ip}:~
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${!node_ip}:~/scripts/config
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${!node_ip}:~/scripts/config
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${!node_ip}:~
  echo "rsync done"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/deploy.sh ${TARBALL_NAME} ndbmtd ${skip}"
done

# 3. mysqld
for ((i=1; i<=MYSQLD_NUMS; i++)); do
  node_ip="MYSQLD_PUB_$i"
  echo "Deploy mysqld $i"

  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${!node_ip}:~
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${!node_ip}:~/scripts/config
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${!node_ip}:~/scripts/config
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${!node_ip}:~
  echo "rsync done"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/deploy.sh ${TARBALL_NAME} mysqld ${skip}"
done

# 4. rdrs
for ((i=1; i<=RDRS_NUMS; i++)); do
  node_ip="RDRS_PUB_$i"
  echo "Deploy RDRS $i"

  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${!node_ip}:~
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${!node_ip}:~/scripts/config
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${!node_ip}:~/scripts/config
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${!node_ip}:~
  echo "rsync done"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/deploy.sh ${TARBALL_NAME} rdrs ${skip}"
done

# 5. locust
for ((i=1; i<=LOC_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  echo "Deploy Locust $i"

  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${!node_ip}:~
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${!node_ip}:~/scripts/config
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${!node_ip}:~/scripts/config
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${!node_ip}:~
  echo "rsync done"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/deploy.sh ${TARBALL_NAME} locust ${skip}"
done

wait # in case of any conflicts on apt install if the valkey stays with the locust.

# 6. valkey
for ((i=1; i<=VALKEY_NUMS; i++)); do
  node_ip="LOC_PUB_$i"
  echo "Deploy valkey $i"

  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./scripts ${USER}@${!node_ip}:~
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r config ${USER}@${!node_ip}:~/scripts/config
  #scp -i ${KEY_PEM} -o StrictHostKeyChecking=no -r ./config_files ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./scripts ${USER}@${!node_ip}:~
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config ${USER}@${!node_ip}:~/scripts/config
  rsync -avz --delete -e "ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no" ./config_files ${USER}@${!node_ip}:~
  locust_ip="LOC_PUB_$i"
  t_skip=$skip
  if [ $skip -eq $NO_SKIP ] && [ "${!node_ip}" == "${!locust_ip}" ]; then
    t_skip=$SKIP_FETCH_TARBALL
  fi
  echo "rsync done"
  ssh -i ${KEY_PEM} -o StrictHostKeyChecking=no ${USER}@${!node_ip} "bash ~/scripts/deploy.sh ${TARBALL_NAME} valkey ${t_skip}" &
done

wait

