#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

#find $LOG -name "vacuum_analyze_*" -mtime 0 -exec rm -r {} \;

#LOGFILE=vacuum_analyze_`date +"%Y-%m-%d-%T"`.log

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_vacuum_all.sh
echo  "******************************************************************************************************\n" > $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
echo  "Script: $SCRIPTNAME: Start Time:  `date`\n" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

echo   "\n\n\nPostgreSQL Cluster Details:\nPort = $PGPORT \nData Directory = $PGDATA" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
#echo -e "\nUser Details \nUser Name = $PGUSER\n" >>$PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
#echo psql -tc "SELECT datname AS "Database",pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';"

echo  "\n*************************************** Before Vacuuming Databases and Size ***************************\n" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

$PGHOME/bin/psql -tc "SELECT datname AS "Database",pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

#$PGHOME/bin/psql -tc "SELECT pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

START1=$(date +%s)
DATABASES=`$PGHOME/bin/psql  -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`

for i in $DATABASES; do

echo  "\n*********************************** Vacuuming the database $i ***********************************\n" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
START=$(date +%s)
$PGHOME/bin/vacuumdb -d $i -z -v -U $PGUSER -p $PGPORT >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log 2>&1

echo  "\n******************************* Vacuum for database $i is done *******************************" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')
#Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N") #| awk '{print " "$1" "hr:" "$2" "min:" "$3" "sec" "$5" "$6" "}')

#END=$(date +%s)
#DIFF=$(( $END - $START ))
#echo -e "\nTime required for $i vacuum is:: $Exe" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
done

echo  "\n*************************************** After Vacuuming Databases and Size ***************************\n" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log
$PGHOME/bin/psql -tc "SELECT datname AS "Database",pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

#END1=(date +%s)
#DIFF1=$(( $END1- $START1))
#echo -e "\n\nTotal time required for Vacuuming : $DIFF1 sec" >> $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

sed -i "5s/^/Total Execution Time (HH:MM:SS:MS)  :  $Exe/" $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

sed -i "4s/^/\nScript: $SCRIPTNAME: End Time  : $en\n /" $PGCRONLOGS/$DATE/pg_vacuum_all_$DATE.log

#mail -s "Vacuum - HOSTNAME=`hostname` :: Port=$PGPORT :: Data Directory=$PGDATA" dba@shreeyansh.com< $PGCRONLOGS/$DATE/Vacuum_log.log

