#! /bin/bash

set -x
set -e

SCRIPT_DIRECTORY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [ -z "${ROLE}" ];then
  echo "ROLE is not set"
  exit -1
fi

initializeSsh(){
  mkdir -p /home/gpadmin/.ssh
  chmod 700 /home/gpadmin/.ssh
  cp /opt/greenplum/ssh/id_rsa.pub /home/gpadmin/.ssh/id_rsa.pub
  cp /opt/greenplum/ssh/id_rsa /home/gpadmin/.ssh/id_rsa
  cat /home/gpadmin/.ssh/id_rsa.pub > /home/gpadmin/.ssh/authorized_keys
  chmod 600 /home/gpadmin/.ssh/id_rsa.pub
  chmod 600 /home/gpadmin/.ssh/id_rsa
  chmod 600 /home/gpadmin/.ssh/authorized_keys
  chown -R gpadmin:gpadmin /home/gpadmin/.ssh
}

initializeMaster(){
  if [ -z "${MASTER_HOSTNAME}" ];then
      echo "MASTER_HOSTNAME should be set"
      exit -1
  fi
  ssh-keyscan ${MASTER_HOSTNAME} >> /home/gpadmin/.ssh/known_hosts
cat > /opt/greenplum/gpinitsystem_config <<EOF
SEG_PREFIX=gpseg
PORT_BASE=6000
declare -a DATA_DIRECTORY=(/opt/greenplum/data/primary)
MASTER_DIRECTORY=/opt/greenplum/data/master
MASTER_PORT=5432
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UTF8
EOF
  echo ARRAY_NAME="'${ARRAY_NAME:-Greenplum Data Platform}'" >> /opt/greenplum/gpinitsystem_config
  echo MASTER_HOSTNAME=${MASTER_HOSTNAME} >> /opt/greenplum/gpinitsystem_config
  echo DATABASE_NAME=${DATABASE_NAME:-gpdb} >> /opt/greenplum/gpinitsystem_config
  echo ${MASTER_HOSTNAME} >> /opt/greenplum/hostfile_exkeys
  echo ${MASTER_HOSTNAME} >> /opt/greenplum/seg_hosts
  chown gpadmin:gpadmin /opt/greenplum/gpinitsystem_config
  chown gpadmin:gpadmin /opt/greenplum/hostfile_exkeys
  chown gpadmin:gpadmin /opt/greenplum/seg_hosts
cat > /home/gpadmin/.bashrc <<EOF
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
source /usr/local/greenplum-db-6.8.1/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/opt/greenplum/data/master/gpseg-1
export PGPORT=5432
export PGUSER=gpadmin
EOF
  echo PGDATABASE=${DATABASE_NAME:-gpdb} >> /home/gpadmin/.bashrc
  chown gpadmin:gpadmin /home/gpadmin/.bashrc
  su -c /opt/greenplum/init_gp_service.sh - gpadmin
}

addSlaveInfo(){
  if [ -z "${SLAVE_HOSTNAME_LIST}" ];then
      echo "SLAVE_HOSTNAME_LIST should be set"
      exit -1
  fi
  for SLAVE in ${SLAVE_HOSTNAME_LIST}
  do
      ssh-keyscan ${SLAVE} >> /home/gpadmin/.ssh/known_hosts
      echo ${SLAVE} >> /opt/greenplum/hostfile_exkeys
      echo ${SLAVE} >> /opt/greenplum/seg_hosts
  done
}

initializeSsh

if [ "${ROLE}" = "MASTERWITHSLAVE" ];then
  initializeMaster
elif [ "${ROLE}" = "CLUSTER" ];then
  addSlaveInfo
  initializeMaster
fi