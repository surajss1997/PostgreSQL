#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=/tmp/pg_bloat_info.log
touch $logs
echo  "\n\t******************************************************************************************************" | tee -a $logs
echo  " \t\tScript created by : Shreeyansh DB Software Pvt Ltd"  | tee -a $logs
echo  " \t\tAuthor : Manoj Kathar(DBA)"
echo  " \t\tScript Description : This script use provides list of objects [Tables/Indexes] and their    \n\t\t\t\t     bloat percentage information in each database" | tee -a $logs
echo  " \t\tPostgreSQL Cluster Details\n\t\tDatabase Name = $PGDATABASE\n\t\tPort = $PGPORT\n\t\tData Directory = $PGDATA" | tee -a $logs
echo  " \t*******************************************************************************************************"
db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of available databases in production server ***************** "
echo  "\n$DATABASES"
echo  "\n Enter your database to get the bloated object information [postgres] : \c "
read db
}
tables_bloat_info()
{
db_info;
echo  "\nShows list of Tables with their bloat percentage in $db database:\n"
echo  "************************************************************************************\n"
#$PGHOME/bin/psql -U $PGUSER -d $db -p $PGPORT -h $HOSTNAME -c "SELECT relname AS \"Table Name\", relpages, pg_stat_get_live_tuples(pg_class.oid) AS \"Live Tuples\" , pg_stat_get_dead_tuples(pg_class.oid) AS \"Dead Tuples\",  pg_size_pretty(relpages::bigint*8*1024) AS size, round((pg_stat_get_dead_tuples(pg_class.oid))::numeric*100/(pg_stat_get_live_tuples(pg_class.oid))::numeric,2) as \"Bloat Percentage(%)\" FROM pg_class ,pg_catalog.pg_namespace n where n.oid = pg_class.relnamespace and relpages >= 8 and relkind='r' and n.nspname != 'pg_catalog' and pg_stat_get_dead_tuples(pg_class.oid) > 0 ORDER BY relpages DESC"
table_query="SELECT relname AS \"Table Name\", relpages, pg_stat_get_live_tuples(pg_class.oid) AS \"Live Tuples\" , pg_stat_get_dead_tuples(pg_class.oid) AS \"Dead Tuples\",  pg_size_pretty(relpages::bigint*8*1024) AS size, round((pg_stat_get_dead_tuples(pg_class.oid))::numeric*100/(pg_stat_get_live_tuples(pg_class.oid))::numeric,2) as Bloat_Percentage FROM pg_class ,pg_catalog.pg_namespace n where n.oid = pg_class.relnamespace and relpages >= 8 and relkind='r' and n.nspname != 'pg_catalog' and pg_stat_get_dead_tuples(pg_class.oid) > 0 ORDER BY relpages DESC"
$PGHOME/bin/psql -U $PGUSER -d $db -p $PGPORT -h $HOSTNAME -c "$table_query"

bloat=`$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -atc "select Bloat_Percentage from ($table_query) as ind"`
#echo "$bloat"

ind_per=25.00
if expr "$bloat" '>' "$ind_per" ;
then
echo "\n Bloat is >= $ind_per need to perform vacuum or vacuum full to remove dirty tuples "
else
echo "\n Bloat is <=$ind_per still vacuum not required"
fi 
echo  "\n************************************************************************************"


#echo -e "--------------------------------------------------------------------------------------"
#echo -e "Recommendation:\tConsider performing VACUUM for your bloated tables as per your maintenance window\n"
#echo -e "--------------------------------------------------------------------------------------"

}
index_bloat_info()
{
db_info;
echo -e "\nShows list of Indexes with their bloat percentage in $db database:\n"
index_query="WITH btree_index_atts AS (
    SELECT nspname, relname, reltuples, relpages, indrelid, relam,
        regexp_split_to_table(indkey::text, ' ')::smallint AS attnum,
        indexrelid as index_oid
    FROM pg_index
    JOIN pg_class ON pg_class.oid=pg_index.indexrelid
    JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    JOIN pg_am ON pg_class.relam = pg_am.oid
WHERE pg_am.amname = 'btree'
    ),
