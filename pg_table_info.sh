#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/table_desc_$DATE.log
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      :Manoj & Rajat " | tee -a $logs
echo " \t\tScript Description : This is Script to Find all Table information of each schema." | tee -a $logs
echo " \t\tscript name        : $0" | tee -a $logs  


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
TABLES=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select table_name from information_schema.tables where table_schema='$sc' and table_type='BASE TABLE';" `
echo  "\n **************** List of Available tables in  Schemas ***************** "
echo  "\n$TABLES"
echo  "\n Enter Your  Table Name[ex.public] : \c "
read tabl
}
table_info;
table_det()
{

Details=`$PGHOME/bin/psql -p $PGPORT -d $db -c "SELECT n.nspname as schemaname, c.relname AS tablename,reltuples, relpages,pg_size_pretty(pg_relation_size('""' ||n.nspname || '"."' || c.relname  ||'""')) as size,u.usename as owner FROM pg_class c LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace) join pg_catalog.pg_user u on (c.relowner = u.usesysid) WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') And c.relname='$tabl';"`
echo  "\n **************** List of Available tables in  Schemas ***************** "
echo  "\n$Details"
}
table_det;
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you want to  continue to main menu  (y/n)...? " yn 
         case $yn in
         [Yy]* )db_info ;
           schemas_info;
          table_info;
table_det;
;;
        [Nn]* ) break;;
         esac
echo "THANKYOU"
done

     
