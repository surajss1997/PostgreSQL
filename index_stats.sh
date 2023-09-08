
#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/index_stats_$DATE.log
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      :Manoj & Rajat " | tee -a $logs
echo " \t\tScript Description : This is Script to Find Index Statstics of all Table Of each Schemas" | tee -a $logs
echo " \t\tscript name        : Index Stats" | tee -a $logs  

echo "\t***********************************************************************************************************\n" | tee -a $logs

currentDate=`date`
echo $currentDate | tee -a $logs
echo " ************************** Index_Stastics **********************************\n" | tee -a $logs

start_time()
{
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
echo " ******************* Script Start Time: $START *************************\n "  | tee -a $logs
}
end_time()
{
END=$(date +"%T.%3N");
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
echo " ******************* Script END Date:$END ************************* \n "   | tee -a $logs
}
exec_time()
{
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N")
echo  " ********************** Total Execution Time :$Exe *************************** \n "   | tee -a $logs
}
start_time;

db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT  -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of Available Databases ***************** "
echo  "\n$DATABASES"
echo  "\n Enter Your Database Name[ex.postgres] : \c "
read db
}

db_info;
schemas_info()
{
SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select schema_name from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema');"`
echo  "\n **************** List of Available Schemas ***************** "
echo  "\n$SCHEMAS"
echo  "\n Enter Your Schema Name[ex.public] : \c "
read sc
}
schemas_info;
table_info()
{
TABLES=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select table_name from information_schema.tables where table_schema='$sc' and table_type='BASE TABLE';"`
echo  "\n **************** List of Available tables in  Schemas ***************** "
echo  "\n$TABLES"
echo  "\n Enter Your  Table Name[ex.public] : \c "
read tabl
}
table_info;



$PGHOME/bin/psql -p $PGPORT -d $db -c "SELECT schemaname as schema,relname AS table,indexrelname AS index,pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS index_size,idx_tup_read,idx_tup_fetch,idx_scan FROM pg_stat_user_indexes JOIN pg_index USING (indexrelid) where relname = '$tabl' ;"  | tee -a $logs

end_time
exec_time
