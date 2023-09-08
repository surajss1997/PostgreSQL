#!/bin/bash

#!/bin/bash
source /var/lib/pgsql/script/pg_env_94.sh
logs=$PGCRONLOGS/$DATE/pg_top_activity_$DATE.log
echo "" > $logs
echo -e "\n\t******************************************************************************************************" | tee -a $logs
echo -e " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo -e " \t\tAuthor : Manoj Kathar(DBA)"
echo -e " \t\tScript Description : This script use to record top command activities to monitor load and cpu usage " | tee -a $logs
echo -e " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo -e " \t*******************************************************************************************************" 

/usr/bin/top -bc -U postgres -n 1 >> $logs
if [ $? -eq 0 ]
then
echo " top command successfully recorded" >> $logs
else
echo " top command recording fail" >> $logs
fi

