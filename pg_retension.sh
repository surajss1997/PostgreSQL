#Created by Shreeyansh

#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_retension.sh

echo  "\nScript: $SCRIPTNAME: Start Time : $st\n" > "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\nRetention policy for PG CRON LOGS: \tDuration: 30 days" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n\t\tFollowing Log Directory would be removed" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
du -ch $PGCRONLOGS | tail -1 | awk '{print "\t\t\tTotal size Before removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
find $PGCRONLOGS -type d -daystart -mtime +30 -exec basename '{}' \; -quit | head -1 >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
#find $PGCRONLOGS -type d -daystart -mtime +30 -print0 | xargs -0 rm -rf
du -ch $PGCRONLOGS | tail -1 | awk '{print "\t\t\tTotal size After removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log" # add new
echo  "**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\nRetention policy for PG BACKUPS: \tDuration: 30 days" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n\t\tFollowing Backup Directory would be removed" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
du -ch $PGBACKUP | tail -1 | awk '{print "\t\t\tTotal size Before removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
find $PGBACKUP -type d -daystart -mtime +30 -exec basename {} \; -quit | head -1 >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
#find $PGBACKUP -type d -daystart -mtime +30 -print0 | xargs -0  rm -rf
du -ch $PGBACKUP | tail -1 | awk '{print "\t\t\tTotal size After removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log" # add new
echo  "**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\nRetention policy for PG Online_Archive BACKUPS: \tDuration: 30 days" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

echo  "\n\t\tFollowing Online Backup Directory would be removed" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

du -ch $PGARCHBACKUP | tail -1 | awk '{print "\t\t\tTotal size Before removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
find $PGARCHBACKUP -type d -daystart -mtime +30 -exec basename {} \; -quit | head -1 >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"
#find $PGARCHBACKUP -type d -daystart -mtime +30 -print0 | xargs -0  rm -rf
du -ch $PGARCHBACKUP | tail -1 | awk '{print "\t\t\tTotal size after removal " $1}' >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log" # add new

echo  "**************************************************************************" >> "$PGCRONLOGS/$DATE/pg_retension_$DATE.log"

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')

sed -i "4s/^/\nTotal Execution Time (HH:MM:SS:MS)  :  $Exe\n/" $PGCRONLOGS/$DATE/pg_retension_$DATE.log

sed -i "3s/^/\nScript: $SCRIPTNAME: End Time   : $en /" $PGCRONLOGS/$DATE/pg_retension_$DATE.log


#mail -s "Retension "$partition" Space: "$space" - HOSTNAME=`hostname` " manoj.kathar@shreeyansh.com <$PGCRONLOGS/$DATE/pg_retension_$DATE.log


#/bin/sendEmail -f aaa@hcl.com -t manoj.kathar@shreeyansh.com -u "Retension Status" -o message -file=$PGCRONLOGS/$DATE/pg_retension_$DATE.log -s 192.168.92.102
