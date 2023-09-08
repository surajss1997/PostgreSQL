#!/bin/bash
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_top_activity_$DATE.log
echo "" > $logs
echo -e "\n\t******************************************************************************************************" | tee -a $logs
echo -e " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo -e " \t\tAuthor : Manoj Kathar(DBA)"
echo -e " \t\tScript Description : This script use to record top command activities to monitor load and cpu usage " | tee -a $logs
echo -e " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo -e " \t*******************************************************************************************************" 
val=2.0
#s=300
#endTime=$(( $(date +%s) + $s ))
#while [ $(date +%s) -lt $endTime ]; do
i=1
while true
do
ld=`uptime | awk '{printf $8}' | sed 's/,/ /g'`
if [ "$ld" \> "$val" ]
then
echo "\t\t\t**************************\n\
        \t\t* No of Occurence = $i    *\n\
        \t\t**************************" >> $logs
/usr/bin/top -bc -n 1 -U postgres >> $logs
i=$(expr $i + 1)
echo "\n" >> $logs
#else
#echo " load is normal so we can't record top command "
fi
sleep 3
done


