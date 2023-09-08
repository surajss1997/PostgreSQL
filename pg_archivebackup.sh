#!/bin/sh

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%s")

SCRIPTNAME=pg_archivebackup.sh

echo  "\nScript: $SCRIPTNAME  : Start Time : `date` \n" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

echo  "\n\n\n***************************ARCHIVE BACKUP*****************************\n" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

cd $PGARCH/

#find -type f -daystart -ctime 1 | xargs tar -cf $PGARCHBACKUP/$DATE/pg_archbackup_$DATE.tar

find -type f -daystart -mtime 1 | xargs tar -czf $PGARCHBACKUP/$DATE/pg_archbackup_$DATE.tar.gz

cd $PGARCHBACKUP/$DATE


echo  "\nArchive File Name : pg_archbackup_$DATE.tar.gz" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

echo  "Archive File Size : \c" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

du -h pg_archbackup_$DATE.tar.gz | awk '{print $1}' >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log


echo  "\nStatus of archive files under directory $PGARCH is :" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

TARCOUNT=`tar -tzf  $PGARCHBACKUP/$DATE/pg_archbackup_$DATE.tar.gz | wc -l`

DIRCOUNT=`find $PGARCH/* -daystart -mtime 1  | wc -l`

echo  "DIRCOUNT = $DIRCOUNT\nTARCOUNT = $TARCOUNT "  >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

if [ $TARCOUNT -eq $DIRCOUNT ]

then

echo  "Compared tar files with directory files both are same" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

cd $PGARCH/

find -daystart -mtime 1 -exec ls -l {} \; >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log
echo  "\n********************Deleting Above Mentioned Files*********************" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

#find -daystart -mtime 1 -exec rm -f {} \; >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

echo  "\nArchive Directory Status :" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

df -h $PGARCH >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

sed -i "3s/^/Script: $SCRIPTNAME  : End Time   : `date`  /" "$PGARCHBACKUP/$DATE/archiveinfo_$DATE.log"
#mail  " Archive backup is completed successfully!!!"
else
echo  "File count is different. Script is unsuccessful" >> $PGARCHBACKUP/$DATE/archiveinfo_$DATE.log

#mail  " Archive backup is not completed successfully!!!"

fi

END=$(date +"%s")

Exe=$(($END - $START))

Exe1=$(($Exe / 60))
Exe2=$(($Exe1 / 60))
Exe3=$(($Exe % 60))

sed -i "4s/^/\nTotal Execution Time (HH:MM:SS)     : $Exe2(Hrs):$Exe1(min):$Exe3(sec) /" "$PGARCHBACKUP/$DATE/archiveinfo_$DATE.log"
