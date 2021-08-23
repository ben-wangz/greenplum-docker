#! /bin/bash

set -x
set -e

source /usr/local/greenplum-db-6.8.1/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/opt/greenplum/data/master/gpseg-1
export PGPORT=5432
export PGUSER=gpadmin
export PGPASSWORD=gparray
export PGDATABASE=${DATABASE_NAME:-gpdb}

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

cat > /home/gpadmin/runtime/gpload.test.table.yaml <<EOF
VERSION: 1.0.0.1
DATABASE: mydatabase
USER: gpadmin
HOST: gpmaster
PORT: 5432
GPLOAD:
  INPUT:
    - SOURCE:
        LOCAL_HOSTNAME:
          - test
        PORT_RANGE: [60000,61000]
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

createdb -h gpmaster -p 5432 mydatabase
psql -h gpmaster mydatabase -f /home/gpadmin/runtime/create.table.sql
psql -h gpmaster mydatabase -f /home/gpadmin/runtime/select.sql
gpload -f /home/gpadmin/runtime/gpload.test.table.yaml
psql -h gpmaster mydatabase -f /home/gpadmin/runtime/select.sql