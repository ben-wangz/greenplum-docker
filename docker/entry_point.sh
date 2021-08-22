#! /bin/bash

set -x
set -e

SCRIPT_DIRECTORY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [ -z "${ROLE}" ];then
  echo "ROLE is not set"
  exit -1
fi

nodeInit(){
  mkdir -p /home/gpadmin/.ssh
  cat /opt/greenplum/ssh/id_rsa.pub > /home/gpadmin/.ssh/id_rsa.pub
  cat /opt/greenplum/ssh/id_rsa > /home/gpadmin/.ssh/id_rsa
  cat /home/gpadmin/.ssh/id_rsa.pub > /home/gpadmin/.ssh/authorized_keys
  chmod 600 /home/gpadmin/.ssh/id_rsa.pub
  chmod 600 /home/gpadmin/.ssh/id_rsa
  chmod 600 /home/gpadmin/.ssh/authorized_keys
  chmod 700 /home/gpadmin/.ssh
  chown -R gpadmin:gpadmin /home/gpadmin/.ssh
}

masterInit(){
  ssh-keyscan ${HOSTNAME} >> /home/gpadmin/.ssh/known_hosts

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
  echo MASTER_HOSTNAME=${HOSTNAME} >> /opt/greenplum/gpinitsystem_config
  echo DATABASE_NAME=${DATABASE_NAME:-gpdb} >> /opt/greenplum/gpinitsystem_config
  echo ${HOSTNAME} >> /opt/greenplum/hostfile_exkeys
  echo ${HOSTNAME} >> /opt/greenplum/seg_hosts
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
  if [ -z "${SLAVENAME}" ]; then
    echo "SLAVENAME not set!"
    exit -1
  fi

  for SLAVE in ${SLAVENAME}
  do
      ssh-keyscan ${SLAVE} >> /home/gpadmin/.ssh/known_hosts
  done

  for SLAVE in ${SLAVENAME}
  do
      echo ${SLAVE} >> /opt/greenplum/hostfile_exkeys
  done

  for SLAVE in ${SLAVENAME}
  do
      echo ${SLAVE} >> /opt/greenplum/seg_hosts
  done
}

nodeInit

if [ "${ROLE}" = "MASTERWITHSLAVE" ];then
  if [ -z "${HOSTNAME}" ];then
    echo "HOSTNAME is not set"
    exit -1
  fi
  masterInit
elif [ "${ROLE}" = "CLUSTER" ];then
  if [ -z "${HOSTNAME}" ];then
    echo "HOSTNAME should be set"
    exit -1
  fi
  if [ -z "${SLAVENAME}" ];then
    echo "SLAVENAME should be set"
    exit -1
  fi
  addSlaveInfo
  masterInit
fi