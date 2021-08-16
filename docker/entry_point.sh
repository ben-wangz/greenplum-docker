#! /bin/bash

set -x
set -e

SCRIPT_DIRECOTRY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
HOSTNAME=${HOSTNAME:-gpmaster}

if [ -z "${AUTHORIZED_KEYS}" ]; then
    echo "AUTHORIZED_KEYS not set!"
    exit -1
fi
echo ${AUTHORIZED_KEYS} >> ${HOME}/.ssh/authorized_keys
chmod 600 ${HOME}/.ssh/authorized_keys
ssh-keyscan ${HOSTNAME} >> ${HOME}/.ssh/known_hosts

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
echo ARRAY_NAME="${ARRAY_NAME:-Greenplum Data Platform}" >> /opt/greenplum/gpinitsystem_config
echo MASTER_HOSTNAME=${HOSTNAME} >> /opt/greenplum/gpinitsystem_config
echo DATABASE_NAME=${DATABASE_NAME:-gpdb} >> /opt/greenplum/gpinitsystem_config
echo ${HOSTNAME} > /opt/greenplum/hostfile_exkeys
echo ${HOSTNAME} > /opt/greenplum/seg_hosts

cat > ${HOME}/.bashrc <<EOF
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
source /usr/local/greenplum-db-6.8.1/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/opt/greenplum/data/master/gpseg-1
export PGPORT=5432
export PGUSER=gpadmin
EOF
echo PGDATABASE=${DATABASE_NAME:-gpdb} >> ${HOME}/.bashrc

source ${HOME}/.bashrc
# check password less ssh
gpssh -f /opt/greenplum/hostfile_exkeys -e 'ls -l /usr/local/greenplum-db-6.8.1'
# init
if [ !-f "/opt/greenplum/data/initialized" ]; then
    gpinitsystem -c /opt/greenplum/gpinitsystem_config -h /opt/greenplum/seg_hosts \
        && echo 1 > /opt/greenplum/data/initialized
fi