index_item_sizes AS (
    SELECT
    i.nspname, i.relname, i.reltuples, i.relpages, i.relam,
    s.starelid, a.attrelid AS table_oid, index_oid,
    current_setting('block_size')::numeric AS bs,
    /* MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?) */
    CASE
        WHEN version() ~ 'mingw32' OR version() ~ '64-bit' THEN 8
        ELSE 4
    END AS maxalign,
    24 AS pagehdr,
    /* per tuple header: add index_attribute_bm if some cols are null-able */
    CASE WHEN max(coalesce(s.stanullfrac,0)) = 0
        THEN 2
        ELSE 6
    END AS index_tuple_hdr,
    /* data len: we remove null values save space using it fractionnal part from stats */
    sum( (1-coalesce(s.stanullfrac, 0)) * coalesce(s.stawidth, 2048) ) AS nulldatawidth
    FROM pg_attribute AS a
    JOIN pg_statistic AS s ON s.starelid=a.attrelid AND s.staattnum = a.attnum
    JOIN btree_index_atts AS i ON i.indrelid = a.attrelid AND a.attnum = i.attnum
    WHERE a.attnum > 0
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
),
index_aligned AS (
    SELECT maxalign, bs, nspname, relname AS index_name, reltuples,
        relpages, relam, table_oid, index_oid,
      ( 2 +
          maxalign - CASE /* Add padding to the index tuple header to align on MAXALIGN */
            WHEN index_tuple_hdr%maxalign = 0 THEN maxalign
            ELSE index_tuple_hdr%maxalign
          END
        + nulldatawidth + maxalign - CASE /* Add padding to the data to align on MAXALIGN */
            WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
            ELSE nulldatawidth::integer%maxalign
          END
 )::numeric AS nulldatahdrwidth, pagehdr
    FROM index_item_sizes AS s1
),
otta_calc AS (
  SELECT bs, nspname, table_oid, index_oid, index_name, relpages, coalesce(
    ceil((reltuples*(4+nulldatahdrwidth))/(bs-pagehdr::float)) +
      CASE WHEN am.amname IN ('hash','btree') THEN 1 ELSE 0 END , 0 -- btree and hash have a metadata reserved block
    ) AS otta
  FROM index_aligned AS s2
    LEFT JOIN pg_am am ON s2.relam = am.oid
),
raw_bloat AS (
    SELECT current_database() as dbname, nspname, c.relname AS table_name, index_name,
        bs*(sub.relpages)::bigint AS totalbytes,
        CASE
            WHEN sub.relpages <= otta THEN 0
            ELSE bs*(sub.relpages-otta)::bigint END
            AS wastedbytes,
        CASE
            WHEN sub.relpages <= otta
            THEN 0 ELSE bs*(sub.relpages-otta)::bigint * 100 / (bs*(sub.relpages)::bigint) END
            AS realbloat,
       pg_relation_size(sub.table_oid) as table_bytes
        --,stat.idx_scan as index_scans
    FROM otta_calc AS sub
    JOIN pg_class AS c ON c.oid=sub.table_oid
    JOIN pg_stat_user_indexes AS stat ON sub.index_oid = stat.indexrelid
)
SELECT dbname as \"Database Name\", nspname as \"Schema Name\", table_name as \"Table Name\", pg_size_pretty(table_bytes) as \"Table Size\", index_name as \"Index Name\",
                pg_size_pretty(totalbytes::bigint) as \"Index Size\",
        pg_size_pretty(wastedbytes::bigint) as \"Bloat Size\",
                round(realbloat, 1) as Bloat_Percentage
                FROM raw_bloat
WHERE ( realbloat > 0 ) --and wastedbytes > 50000000 )
ORDER BY wastedbytes DESC"

$PGHOME/bin/psql -U $PGUSER -d $db -p $PGPORT -c "$index_query"

bloat=`$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -atc "select Bloat_Percentage from ($index_query) as ind"`
#echo "$bloat"

ind_per=25.00
if expr "$bloat" '>' "$ind_per" ;
then
echo "\n Recommedation : Index Bloat is >= $ind_per need to perform reindexing "
else
echo "\n Bloat is <=$ind_per still reindexing not required"
fi 
echo  "\n************************************************************************************"

}
echo  "\nPlease select your options to verify bloated objects in production(DB) server \n\n1.Bloated Tables Information in Server \n2.Bloated Indexes Information in Server\n3.Exit"
echo  "Your choice[3]: \c"
read ch
case $ch in 
1) tables_bloat_info;
;;
2) index_bloat_info;
;;
3)exit;
;;
esac

