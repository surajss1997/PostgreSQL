# Created by Shreeyansh

#!/bin/bash

source /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_94.sh 

echo -e "\n*************************************************************************************************"
echo -e "\t\t\t\tTransaction ID details which is imp to vacuuming table"

echo -e "\n**************** Current Transaction id **************************"

$PGHOME/bin/psql -c "select * from txid_current();"

echo -e "\n**************** transaction id age database level **************************"

$PGHOME/bin/psql -c "SELECT datname, age(datfrozenxid) FROM pg_database ORDER BY 2 DESC LIMIT 20;"


echo -e "\n**************** transaction id age tables level **************************"

$PGHOME/bin/psql -c "SELECT c.relname as table_name, c.relkind as type, age(c.relfrozenxid) as age, c.relfrozenxid FROM pg_class AS c WHERE age(c.relfrozenxid) <> 2147483647 ORDER BY 3 DESC LIMIT 20;"

echo -e "\n**************** display vacuum running queries(Before 9.5) **************************"

$PGHOME/bin/psql -c "SELECT datname, usename, pid, waiting, current_timestamp - xact_start AS xact_runtime, query FROM pg_stat_activity WHERE upper(query) like '%VACUUM%' and pid<>pg_backend_pid() ORDER BY xact_start;"

echo -e "\n**************** display vacuum running queries(After 9.5) **************************"

#$PGHOME/bin/psql -c "SELECT datname, usename, pid, wait_event_type, current_timestamp - xact_start AS xact_runtime, query FROM pg_stat_activity WHERE upper(query) like '%VACUUM%' and pid<>pg_backend_pid() ORDER BY xact_start;"
