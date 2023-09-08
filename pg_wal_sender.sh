# Created by Shreeyansh


#!/bin/bash

source /home/postgres/SY_cronjobs/pg_env_94.sh
echo -e "************************************************************************************"

a=`ps -ef | grep 'wal sender process' | awk '{print $9$10$11$12}' | wc -l` 

if [ $a -gt 1 ] 
then
b=`ps -ef | grep 'wal sender process' | awk '{print $9$10$11$12}' | head -1`

c=`expr substr $b 17 17`

if [ $c = "" ] 
then 
echo -e "\nNo WAL Sender Procedure exist"

else 
echo -e "\nWAL Sender Process exists with User $c\n"
fi
else 
echo -e "\nNo WAL sender Process Exists\n"

fi