<<comment1
choice=${choice:-3}
if [ $choice -eq 1 ]
then
echo -e "\nPlease enter % of bloat for tables[10]: \c"
read tab_per
tab_per=${tab_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $tab_per% of bloat\n"
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select * from (
SELECT relname AS \"Table Name\", relpages, pg_stat_get_live_tuples(pg_class.oid) AS \"Live Tuples\" , pg_stat_get_dead_tuples(pg_class.oid) AS \"Dead Tuples\",  pg_size_pretty(relpages::bigint*8*1024) AS size, round((pg_stat_get_dead_tuples(pg_class.oid))::numeric*100/(pg_stat_get_live_tuples(pg_class.oid))::numeric,2) as \"Bloat Percentage(%)\"
        FROM pg_class ,pg_catalog.pg_namespace n
        where n.oid = pg_class.relnamespace and
        relpages >= 8 and relkind='r' and n.nspname != 'pg_catalog' and pg_stat_get_dead_tuples(pg_class.oid) > 0 and pg_stat_get_live_tuples(pg_class.oid) > 0
        ORDER BY relpages DESC) as temp where \"Bloat Percentage(%)\" >= $tab_per"
#echo -e "\nDo you want to remove dead tuples from table[y]: \c"
#read tab_choice
#tab_choice=${tab_choice:-y}
echo -e "--------------------------------------------------------------------------------------"


echo -e "Recommendation:\nConsider performing VACUUM for your bloated tables as per your maintenance window\n"
echo -e "--------------------------------------------------------------------------------------"
fi
if [ $choice -eq 2 ]
then
echo -e "\nPlease enter % of bloat for Indexes[10]:\c "
read ind_per
ind_per=${ind_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $ind_per% of bloat\n"
echo -e "\n************************************************************************************"

echo -e "\nPlease select option to verify individual bloated objects\n\n1.Table\n2.Index\n3.Exit"
echo -e "Your choice[3]: \c"
read choice
choice=${choice:-3}
if [ $choice -eq 1 ]
then
echo -e "\nPlease enter % of bloat for tables[10]: \c"
read tab_per
tab_per=${tab_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $tab_per% of bloat\n"
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select * from (
SELECT relname AS \"Table Name\", relpages, pg_stat_get_live_tuples(pg_class.oid) AS \"Live Tuples\" , pg_stat_get_dead_tuples(pg_class.oid) AS \"Dead Tuples\",  pg_size_pretty(relpages::bigint*8*1024) AS size, round((pg_stat_get_dead_tuples(pg_class.oid))::numeric*100/(pg_stat_get_live_tuples(pg_class.oid))::numeric,2) as \"Bloat Percentage(%)\"
        FROM pg_class ,pg_catalog.pg_namespace n
        where n.oid = pg_class.relnamespace and
        relpages >= 8 and relkind='r' and n.nspname != 'pg_catalog' and pg_stat_get_dead_tuples(pg_class.oid) > 0 and pg_stat_get_live_tuples(pg_class.oid) > 0
        ORDER BY relpages DESC) as temp where \"Bloat Percentage(%)\" >= $tab_per"
#echo -e "\nDo you want to remove dead tuples from table[y]: \c"
#read tab_choice
#tab_choice=${tab_choice:-y}
echo -e "--------------------------------------------------------------------------------------"
echo -e "Recommendation:\nConsider performing VACUUM for your bloated tables as per your maintenance window\n"
echo -e "--------------------------------------------------------------------------------------"
fi
if [ $choice -eq 2 ]
then
echo -e "\nPlease enter % of bloat for Indexes[10]:\c "
read ind_per
ind_per=${ind_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $ind_per% of bloat\n"
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select * from ($index_query) as ind where  \"Bloat Perentage(%)\" > $ind_per"
read tab_per
tab_per=${tab_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $tab_per% of bloat\n"
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select * from (
SELECT relname AS \"Table Name\", relpages, pg_stat_get_live_tuples(pg_class.oid) AS \"Live Tuples\" , pg_stat_get_dead_tuples(pg_class.oid) AS \"Dead Tuples\",  pg_size_pretty(relpages::bigint*8*1024) AS size, round((pg_stat_get_dead_tuples(pg_class.oid))::numeric*100/(pg_stat_get_live_tuples(pg_class.oid))::numeric,2) as \"Bloat Percentage(%)\"
        FROM pg_class ,pg_catalog.pg_namespace n
        where n.oid = pg_class.relnamespace and
        relpages >= 8 and relkind='r' and n.nspname != 'pg_catalog' and pg_stat_get_dead_tuples(pg_class.oid) > 0 and pg_stat_get_live_tuples(pg_class.oid) > 0
        ORDER BY relpages DESC) as temp where \"Bloat Percentage(%)\" >= $tab_per"
#echo -e "\nDo you want to remove dead tuples from table[y]: \c"
#read tab_choice
#tab_choice=${tab_choice:-y}
echo -e "--------------------------------------------------------------------------------------"
echo -e "Recommendation:\nConsider performing VACUUM for your bloated tables as per your maintenance window\n"
echo -e "--------------------------------------------------------------------------------------"
fi
if [ $choice -eq 2 ]
then
echo -e "\nPlease enter % of bloat for Indexes[10]:\c "
read ind_per
ind_per=${ind_per:-10}
echo -e "\n************************************************************************************"
echo -e "\nFollowing objects having more than $ind_per% of bloat\n"
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select * from ($index_query) as ind where  \"Bloat Perentage(%)\" > $ind_per"
echo -e "--------------------------------------------------------------------------------------"
echo -e "Recommendation:\nConsider performing REINDEX for your bloated Indexes as per your maintenance window"
echo -e "--------------------------------------------------------------------------------------"
fi  
if [ $choice -eq 3 ] 
then
echo -e "\n"
exit
fi
comment1








