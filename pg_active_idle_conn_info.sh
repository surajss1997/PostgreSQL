#!/bin/bash
. /home/postgres/SY_dbascripts/pg_env_94.sh

echo -e "\n********************************************************************************************\n" 
echo " Script createdb by : Shreeyansh DB Software Pvt Ltd "
echo " Script author      : Mayuri Shinde " 
echo " Script Description : This script use find out the all the running queries & the queries in 'Active' & 'Idle' state" 
echo " script name        : $0"
echo -e "\n********************************************************************************************\n"


echo -e "\n\n******************* ||| Show all running queries running from more than 5 min ||| ******************************\n\n" 
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid, now() - query_start as "query_running_time", query_start as query_start_time, usename as user, waiting, state, query as running_query FROM  pg_stat_activity WHERE state <> 'idle' and now() - query_start > '5 minutes'::interval ORDER BY query_running_time DESC; "

echo -e "\n\n******************* ||| Show all Idle connections from more than 5 min ||| ****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid, now() - query_start as "idle_session_time", backend_start as session_start_time, usename as user, waiting, state as current_state, query as last_executed_query FROM pg_stat_activity WHERE state = 'idle'  and now() - query_start > '5 minutes'::interval ORDER BY idle_session_time DESC;"
