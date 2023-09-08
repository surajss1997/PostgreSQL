# Created by Shreeyansh

#!/bin/bash

source /var/lib/pgsql/script/pg_env_94.sh

echo -e "\n*************************************************************************************************"
echo -e "\t\t\t\tLong Running Queries Information"
#echo -e "\t\t\t\t Interval in Minutes = $min\n"
#echo -e "\nEnter Database Name [postgres]: \c"
#read db
#db=${db:-postgres}
echo -e "\nEnter Interval In Minutes[1]: \c"
read min
min=${min:-1}

echo -e "\n"

#$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select query AS \"Query\" from pg_stat_activity limit 1" | wc -l

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid AS \"PID\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\", state, query AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by pid limit 25"
echo -e "\n*************************************************************************************************\n"
