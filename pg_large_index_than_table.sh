#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_large_index_size_$DATE.log
touch $logs
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj " | tee -a $logs
echo " \t\tScript Description : This is script to findout large index size greater than table each schema" | tee -a $logs
echo " \t\tscript name        : $0" | tee -a $logs  

echo "\t***********************************************************************************************************\n" | tee -a $logs

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

echo " \t ****** larger indexes size respective each of each table *******"
script="SELECT c.oid, s.nspname, c.relname as table, c.reltuples::int4 as rows, c.relpages as pages, pg_size_pretty (pg_relation_size(c.oid)) as table_size,(SELECT pg_size_pretty (SUM (pg_relation_size(indexrelid) )::INT8) FROM pg_index WHERE indrelid = c.oid) as index_size,pg_size_pretty (pg_total_relation_size(c.oid)) as total_table_size FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace s ON (relnamespace = s.oid) WHERE nspname not like 'pg_%' and nspname <> 'information_schema' AND relkind = 'r' GROUP BY 1, 2, 3, 4, 5, 6 HAVING pg_relation_size(c.oid) < (SELECT SUM (pg_relation_size(indexrelid) ) FROM pg_index WHERE indrelid = c.oid) ORDER BY (SELECT SUM (pg_relation_size(indexrelid) )::INT8  FROM pg_index WHERE indrelid = c.oid) DESC"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script" |tee -a $logs

end_time
exec_time
