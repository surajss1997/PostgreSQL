#!/bin/sh

. /home/postgres/SY_cronjobs/pg_env_10.sh

date1=$(date +"%s")

echo   "Following are the server Details\nDatabase name=$PGDATABASE \nPort = $PGPORT \nLocation of Data Directory = $PGDATA" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

echo  "\nUser Details \nUser Name =$REPUSER\n" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

echo " online back is started at time ::: $TODAY" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

#$PGHOME/bin/pg_basebackup -h $HOSTNAME -PR -p $PGPORT -x -Ft -D $BACKUP_DIR/pgbackup_$DATE  -v -U $REPUSER >> $PGBACKUP/$DATE/onlinebackup_$DATE.log 1>&2

$PGHOME/bin/pg_basebackup -h $HOSTNAME -PR -p $PGPORT -X stream -Ft -D $PGBACKUP/$DATE/online_backup_$DATE -v -U $PGUSER 2>&1 >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

date2=$(date +"%s")

diff=$(($date2-$date1))

echo " Time required for completion of this backup ::$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

#echo " online back is completed at time ::: ($diff / 60) minutes" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

echo " online back is stored at $BACKUP_DIR/pgbackup_$DATE" >> $PGBACKUP/$DATE/onlinebackup_$DATE.log

# Online Backup file Retention policy will be 3 days

#find $BACKUP_DIR/* -name "pgbackup_*" -ctime +3 -exec ls -l {} \;>> $ONLINE_LOG/retention_$DATE.log

#find $BACKUP_DIR/* -name "pgbackup_*" -ctime +3 -exec rm -r {} \;
