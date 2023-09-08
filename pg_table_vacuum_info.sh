#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs="/tmp/pg_vacuum_info.log"
/usr/bin/touch $logs
echo "" > $logs
echo "\n********************************************************************************************" | tee -a $logs
echo " Script createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " Script author : Dipak Borse (DBA)" | tee -a $logs
echo " Script Description :  This script use find out table vacuuming information " | tee -a $logs
echo " script name : $0" | tee -a $logs
echo "\n********************************************************************************************" | tee -a $logs
db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n ************************** List of available databases *********************************** "
echo  "\n$DATABASES"
echo  "\n Enter your database : \c "
read db
}
table_info()
{
TABLES=`$PGHOME/bin/psql -p $PGPORT $db -c "select schemaname,tablename from pg_tables where schemaname not in ('pg_catalog','information_schema') order by schemaname;"`
echo "\n ****************************List of available Tables **************************************"
echo  "\n$TABLES"
echo "\n Enter your table : \c "
read tb
}

{
db_info;
table_info;
$PGHOME/bin/psql -p $PGPORT $db  -c "select u.schemaname as schema, u.relname as tablename, u.last_vacuum, u.last_autovacuum, u.last_analyze, u.last_autoanalyze, u.vacuum_count, u.autovacuum_count, u.analyze_count, u.autoanalyze_count from pg_stat_all_tables u where u.relname='$tb';"
}


