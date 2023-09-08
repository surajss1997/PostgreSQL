#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

#date> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_replication_lag.sh
echo  "\n*************************************[BEGIN]*************************************" > $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
echo  "\nScript: $SCRIPTNAME: Start Time          : $st\n" >> "$PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log"
echo  "\n\n\nMASTER PostgreSQL Cluster  Details\n\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\nHOST= $MASTER_IP" >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

echo  "\nSLAVE PostgreSQL Cluster  Details\n\nDatabase Name = $PGDATABASE \nPort = $REPPORT\nData Directory = $REPPGDATA\n" >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

#echo " Master is delayed by time: " >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

#$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -h $MASTER_IP -p $PGPORT -Atc " SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS log_delay;">> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

echo " Slave is delayed by time: "  >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $REPPORT -Atc " SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS log_delay;">> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

echo " Slave is delayed by bytes:" >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log

$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -Atc " select pg_wal_lsn_diff (pg_stat_replication.sent_lsn, pg_stat_replication.replay_lsn) from pg_stat_replication;" >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
echo  "\n" >> $PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
#Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N") #| awk '{print " "$1" "hr:" "$2" "min:" "$3" "sec" "$5" "$6" "}')
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')
sed -i "7s/^/Total Execution Time (HH:MM:SS:MS) :  $Exe/" "$PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log"
sed -i "5s/^/\nScript: $SCRIPTNAME: End Time  : $en /" "$PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log"


