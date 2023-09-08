
#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_indexes_stat_$DATE.log
touch $logs
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj & Rajat " | tee -a $logs
echo " \t\tScript Description : This is script to findout tables statstics of all tablea in each schema" | tee -a $logs
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

script="SELECT n.nspname, s.relname, c.reltuples::bigint, c.relpages::bigint, -- n_live_tup, 
n_tup_ins, n_tup_upd, n_tup_del, n_dead_tup ,
date_trunc('second', last_vacuum) as last_vacuum, date_trunc('second', last_autovacuum) as last_autovacuum, date_trunc('second', last_analyze) as last_analyze, date_trunc('second', last_autoanalyze) as last_autoanalyze, round( current_setting('autovacuum_vacuum_threshold')::integer + current_setting('autovacuum_vacuum_scale_factor')::numeric * C.reltuples) AS av_threshold, pg_size_pretty(pg_relation_size(quote_ident(n.nspname) || '.' || quote_ident(s.relname) )) as size
/*,CASE WHEN reltuples > 0 THEN round(100.0 * n_dead_tup / (reltuples)) ELSE 0 END AS pct_dead, CASE WHEN n_dead_tup > round( current_setting('autovacuum_vacuum_threshold')::integer + current_setting('autovacuum_vacuum_scale_factor')::numeric * C.reltuples) THEN 'VACUUM'
ELSE 'ok' END AS "av_needed" 
*/
  FROM pg_stat_all_tables s
  JOIN pg_class c ON c.oid = s.relid
  JOIN pg_namespace n ON (n.oid = c.relnamespace)
 WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname <> 'information_schema'
--   AND s.relname LIKE '%TBL%'
-- AND n.nspname='public'
 ORDER by 1, 2;"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script" |tee -a $logs

end_time
exec_time
