
#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_indexes_stat_$DATE.log
touch $logs
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj & Rajat " | tee -a $logs
echo " \t\tScript Description : This is script to findout index statstics of all tablea in each schema" | tee -a $logs
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

echo " \t****** List of Indexes and usages of  tables in each schema\n *******"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "SELECT schemaname as schema, relname AS tablename, indexrelname AS indexname, pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS index_size, idx_tup_read, idx_tup_fetch, idx_scan FROM pg_stat_user_indexes JOIN pg_index USING (indexrelid) order by schemaname;" | tee -a $logs
script="SELECT n.nspname as schema,i.relname as table,i.indexrelname as index,i.idx_scan,i.idx_tup_read,i.idx_tup_fetch,CASE WHEN idx.indisprimary     THEN 'pkey' WHEN idx.indisunique THEN 'uidx'ELSE 'idx'END AS type, /*pg_get_indexdef(idx.indexrelid, 1, FALSE) as idxcol1, pg_get_indexdef(idx.indexrelid, 2, FALSE) as idxcol2, pg_get_indexdef(idx.indexrelid, 3, FALSE) as idxcol3,
       pg_get_indexdef(idx.indexrelid, 4, FALSE) as idxcol4,
*/ CASE WHEN idx.indisvalid THEN 'valid' ELSE 'INVALID' END as statusi, pg_size_pretty(pg_relation_size(quote_ident(n.nspname) || '.' || quote_ident(i.relname) )) as size FROM pg_stat_all_indexes i JOIN pg_class c ON (c.oid = i.relid) JOIN pg_namespace n ON (n.oid = c.relnamespace) JOIN pg_index idx ON (idx.indexrelid =  i.indexrelid ) WHERE i.relname LIKE '%%' AND n.nspname NOT LIKE 'pg_%' -- AND n.nspname='public' -- AND idx.indisunique = TRUE -- AND NOT idx.indisprimary --   AND i.indexrelname LIKE 'tmp%' --   AND idx.indisvalid IS false 
/*   AND NOT idx.indisprimary AND NOT idx.indisunique AND idx_scan = 0
*/ ORDER BY 1, 2, 3;"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script" |tee -a $logs

script1="SELECT n.nspname as schema,i.relname as table,i.indexrelname as index,i.idx_scan,i.idx_tup_read,i.idx_tup_fetch,CASE WHEN idx.indisprimary     THEN 'pkey' WHEN idx.indisunique THEN 'uidx'ELSE 'idx'END AS type,pg_get_indexdef(idx.indexrelid, 1, FALSE) as idxcol1,
       pg_get_indexdef(idx.indexrelid, 2, FALSE) as idxcol2,
       pg_get_indexdef(idx.indexrelid, 3, FALSE) as idxcol3,
       pg_get_indexdef(idx.indexrelid, 4, FALSE) as idxcol4,
CASE WHEN idx.indisvalid THEN 'valid' ELSE 'INVALID' END as statusi, pg_size_pretty(pg_relation_size(quote_ident(n.nspname) || '.' || quote_ident(i.relname) )) as size FROM pg_stat_all_indexes i JOIN pg_class c ON (c.oid = i.relid) JOIN pg_namespace n ON (n.oid = c.relnamespace) JOIN pg_index idx ON (idx.indexrelid =  i.indexrelid ) WHERE i.relname LIKE '%%' AND n.nspname NOT LIKE 'pg_%' -- AND idx.indisunique = TRUE -- AND NOT idx.indisprimary --   AND i.indexrelname LIKE 'tmp%' --   AND idx.indisvalid IS false 
/*   AND NOT idx.indisprimary AND NOT idx.indisunique AND idx_scan = 0
*/ ORDER BY 1, 2, 3;"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script1" |tee -a $logs

end_time
exec_time
