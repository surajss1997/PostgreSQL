#!/bin/sh

#Created by Shreeyansh

. /home/postgres/SY_cronjobs/pg_env_10.sh

#abc=`cat $PGBACKUP/$DATE/pg_logicaldump_$DATE.log | wc -l`
#START=$(date +%s.%3N);
#echo -e "ABC"  > $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_logicalbackup.sh

echo  "***********************************************************************************************************" > $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

echo  "\nScript: $SCRIPTNAME: Start Time: $st\n" > "$PGBACKUP/$DATE/pg_logicalbackup_$DATE.log"

#echo -e "\nDatabase Dump Start Time :  \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#date >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#sed -i "2s/^/***************************************************BACKUP STARTED************************************************** \n/" $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo "-------------------------------------Backup Started-----------------------------------------" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo   "\n\n\n\n\nFollowing are the server Details\n\nCustomer Name = $CUSTNAME\nHost Name = $HOSTNAME\nDatabase name = $PGDATABASE \nPort = $PGPORT\n" > $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo "------------------------------------------------------------------------------" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo  "\nSize of Database: \n " >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
$PGHOME/bin/psql -tc "SELECT datname AS "Database",pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

#echo > /tmp/data-rsync-full-time.txt
#echo "Database Full Backup on  server.">> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo "------------------------------------------------------------------------------" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo -e "Database Dump Start Time :  \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#date >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log


# /bin/mv -v $LOGICAL_NEWDUMP/* $LOGICAL_OLDDUMP/

sed -i "1s/^/***********************************************************************************************************\n/" $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
sed -i "3s/^/Script: $SCRIPTNAME: Start Time: `date` \n/" $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

echo  "\n***********************************************Global Dump*************************************************\n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

$PGHOME/bin/pg_dumpall -p $PGPORT -g -v -f $PGBACKUP/$DATE/globaldump_$DATE.sql >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log 2>&1
echo  "\n********************************************************************************" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo -e "\n***********************************************************************************************************" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

GFILENAME=$PGBACKUP/$DATE/globaldump_$DATE.sql
GFILESIZE=$(stat -c%s "$GFILENAME")
GDUMPNAME=globaldump_$DATE.sql

echo  "\n\tGlobal Dump File Name: $GDUMPNAME \n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo  "\tGlobal Dump File Size: \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo " ${GFILESIZE} Bytes" >>  $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

DATABASES=`$PGHOME/bin/psql  -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`

for i in $DATABASES; do

echo  "\n***********************************************Logical Dump of $i DB************************************************\n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

$PGHOME/bin/pg_dump -v -p $PGPORT -d $i -Fc -f $PGBACKUP/$DATE/$i"_"$DATE.dump  >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log 2>&1

echo  "\n********************************************************************************" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

FILENAME=$PGBACKUP/$DATE/$i"_"$DATE.dump
FILESIZE=$(stat -c%s "$FILENAME")
DUMPNAME=$i"_"$DATE.dump
echo  "\n\tDump File Name: $DUMPNAME \n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo  "\tDump File Size: \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo " $((${FILESIZE}/1024/1024)) MB" >>  $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

done
<<comment1
#echo -e "\n\n***********************************************************************************************************" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

#echo -e "Database Dump End Time :\c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#date >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log        
#echo "------------------------------------------------------------------------------" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

#GFILENAME=$PGBACKUP/$DATE/globaldump_$DATE.sql
#GFILESIZE=$(stat -c%s "$GFILENAME")
#GDUMPNAME=globaldump_$DATE.sql

#echo -e "Global Dump File Name: $GDUMPNAME \n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo -e "Global Dump File Size: \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo " ${GFILESIZE} Bytes" >>  $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

#FILENAME=$PGBACKUP/$DATE/$i"_"$DATE.dump
#FILESIZE=$(stat -c%s "$FILENAME")
#DUMPNAME=$i"_"$DATE.dump
#echo -e "\nDump File Name: $DUMPNAME \n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo -e "Dump File Size: \c" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#echo " $((${FILESIZE}/1024/1024)) MB" >>  $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
comment1

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')
#Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N") #| awk '{print " "$1" "hr:" "$2" "min:" "$3" "sec" "$5" "$6" "}')

#END=$(date +%s.%3N);

#Exe=`echo $((END-START)) | awk '{print int($1/60)":"int($1%60)}'`
#Exe=`echo $((END-START)) | awk '{print ($1)":"int($1/60)":"int($1%60)}'`
sed -i "7s/^/Total Execution Time  (HH:MM:SS:MS)    : $Exe  \n/" $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

sed -i "5s/^/Script: $SCRIPTNAME: End Time  :$en /" $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

#echo $Exe
#s=$(ls -lah $PGBACKUP/$DATE/dump_$DATE.dump | awk '{ print $5}')
#s=$( stat -c %s $PGBACKUP/$DATE/dump_$DATE.dump)

#echo $s >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
#stat -s $PGBACKUP/$DATE/dump_$DATE.dump >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
echo  "\n***************************************************BACKUP COMPLETED**************************************************\n" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

cd $PGBACKUP/$DATE

echo  "Compress the below dump files and sql file using tar\t" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log
tar -cvf pg_logicalbackup_$DATE.tar *.dump globaldump_$DATE.sql >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

if [ $? = 0 ]
then

rm *.dump globaldump_$DATE.sql

echo  "\n********************************************************************************" >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

echo  "\nMerged all dump and sql files into pg_logicalbackup_$DATE.tar "  >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

echo  "\nTar File Size : \c " >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

du -h $PGBACKUP/$DATE/pg_logicalbackup_$DATE.tar | awk '{print $1}'  >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

else

echo  "\nTar is Unsuccessful   : \c " >> $PGBACKUP/$DATE/pg_logicalbackup_$DATE.log

fi
#cd $PGBACKUP/$DATE/
#tar --remove-files -cf pglogical_$DATE.tar *.dump globaldump_$DATE.sql pg_logicalbackup_$DATE.log 

