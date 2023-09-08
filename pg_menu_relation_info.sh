#!/bin/bash -x           
echo "\n********************************************************************************************"
echo " Script createdb by : Shreeyansh DB Software Pvt Ltd "
echo " Script author : Manoj Kathar (DBA)"
echo " Script Description :  This script  use find out all logical relation information along with it's size " 
echo " script name : $0"
echo "\n********************************************************************************************"
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
#source /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
SCRIPTNAME="$0"
logs="/tmp/pg_relation_size.log"
/usr/bin/touch $logs
warning="Warning: Check all the query execution and test first execute on test environment and then execute on production"

all_db_size()
{
echo "$warning"
echo " All database information along with size :" 
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;"
}

db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of available databases ***************** "
echo  "\n$DATABASES"
echo  "\n Enter your database to get the size [postgres] : \c "
read db
}
particular_db_size()
{
echo "$warning"
db_info;
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') and datname='$db';"
}

all_table_size()
{
echo "$warning"
db_info;
script="select t.table_catalog as database, t.table_schema as schema, t.table_name as tablename, u.usename as owner,pg_size_pretty(pg_relation_size('' ||t.table_schema || '"."' || t.table_name ||'')) as size from information_schema.tables t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE' order by table_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script"
}

particular_table()
{
db_info;
script1="select table_catalog as database, table_schema as schema,table_name as table_name from information_schema.tables where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE' order by table_schema;"
TABLES=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script1"`
echo " \n ************ List of Available tables on each schema ********************\n "
echo "\n $TABLES"
echo " \n Enter Your table name to get the size : [public.test] : \c "
read tb
tb1=`echo "'$tb'"`
script2="select t.table_catalog as database, t.table_schema as schema, t.table_name as tablename, u.usename as owner,pg_size_pretty(pg_relation_size('' ||t.table_schema || '"."' || t.table_name ||'')) as size from information_schema.tables t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE'and table_name=$tb1 order by table_schema;"

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

particular_schema()
{
db_info;
SC=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "select nspname as schema_name from pg_namespace where nspname not like 'pg_%' and nspname not in ('information_schema');"`
echo "\n ****************** List of available schemas in $db database ******************\n"
echo "\n$SC"
echo "\n Enter your schema to get all schema size : \c"
read sc
sc1=`echo "'$sc'"`
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename))))::text as \"schema_size\" FROM pg_tables WHERE schemaname=$sc1;"
}

all_index_size()
{
db_info;
idx="select schemaname, tablename, indexname,pg_size_pretty(pg_indexes_size('' || schemaname || '"."' || tablename  || '')) AS index_size from pg_indexes where schemaname not like 'pg_%' and schemaname not in('information_schema');"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$idx"
}

particular_index_size()
{
db_info;
idx1="select schemaname, tablename, indexname from pg_indexes where schemaname not like 'pg_%' and schemaname not in('information_schema');"
INDEXES=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$idx1"`
echo " \n ************ List of Available tables and indexes on each schema ********************\n "
echo "\n $INDEXES"
echo " \n Enter Your index name to get the size : [public.test.idx1] : \c "
read ix
id1=`echo "'$ix'"`
script2="select schemaname, tablename, indexname,pg_size_pretty(pg_indexes_size('' || schemaname || '"."' || tablename  || '')) AS "size" from pg_indexes where indexname=$id1;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

all_table_index_size()
{
db_info;
script2="select schemaname, tablename,pg_size_pretty(pg_table_size('' || schemaname || '"."' || tablename  || '')) AS table_size, indexname,pg_size_pretty(pg_indexes_size('' || schemaname || '"."' || tablename  || '')) AS index_size from pg_indexes where schemaname not like 'pg_%' and schemaname not in('information_schema');"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

all_schema_size()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo " \n **************** List of available databases ***************** \n"
echo "\n$DATABASES"
echo "\n Enter your database to get all the schema size [postgres] : \c "
read db
sc1="SELECT schema_name, pg_size_pretty(sum(table_size)::bigint) as schema_size FROM (SELECT pg_namespace.nspname as schema_name, pg_relation_size(pg_class.oid) as table_size FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid where pg_namespace.nspname not like 'pg_%' and pg_namespace.nspname not in('information_schema'))t GROUP BY schema_name ORDER BY schema_name;"

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$sc1"
}
total_relation_size()
{
db_info;
#script2="SELECT table_schema || '.' || table_name AS TableName, pg_size_pretty(pg_total_relation_size('' || table_schema || '"."' || table_name || '')) AS TotalSize FROM information_schema.tables where table_schema not like 'pg_%' and table_schema not in('information_schema') And table_type='BASE TABLE' ORDER BY  pg_total_relation_size('' || table_schema || '"."' || table_name || '') DESC;"
script2="select t.table_catalog as database, p.schemaname, p.tablename,pg_size_pretty(pg_table_size('' || p.schemaname || '"."' || p.tablename  || '')) AS table_size, p.indexname,pg_size_pretty(pg_indexes_size('' || p.schemaname || '"."' || p.tablename  || '')) AS index_size,pg_size_pretty(pg_total_relation_size('' || p.schemaname || '"."' || p.tablename  || '')) AS TotalSize,u.usename as owner,p.tablespace from pg_indexes p join information_schema.tables t on (p.tablename=t.table_name) join pg_catalog.pg_class c on (p.tablename = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where p.schemaname not like 'pg_%' and p.schemaname not in ('information_schema');"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

all_views_size()
{
db_info;
#script="select table_catalog as database, table_schema || '.' || table_name as tablename, pg_size_pretty(pg_relation_size('' || table_schema || '"."' || table_name ||'')) from information_schema.tables where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='VIEW' order by table_schema;"
#$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "select table_catalog as database, table_schema || '\.' || table_name as tablename, pg_size_pretty(pg_table_size('"' || table_schema || '"\."' || table_name || '"')) from information_schema.tables where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE' order by table_schema;"
script="select t.table_catalog as database, t.table_schema as schema,t.table_name as viewname, t.check_option, t.is_updatable, t.is_insertable_into, t.is_trigger_updatable, t.is_trigger_deletable, t.is_trigger_insertable_into,u.usename as owner, pg_size_pretty(pg_relation_size('' || t.table_schema || '"."' || t.table_name ||'')) from information_schema.views t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') order by table_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script"
}

particular_view_size()
{
db_info;
script1="select table_catalog as database, table_schema as schema,table_name as view_name from information_schema.tables where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='VIEW' order by table_schema;"
views=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script1"`
echo " \n ************ List of Available views in $db database ********************\n "
echo "\n $views"
echo " \n Enter Your view name to get the size : \c "
read v1
v2=`echo "'$v1'"`
#script2="select table_catalog as database, table_schema || '.' || table_name as tablename, pg_size_pretty(pg_relation_size('' || table_schema ||'"."' || table_name ||'')) from information_schema.tables where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='VIEW' and table_name=$tb1 order by table_schema;"
script2="select t.table_catalog as database, t.table_schema as schema,t.table_name as viewname, t.check_option, t.is_updatable, t.is_insertable_into, t.is_trigger_updatable, t.is_trigger_deletable, t.is_trigger_insertable_into,u.usename as owner, pg_size_pretty(pg_relation_size('' || t.table_schema || '"."' || t.table_name ||'')) from information_schema.views t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') and t.table_name='pg_database1' order by table_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

all_sequence_size()
{
db_info;
#script="select sequence_schema, sequence_name,pg_size_pretty(pg_relation_size('' ||sequence_schema || '"."' || sequence_name || '')) As sequecne_size from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema');"
#script="select sequence_catalog as database,sequence_schema as schema, sequence_name, start_value, minimum_value as min_value, maximum_value as max_value, increment as incremented_by, cycle_option as is_cycled,pg_size_pretty(pg_relation_size('' ||sequence_schema || '"."' || sequence_name || '')) As sequecne_size from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema');"
script="select t.sequence_catalog as database,t.sequence_schema as schema, t.sequence_name, t.start_value, t.minimum_value as min_value, t.maximum_value as max_value, t.increment as incremented_by, t.cycle_option as is_cycled,u.usename as owner,pg_size_pretty(pg_relation_size('' || t.sequence_schema || '"."' || t.sequence_name || '')) As sequecne_size from information_schema.sequences t join pg_catalog.pg_class c on (t.sequence_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema');"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script"
}

particular_sequence_size()
{
db_info;
script1="select sequence_schema, sequence_name from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema'); "
#script1="select sequence_catalog as database,sequence_schema as schema, sequence_name, start_value, minimum_value as min_value, maximum_value as max_value, increment as incremented_by, cycle_option as is_cycled,pg_size_pretty(pg_relation_size('"' ||sequence_schema || '"."' || sequence_name || '"')) As sequecne_size from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema') ;"
SEQUENCES=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script1"`
echo " \n ************ List of Available sequences on $db database ********************\n "
echo "\n $SEQUENCES"
echo " \n Enter Your squence name to get the sequence informatin size : \c "
read sq
se=`echo "'$sq'"`
#script2="select sequence_schema, sequence_name,pg_size_pretty(pg_relation_size('' ||sequence_schema || '"."' || sequence_name || '')) As sequecne_size from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema') and sequence_name=$se;"
#script2="select sequence_catalog as database,sequence_schema as schema, sequence_name, start_value, minimum_value as min_value, maximum_value as max_value, increment as incremented_by, cycle_option as is_cycled,pg_size_pretty(pg_relation_size('' ||sequence_schema || '"."' || sequence_name || '')) As sequecne_size from information_schema.sequences where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema') and sequence_name=$se"
script2="select t.sequence_catalog as database,t.sequence_schema as schema, t.sequence_name, t.start_value, t.minimum_value as min_value, t.maximum_value as max_value, t.increment as incremented_by, t.cycle_option as is_cycled,u.usename as owner,pg_size_pretty(pg_relation_size('' ||t.sequence_schema || '"."' || t.sequence_name || '')) As sequecne_size from information_schema.sequences t join pg_catalog.pg_class c on (t.sequence_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where sequence_schema not like 'pg_%' and sequence_schema not in('information_schema') and sequence_name=$se;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script2"
}

all_tables_name()
{
db_info;
echo " \n ************ List of Available tables name in $db database stored into /tmp/all_tables.csv file ********************\n "
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "COPY(select table_schema as schema_name, table_name as table_name from information_schema.tables where table_schema <> 'information_schema' and table_schema not like 'pg_%' and table_type='BASE TABLE' ) to '/tmp/all_tables.csv' WITH DELIMITER '|' CSV HEADER;" >> $logs 2>&1
}

all_tables_count()
{
db_info;
echo " \n ************ List of tables count in $db database stored into /tmp/all_tables_count_$DATE.csv file ********************\n "
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "COPY(select schemaname,count(tablename) as tables_count from pg_tables group by schemaname having schemaname not like 'pg_%' and schemaname <> 'information_schema') to '/tmp/all_tables_count_$DATE.csv'  WITH DELIMITER '|' CSV HEADER;" >> $logs 2>&1
}


echo " List of options to get the all logical objects information along with size : \n 1. Database Information \n 2. Table Information \n 3. Index Information \n 4. Schema Informationo \n 5. Other Information (Views and Sequences) \n 6. Tables Name in each schema \n 7. Tables Count in each schema \n 8. Exit"

echo "Enter your option [8] : \c"
read op
case $op in 

1) echo "******************************************************************************************"
   echo " choose the below DB options to get the information :\n 1. All Datasase Size \n 2. Particular Database Size \n 3. Exit"
   echo " Enter you options "
   echo "******************************************************************************************"
   read op1
      case $op1 in
      1) all_db_size;
        ;;
      2) particular_db_size;
       ;;
      3) exit
       ;;
      esac
