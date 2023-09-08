#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_logs_cleanup.sh

echo  "\nScript: $SCRIPTNAME: Start Time : $st\n" > "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"

echo  "\nRetention policy for pg_logs: \t\tDuration: 15 days" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "*******************************************************************************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"

echo  "\n\t\t\t\t*****************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "\t\t\t\t*  Following Database Server logs would be removed  *" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "\t\t\t\t*****************************************************\n" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "*****************************************************************************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
find $PGLOGS -name "*postgresql-*.log" -daystart -ctime +15 -exec ls -l {} \; >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
#find $PGLOGS -name "postgresql-*.log" -daystart -ctime +15 -exec rm -r {} \;

echo  "*******************************************************************************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "\n\t\t\t\t\t***********************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "\t\t\t\t\t*  Available Datbase server logs  *" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "\t\t\t\t\t***********************************\n" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "*****************************************************************************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
find $PGLOGS -name "*.log" -exec ls -l {} \; >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"
echo  "*****************************************************************************************************************" >> "$PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log"

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
#echo -e "Execution Time: \c"
#Exe=`echo $((END-START)) | awk '{print int($1/60)":"int($1%60)}'`

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')

sed -i "4s/^/\nTotal Execution Time (HH:MM:SS:MS)     :  $Exe\n/" $PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log

sed -i "3s/^/\nScript: $SCRIPTNAME: End Time   : $en /" $PGCRONLOGS/$DATE/pg_logs_cleanup_$DATE.log




