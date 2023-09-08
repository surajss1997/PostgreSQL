#!/bin/bash
#!/bin/bash -x
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs="/tmp/pg_vacuum_info.log"
/usr/bin/touch $logs
echo "" > $logs
echo "\n********************************************************************************************" | tee -a $logs
echo " Script createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " Script author : Manoj Kathar (DBA)" | tee -a $logs
echo " Script Description :  This script use find out all vacuuming information " | tee -a $logs
echo " script name : $0" | tee -a $logs
echo "\n********************************************************************************************" | tee -a $logs
db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of available databases ***************** "
echo  "\n$DATABASES"
echo  "\n Enter your database to get the vacuuming info [postgres] : \c "
read db
}

vacuum_info()
{
db_info;
$PGHOME/bin/psql -p $PGPORT $db  -c "select t.table_catalog as database, u.schemaname as schema, u.relname as tablename, u.last_vacuum from pg_stat_user_tables u join information_schema.tables t on u.relname=t.table_name;"
}
autovacuum_info()
{
db_info;
$PGHOME/bin/psql -p $PGPORT $db  -c "select t.table_catalog as database, u.schemaname as schema, u.relname as tablename, u.last_autovacuum from pg_stat_user_tables u join information_schema.tables t on u.relname=t.table_name;"
}

analyze_info()
{
db_info;
$PGHOME/bin/psql -p $PGPORT $db  -c "select t.table_catalog as database, u.schemaname as schema, u.relname as tablename, u.last_analyze from pg_stat_user_tables u join information_schema.tables t on u.relname=t.table_name;"
}
autoanalyze_info()
{
db_info;
$PGHOME/bin/psql -p $PGPORT $db  -c " select t.table_catalog as database, u.schemaname as schema, u.relname as tablename, u.last_autoanalyze from pg_stat_user_tables u join information_schema.tables t on u.relname=t.table_name;"
}

echo  " Menu Options scripts to get the vacuuming information of each database: \n  1. Last vacuum info \n  2. Last autovacuum info \n  3. Last analyze info \n  4. Last autoanalyze info\n 5. Exit"
echo  "\nEnter your Options: \c"
read op
case $op in
      1) vacuum_info;
            ;;
     2) autovacuum_info;
	        ;;
    3) analyze_info;
        ;;
   4) autoanalyze_info;
       ;;
   5) exit
      ;;
esac
