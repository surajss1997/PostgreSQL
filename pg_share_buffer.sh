#!/bin/bash
# Organization : shreeyansh
# Author : Manoj Kathar
script_description="Script to check the status of Shared Buffer (Use pg_buffercache)"
echo "$script_description"

#source /opt/PostgreSQL/9.5/pg_env96.sh
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "copy (SELECT c.relname, count(*) AS buffers FROM pg_buffercache b INNER JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid) AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database())) GROUP BY c.relname ORDER BY 2 DESC) to '/tmp/share.csv' WITH DELIMITER '|' CSV HEADER;"

cat /tmp/share.csv
