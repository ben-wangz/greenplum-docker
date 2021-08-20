#! /bin/bash

set -x
set -e

SCRIPT_DIRECTORY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

mkdir -p /home/gpadmin/.ssh
cat /opt/greenplum/ssh/id_rsa.pub > /home/gpadmin/.ssh/id_rsa.pub
cat /opt/greenplum/ssh/id_rsa > /home/gpadmin/.ssh/id_rsa
cat /home/gpadmin/.ssh/id_rsa.pub > /home/gpadmin/.ssh/authorized_keys
chmod 600 /home/gpadmin/.ssh/id_rsa.pub
chmod 600 /home/gpadmin/.ssh/id_rsa
chmod 600 /home/gpadmin/.ssh/authorized_keys
chmod 700 /home/gpadmin/.ssh
chown -R gpadmin:gpadmin /home/gpadmin/.ssh

