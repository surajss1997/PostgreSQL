#!/bin/bash
source /var/lib/pgsql/script/pg_env_94.sh
logs=$PGCRONLOGS/$DATE/pg_blocking_pid_$DATE.log
echo "" > $logs
echo -e "\n\t******************************************************************************************************" | tee -a $logs
echo -e " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo -e " \t\tAuthor : Manoj Kathar(DBA)"
echo -e " \t\tScript Description : Script to find sessions that are blocking other sessions in PostgreSQL " | tee -a $logs
echo -e " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo -e " \t*******************************************************************************************************" 

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT pl.pid as blocked_pid, psa.usename as blocked_user, pl2.pid as blocking_pid ,psa2.usename as blocking_user ,psa.query as blocked_statement FROM pg_catalog.pg_locks pl JOIN pg_catalog.pg_stat_activity psa ON pl.pid = psa.pid JOIN pg_catalog.pg_locks pl2 JOIN  pg_catalog.pg_stat_activity psa2 ON pl2.pid = psa2.pid ON pl.transactionid = pl2.transactionid AND pl.pid != pl2.pid WHERE NOT pl.granted;" | tee -a $logs

