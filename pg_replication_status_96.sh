#             scripts is created by Shreeyansh DB Software Pvt Ltd.                                                                                                                                 
#             Author Name: Emilesh                                                                                                                                                                                               
#             Script Name: pg_replication_status.sh                                                                                                                                                                                                    
#             Version 1.0                                                                                                                                                                                                
#             This script is used for checking the idle connections in the transaction.
################################################################################################################################

#!/bin/bash
#TIME=$(date +"%T.%2N")
#DATE=`date +%Y-%m-%d`
SCRIPTNAME=pg_replication_status.sh
home=$(pwd)

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh

LOG=$PGCRONLOGS/$DATE/pg_replication_lag_$DATE.log
echo "\n" > $LOG
start_time()
{
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
echo "*******************Name of the script: $SCRIPTNAME  Script Start Time:$st*************************" | tee -a $LOG
}

end_time()
{
END=$(date +"%T.%3N");
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
echo "*******************Name of the script: $SCRIPTNAME  Script End Time:$en*************************" | tee -a $LOG
}

exec_time()
{
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N")
echo "Total Execution Time :$Exe" | tee -a $LOG 
}

start_time;

echo "\nMonitoring the standby on Master side" | tee -a $LOG
$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -h $HOSTNAME -p $PGPORT -c "select * from pg_stat_replication;" | tee -a $LOG

echo "\nFollowing details tells whether standby is still in recovery mode or not" | tee -a $LOG

$PGHOME/bin/psql -p $REPPORT -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -c "select pg_is_in_recovery();" | tee -a $LOG

echo "Following details tells location of current transaction log which was streamed send by master.\n" | tee -a $LOG

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $REPUSER -h $HOSTNAME -c "SELECT pg_current_xlog_location();" | tee -a $log
echo "Following details tells location of last transaction log which was streamed by Standby and also written on standby disk.\n" | tee -a $LOG

$PGHOME/bin/psql -p $REPPORT -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -c "select pg_last_xlog_receive_location();" | tee -a $LOG

echo "Following details tells last transaction replayed during recovery process." | tee -a $LOG

$PGHOME/bin/psql -p $REPPORT -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -c "select pg_last_xlog_replay_location();" | tee -a $LOG

echo "Following details tells about the time stamp of last transaction which was replayed during recovery" | tee -a $LOG

$PGHOME/bin/psql -p $REPPORT -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -c "select pg_last_xact_replay_timestamp();" | tee -a $LOG

echo "Following details tells about Lags in Bytes i.e how far off is the Standby from Master." | tee -a $LOG

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -h $HOSTNAME -c "select pg_xlog_location_diff(pg_stat_replication.sent_location, pg_stat_replication.replay_location) as lag_bytes_delay from pg_stat_replication;" | tee -a $LOG

echo "Following details tells about lags in Seconds i.e how far off is the Standby from slave." | tee -a $LOG

$PGHOME/bin/psql -p $REPPORT -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -c "SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS lag_time_delay;" | tee -a $LOG

end_time;
exec_time;
