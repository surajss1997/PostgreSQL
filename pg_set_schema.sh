#!/bin/bash
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh

logs=$PGCRONLOGS/$DATE/table_desc_$DATE.log
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      :Rajat Dalvi " | tee -a $logs
echo " \t\tScript Description : This is Script to set schema search path " | tee -a $logs
echo " \t\tscript name        : $0" | tee -a $logs  


db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT  -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of Available Databases ***************** "
echo  "\n$DATABASES"
echo  "\n Enter Your Database Name[ex.postgres] : \c "
read db
}

#db_info;
schemas_info()
{
SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -c "select schema_name from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema')"`
echo  "\n **************** List of Available Schemas ***************** "
echo  "\n$SCHEMAS"
echo  "\n Enter Your Schema Name[ex.public] : \c "
read sc
}
schemas_info;

Set_Path()
{
echo "You are connecting to $sc schema "
#PGOPTIONS='-c search_path='$sc'' $PGHOME/bin/psql -d $PGDATABASE

alias schema_one.con='PGOPTIONS='--search_path=$sc' $PGHOME/bin/psql -U $PGUSER -d $PGDATABASE '
}

Set_Path

