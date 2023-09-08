#!/bin/bash
#created by shreeyansh
. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pgbadger.sh
echo  "\n!!********************************************************************************!!" > "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
echo  "\nScript: $SCRIPTNAME: Start Time: $st\n" >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
echo  "\n\n!!********************************************************************************!!" >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
echo  "\nPostgreSQL Cluster Details\n\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\n">> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
mkdir -p $PGCRONLOGS/$DATE/pgbadger

# store all log files in one variable 

logs=`find $PGLOGS/ -name postgresql-*.log -daystart -ctime 1`
echo $logs >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"    

filecount=`find $PGLOGS/ -name postgresql-*.log -daystart -ctime 1 | wc -l`
echo $filecount >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"

prev_date=$(perl -e 'use POSIX;print strftime "%Y-%m-%d",localtime time-86400;')
 
echo  "\npgbadger analysis is in progress for above listed files\n">> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"

/usr/bin/pgbadger -f stderr $logs -o $PGCRONLOGS/$DATE/pgbadger/pgbadger_$prev_date.html >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log" 2>&1

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")

Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')
sed -i "7s/^/Total Execution Time (HH:MM:SS:MS) :  $Exe\n/" "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
sed -i "5s/^/\nScript: $SCRIPTNAME: End Time  : $en /" "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"

echo  "\nPlease see badger report: `find $PGCRONLOGS/$DATE/pgbadger/ -name pgbadger_$prev_date.html -daystart -ctime 0 `\n" >> "$PGCRONLOGS/$DATE/pgbadger_$DATE.log"
