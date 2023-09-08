#!/bin/sh

#Created by Shreeyansh

source /home/postgres/SY_cronjobs/pg_env_96.sh

echo -e "\n***********************************************Global Dump*************************************************\n" > /home/postgres/global_backup.log

$PGHOME/bin/pg_dumpall -v -p $PGPORT -s -f /home/postgres/global_backup.sql >> /home/postgres/global_backup.log 2>&1

echo -e "\n****************************************Global Dump Comleted *************************************************\n" >> /home/postgres/global_backup.log

