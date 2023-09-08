# Created by Shreeyansh

#!/bin/bash

source /var/lib/pgsql/script/pg_env_94.sh

echo -e "\nPostgreSQL Cluster  Details\n\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\n"

echo -e "\n*************************************************************************************************"
echo -e "\t\t\t\t\tWaiting Queries Information\n"

#echo -e "\nEnter database name: \c"
#read pgdb


echo -e "List of queries\n"

#$PGHOME/bin/psql -d $pgdb -c "select pid AS \"PID\", substr(query,1) AS \"Query\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='t' and now() - query_start > interval '5 minutes' and datname='$pgdb' order by pid limit 25"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid AS \"PID\", substr(query,1) AS \"Query\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\" from pg_stat_activity where waiting='t';"

#$PGHOME/bin/psql -d $pgdb  -U $PGUSER -p $PGPORT -c "select pid AS \"PID\",waiting AS \"Waiting\",query,query_start as start_time  from pg_stat_activity where waiting='t';"

echo -e "\n\nWhat action you want: \c "

echo -e "\n1. Kill All pids\n2. Kill pids Dynamically\n3. Exit"

echo -e "Enter your choice:\c"
read act


if [ "$act" -eq 1 ]
then
echo -e "\nAre you sure [ Y / N ]? \c"
read s

if [ "$s" = "Y" -o "$s" = "y" ] 
then

$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pg_terminate_backend(pid) from pg_stat_activity where waiting='t';"
echo -e "\n******Removed all The waiting queries******* "

$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pid,waiting,query from pg_stat_activity where waiting='t';"

elif [ "$s" = "n" -o "$s" = "N" ]
then

echo -e "No pid is killed"

fi
fi
 

if [ "$act" -eq 2 ]
then

echo -e "Please enter comma sepearted pid's of waiting sessions: \c"
read pid

pid=${pid:-0,0}

if [ "$pid" = "0,0" ]
then
echo -e "\nNo pid supplied exiting\n"
else
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from pg_stat_activity where waiting='t' and pid in ($pid)"
fi
fi
