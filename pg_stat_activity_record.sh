#!/bin/bash
source /var/lib/pgsql/script/pg_env_94.sh
logs=$PGCRONLOGS/$DATE/pg_stat_activity_$DATE.log
echo "" > $logs
echo -e "\n\t******************************************************************************************************" | tee -a $logs
echo -e " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo -e " \t\tAuthor : Manoj Kathar(DBA)"
echo -e " \t\tScript Description : This script use to record pg activities within provided time interval " | tee -a $logs
echo -e " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo -e " \t*******************************************************************************************************" 
read -p "enter your time into minutes to execute :" mins 
m=$(expr $mins \* 60) ## convert min into seconds
read -p "enter your time in seconds to iterate the same commands :" sc # time for repeative command  
endTime=$(( $(date +%s) + $m )) # Calculate end time.
while [ $(date +%s) -lt $endTime ]; do  # Loop until interval has elapsed.
dt=$(date +"%A %d %B %Y %H:%M:%S %Z") 
echo "$dt (every $sc seconds)"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid, client_hostname as hostname, backend_start, xact_start, query_start, waiting, state, query from pg_stat_activity;" >> $logs
sleep $sc
done

