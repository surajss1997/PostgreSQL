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
echo "\n"
script="select pid AS \"PID\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\", state, query AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by pid limit 25"
#$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select query AS \"Query\" from pg_stat_activity limit 1" | wc -l

#$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid AS \"PID\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\", state, query AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by pid limit 25"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script"
echo -e "\n*************************************************************************************************\n"
echo -e " Please enter your option kill $min  minutes long running queries\n 1. All pid \n 2. Enter pid's to kill long running queries \n 3. exit"
read op
case $op in
1) read -p "Are you sure to kill all long running queries (y/n)...? " yn 
   case $yn in
        [Yy]* ) $PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from ($script) as scr"
        ;;
        [Nn]* ) exit;;
   esac
;;
2) echo -e "Please enter comma seperated pid's of kill long running queries: \c"
read pid
pid=${pid:-0,0}
if [ "$pid" = "0,0" ]
then
echo -e "\nNo pid supplied exiting\n"
else
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from ($script) as sc where pid in ($pid)" 
fi
;;
3) exit
;;
esac 

