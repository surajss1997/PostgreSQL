#!/bin/sh

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%s")

SCRIPTNAME=pg_online_archivebackup.sh

echo  "\nScript: $SCRIPTNAME  : Start Time : `date` \n" > $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

echo  "\n\n\n***************************ONLINE BACKUP*****************************\n" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

$PGHOME/bin/pg_basebackup -h $HOSTNAME -P  -p $PGPORT -X stream -Ft -D $PGARCHBACKUP/$DATE/pgbackup_$DATE  -v -U $PGUSER >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

if [ $? -eq 0 ]

then

cd $PGARCHBACKUP/$DATE/pgbackup_$DATE

echo "\nOnline Backup File Name : pgbackup_$DATE" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

/bin/gzip base.tar --fast

echo  "File Size: \c" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log
du -h | awk '{print $1}' >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log


echo  "\n***************************ARCHIVE BACKUP*****************************\n" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

cd $PGARCH/

find -type f -daystart -mtime 1 | xargs tar -czf $PGARCHBACKUP/$DATE/pg_archbackup_$DATE.tar.gz

cd $PGARCHBACKUP/$DATE

#/usr/bin/bzip2 pg_archbackup_$DATE.tar -z
#/usr/bin/zip pg_archbackup_$DATE.tar.zip -m pg_archbackup_$DATE.tar

echo  "\nArchive File Name : pg_archbackup_$DATE.tar.gz" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

echo  "Archive File Size : \c" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

du -h pg_archbackup_$DATE.tar.gz | awk '{print $1}' >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

echo  "\nStatus of archive files under directory $PGARCH is :" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

TARCOUNT=`tar -tzf  $PGARCHBACKUP/$DATE/pg_archbackup_$DATE.tar.gz | wc -l`

DIRCOUNT=`find $PGARCH/* -daystart -mtime 1 | wc -l`

echo  "DIRCOUNT = $DIRCOUNT \n TARCOUNT = $TARCOUNT "  >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

if [ $TARCOUNT -eq $DIRCOUNT ]

then

echo  "Compared tar files with directory files both are same" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

cd $PGARCH/

find -daystart -mtime +1 -exec ls -l {} \; >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log
echo  "\n********************Deleting Above Mentioned Files*********************" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

find -daystart -mtime +1 -exec rm -f {} \; >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

echo  "\nArchive Directory Status :" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

df -h $PGARCH >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

else
echo  "File count is different" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

#mail  " Attention Online Backup is successfully completed but Archive Backup is Failed!!! DONT run this script again .Run the archive backup script"
#exit 0

fi

cd $PGARCHBACKUP/$DATE

tar -cf pg_online_archivebackup_$DATE.tar pg_archbackup_$DATE.tar.gz pgbackup_$DATE

if [ $? -eq 0 ]
then

rm -rf pg_archbackup_$DATE.tar.gz  pgbackup_$DATE

echo  "\n\nMerged pg_archbackup_$DATE.tar.gz, pgbackup_$DATE into pg_online_archivebackup_$DATE.tar" >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

echo  "\nFile Size   : \c " >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

du -h $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.tar | awk '{print $1}'  >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

END=$(date +"%s")

sed -i "3s/^/Script: $SCRIPTNAME  : End Time   : `date`  /" "$PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log"

Exe=$(($END - $START))

#mail  " All the backups are completed successfully!!!"

Exe1=$(($Exe / 60))
Exe2=$(($Exe1 / 60))
Exe3=$(($Exe % 60))

sed -i "4s/^/\nTotal Execution Time (HH:MM:SS)     : $Exe2(Hrs):$Exe1(min):$Exe3(sec) /" "$PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log"

else

echo  "\nTar is Unsuccessful and the backup files still exists on disk!!!  " >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

fi

else

echo  "Physical Backup is NOT completed successfully " >> $PGARCHBACKUP/$DATE/pg_online_archivebackup_$DATE.log

#rm -rf  $PGBACKUP/$DATE/pgbackup_$DATE

# mail -s "Online Archive Backup : "$partition" Space: "$space%" - HOSTNAME=`hostname` " neerajreddy.singadi@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log


# mail  " Attention Online Backup is UNSUCCESSFUL, Check the error and re run script"

fi

