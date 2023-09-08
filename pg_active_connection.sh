#!/bin/bash
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_active_connections_$DATE.log
echo "" > $logs
echo -e "\n\t******************************************************************************************************" | tee -a $logs
echo -e " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo -e " \t\tAuthor : Manoj Kathar(DBA)"
echo -e " \t\tScript Description : Script to find active sessions or connections in PostgreSQL " | tee -a $logs
echo -e " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo -e " \t*******************************************************************************************************" |tee -a $logs 

n=`$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -Atc "select count(*) from pg_stat_activity where state <>'idle' AND pid<>pg_backend_pid();"`

if [ $n -eq 0 ]
then
echo -e "\nNo Session in active/running state\n"
else
echo -e "\nFollowing $n sessions are in state: Active\n"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select datname as \"Database\" ,usename as \"User Name\",pid as \"Pid\",query_start as \"Start Time\",now()- query_start as \"Running Since\",substr(query,1,50) as \"Query\", backend_xid as \"Transaction Id\", state from pg_stat_activity where state <>'idel' AND pid<>pg_backend_pid();"
fi
