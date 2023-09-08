#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_disk_space.sh

echo  "\n Script: $SCRIPTNAME: Start Time : $st \n" > "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"

echo  "\n Disk Space on the server" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
echo  "\n ************************************************************************** \n" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
df -Ph >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
echo  "\n **************************************************************************" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')

sed -i "4s/^/\nTotal Execution Time (HH:MM:SS:MS)   :  $Exe\n/" $PGCRONLOGS/$DATE/pg_disk_space_$DATE.log
sed -i "3s/^/\nScript: $SCRIPTNAME: End Time   : $en /" $PGCRONLOGS/$DATE/pg_disk_space_$DATE.log

HIGH=75
CRITICAL=85

count=$(df -h | awk '{print $5}' | grep % | grep -v Use | sort -n | wc -l)

#for (( i="$count"; i>0; i-- ))
for i in $count
do
        space=$(df -h | awk '{print $5}' | grep % | grep -v Use | sort -n | head -$i | tail -1 |cut -d "%" -f1)
        partition=$(df -Ph | awk '{print $6}'| tail -$i | head -1)
        if   [ "$space" -gt "$CRITICAL" ]; then
                echo  "$partition is $space% Critical!" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
		 #mail -s "Critical Disk Space on Partition "$partition" Space: "$space%" - HOSTNAME=`hostname` " manoj.kathar@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log
               break;
        elif [ "$space" -gt "$HIGH" ]; then
                echo  "$partition is $space% High!" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
		 #mail -s "High Disk Space on Partition: "$partition" Space: "$space%" - HOSTNAME=`hostname` " manoj.kathar@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log
                break;
        else
                echo  "Disk space is normal" >> "$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log"
		#mail -s "Normal Disk Space - HOSTNAME=`hostname` " manoj.kathar@@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log
                break;
        fi
done

#mail -s "PostgreSQL Disk Space Information - HOSTNAME=`hostname` :: Database =$PGDATABASE :: Port=$PGPORT :: Data Directory= $PGDATA " manoj.kathar@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log
