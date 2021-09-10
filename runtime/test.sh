#! /bin/bash

set -x
set -e

source /usr/local/greenplum-db-6.8.1/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/opt/greenplum/data/master/gpseg-1
export GP_HOST=${GP_HOST:gpmaster}
export GP_PORT=${GP_PORT:-5432}
export GP_USER=${GP_USER:-gpadmin}
export GP_PASSWORD=${GP_PASSWORD:-gparray}
export GP_DATABASE=${DATABASE_NAME:-gpdb}
export GP_LOAD_PORT=${GP_LOAD_PORT:-60000}
TEST_DATABASE_NAME=mydatabase

mkdir -p /home/gpadmin/runtime
cat > /home/gpadmin/runtime/create.table.sql <<EOF
create table test_table
(
   name varchar(54)
   ,value1 int
   ,value2 int
)
distributed by (name);
EOF
cat > /home/gpadmin/runtime/select.sql <<EOF
select * from test_table;
EOF
cat > /home/gpadmin/runtime/gpload.table.yaml <<EOF
VERSION: 1.0.0.1
DATABASE: $TEST_DATABASE_NAME
USER: $GP_USER
HOST: $GP_HOST
PORT: $GP_PORT
GPLOAD:
  INPUT:
    - SOURCE:
        LOCAL_HOSTNAME:
          - $GP_HOST
        PORT_RANGE: [$GP_LOAD_PORT,$GP_LOAD_PORT]
        FILE:
          - /home/gpadmin/runtime/测试_table.csv
    - COLUMNS:
        - 'a': varchar
        - 'b': int
        - 'c': int
    - FORMAT: csv
    - DELIMITER: ','
    - HEADER: true
    - ERROR_LIMIT: 25
  OUTPUT:
    - TABLE: "test_table"
    - MODE: INSERT
    - MAPPING:
        'name': 'a'
        'value1': 'b'
        'value2': 'c'
EOF
cat > /home/gpadmin/runtime/测试_table.csv <<EOF
a,b,c
sd,2,3
asd,3,2
中文,5,6
另一行中文,7,8
EOF
export PGPASSWORD=$GP_PASSWORD
createdb -h $GP_HOST -p $GP_PORT --username $GP_USER $TEST_DATABASE_NAME
psql -h $GP_HOST -p $GP_PORT --username $GP_USER $TEST_DATABASE_NAME -f /home/gpadmin/runtime/create.table.sql
psql -h $GP_HOST -p $GP_PORT --username $GP_USER $TEST_DATABASE_NAME -f /home/gpadmin/runtime/select.sql
gpload -f /home/gpadmin/runtime/gpload.table.yaml
psql -h $GP_HOST -p $GP_PORT --username $GP_USER $TEST_DATABASE_NAME -f /home/gpadmin/runtime/select.sql