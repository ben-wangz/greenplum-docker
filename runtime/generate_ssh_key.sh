#! /bin/bash

set -e
SCRIPT_DIRECOTRY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ssh-keygen -t rsa -b 4096 -N "" -f ${SCRIPT_DIRECOTRY}/id_rsa