;;

2) echo "******************************************************************************************"
   echo " choose the below Tables options to get the information :\n 1. All Tables Size \n 2. Particular Table Size \n 3. Total Size (Table+index) \n 4. Exit"
   echo " Enter you options "
   echo "******************************************************************************************"
        read op2
        case $op2 in
        1) all_table_size;
        ;;
        2) particular_table;
        ;;
        3) total_relation_size;
        ;;
        4) exit
        ;;
        esac
;;

3) echo "******************************************************************************************"
   echo " choose the below Indexes options to get the information :\n 1. All Index Size \n 2. Particular Index Size \n 3. All Table+Index Size \n 4. Exit"
   echo " Enter you options "
   echo "******************************************************************************************"
        read op3
        case $op3 in
        1) all_index_size;
        ;;
        2) particular_index_size;
        ;;
        3) all_table_index_size;
        ;;
        4) exit
        ;;
        esac
;;

4)  echo "******************************************************************************************"
    echo " choose the below Indexes options to get the information :\n 1. All Schemas Size \n 2. Particular Schema Size \n 3. Exit "
    echo " Enter you options "
    echo "******************************************************************************************"
        read op4
        case $op4 in
        1) all_schema_size;
        ;;
        2) particular_schema;
        ;;
        3) Exit
        ;;
        esac
;;
5)  echo "******************************************************************************************"
    echo " choose the below Views & Sequecnces options to get the information :\n 1. All Views Size \n 2. Particular View Size \n 3. All Sequence Size \n 4. Particular Sequence Size \n 5. Exit"
    echo " Enter you options "
    echo "******************************************************************************************"
        read op5
        case $op5 in
        1) all_views_size;
        ;;
        2) particular_view_size;
        ;;
        3) all_sequence_size;
        ;;
        4) particular_sequence_size;
        esac
        ;;
        5) exit
       ;;
6) all_tables_name;
;;
7) all_tables_count;
;;
8) exit;
;;
esac
