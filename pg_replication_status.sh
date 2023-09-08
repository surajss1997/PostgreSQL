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

. $home/pg_env_10.sh

LOG=$SLOG/pg_replication_status.log

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

if [ -d $SLOG ]

then

    echo "PG replication status log present under $SLOG" | tee -a $LOG

else

    mkdir $SLOG

    echo "PG replication status log present under $SLOG" | tee -a $LOG

fi

echo "Monitoring the standby on Master side" | tee -a $LOG

psql -d $PGDATABASE -U $PGUSER -h $HOSTNAME -p $PGPORT -c "select * from pg_stat_replication;" | tee -a $LOG

echo "-:Replication Summery:-"

psql -d $PGDATABASE -U $PGUSER -h $HOSTNAME -p $PGPORT -c "select  pid, client_addr, state, sync_state, pg_wal_lsn_diff(sent_lsn, write_lsn) as write_lag, pg_wal_lsn_diff(sent_lsn, flush_lsn) as flush_lag, pg_wal_lsn_diff(sent_lsn, replay_lsn) as replay_lag from pg_stat_replication ;"

echo "Following details tells whether standby is still in recovery mode or not" | tee -a $LOG

psql -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -p $REPPORT -c "select pg_is_in_recovery();" | tee -a $LOG

echo "Following details tells location of last transaction log which was streamed by Standby and also written on standby disk." | tee -a $LOG

psql -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -p $REPPORT -c "select pg_last_wal_receive_lsn();" | tee -a $LOG

echo "Following details tells last transaction replayed during recovery process." | tee -a $LOG

psql -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -p $REPPORT -c "select pg_last_wal_replay_lsn();" | tee -a $LOG

echo "Following details tells about the time stamp of last transaction which was replayed during recovery" | tee -a $LOG

psql -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -p $REPPORT -c "select pg_last_xact_replay_timestamp();" | tee -a $LOG

echo "Following details tells about Lags in Bytes i.e how far off is the Standby from Master." | tee -a $LOG

psql -d $PGDATABASE -U $PGUSER -h $HOSTNAME -p $PGPORT -c "select pg_wal_lsn_diff(pg_stat_replication.sent_lsn, pg_stat_replication.replay_lsn) from pg_stat_replication;" | tee -a $LOG

echo "Following details tells about lags in Seconds i.e how far off is the Standby from Master." | tee -a $LOG

psql -d $PGDATABASE -U $REPUSER -h $REPHOSTNAME -p $REPPORT -c "SELECT CASE WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() THEN 0 ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp()) END AS log_delay;" | tee -a $LOG

end_time;
exec_time;
