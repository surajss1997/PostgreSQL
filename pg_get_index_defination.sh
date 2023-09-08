
#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_indexes_stat_$DATE.log
touch $logs
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj Kathar " | tee -a $logs
echo " \t\tScript Description : This is script to findout create index defination in each schema" | tee -a $logs
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

echo " \t****** create index defination in each schema*******\n"

script="SELECT pg_get_indexdef(idx.indexrelid) || ';' FROM pg_stat_all_indexes i JOIN pg_class c ON (c.oid = i.relid) JOIN pg_namespace n ON (n.oid = c.relnamespace) JOIN pg_index idx ON (idx.indexrelid =  i.indexrelid ) WHERE i.schemaname NOT LIKE 'pg_%' and i.schemaname <> 'information_schema' AND NOT idx.indisprimary AND NOT idx.indisunique ORDER BY n.nspname, i.relname;"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script" |tee -a $logs

echo "\t************ create index defiantion for primary key in each schema *************\n"
script1="SELECT pg_get_indexdef(idx.indexrelid) || ';' FROM pg_stat_all_indexes i JOIN pg_class c ON (c.oid = i.relid) JOIN pg_namespace n ON
(n.oid = c.relnamespace) JOIN pg_index idx ON (idx.indexrelid =  i.indexrelid ) WHERE i.schemaname NOT LIKE 'pg_%' and i.schemaname <> 'informat
ion_schema' AND idx.indisprimary ORDER BY n.nspname, i.relname;"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script1" |tee -a $logs

end_time
exec_time
