#! /bin/bash

set -x
set -e

source /home/gpadmin/.bashrc
# check password less ssh
gpssh -f /opt/greenplum/hostfile_exkeys -e 'ls -l /usr/local/greenplum-db-6.8.1'
# init
if [ ! -f "/opt/greenplum/data/initialized" ]; then
    gpinitsystem -c /opt/greenplum/gpinitsystem_config -h /opt/greenplum/seg_hosts -a \
        && echo "host     all         gpadmin         0.0.0.0/0      md5" >> /opt/greenplum/data/master/gpseg-1/pg_hba.conf \
        && gpstop -u \
        && echo 1 > /opt/greenplum/data/initialized
fi
