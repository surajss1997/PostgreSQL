#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh

logs=$PGCRONLOGS/$DATE/index_stats_$DATE.log
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Akash " | tee -a $logs
echo " \t\tScript Description : This is Script to Find Row Count of all Table Of Perticular Schemas" | tee -a $logs
echo " \t\tscript name        : Row Count Details " | tee -a $logs  

echo "\t***********************************************************************************************************\n" | tee -a $logs

currentDate=`date`
echo $currentDate | tee -a $logs
echo " ************************** Row Count Details **********************************\n" | tee -a $logs

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
DATABASES=`$PGHOME/bin/psql -p $PGPORT  -c "select datname as Database_name from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of Available Databases ***************** "
echo  "\n$DATABASES"
#echo  "\n Enter Your Database Name to connect [ex.postgres] : \c "
#read db
}

#db_info;

#schemas_info()
#{
#SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select schema_name as schemaname from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema');"`
#echo  "\n **************** List of Available Schemas ***************** "
#echo  "\n$SCHEMAS"
#echo  "\n Enter Your Schema Name to connect [ex.public] : \c "
#read sc

#$PGHOME/bin/psql -p $PGPORT -d $db -c " select table_schema, table_name, table_type
#from information_schema.tables 
   # where table_schema not in ('pg_catalog', 'information_schema') and table_type in ('BASE TABLE')    
#group by table_schema, table_name, table_type;"
#}

#schemas_info;

table_info()
{
db_info;
echo  "\n Enter Your Database Name to connect [ex.postgres] : \c "
read db
TABLES=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select table_schema as schemaname, table_name as tablename from information_schema.tables where table_schema not in ('pg_catalog', 'information_schema') and table_type='BASE TABLE';"`
echo  "\n **************** List of Available schemas and tables ***************** "
echo  "\n$TABLES"
echo  "\n Enter Your Table Name to count table row[ex.schemaname.tablename] : \c "
read tabl
$PGHOME/bin/psql -p $PGPORT -d $db -c "select count(*) as Table_count from $tabl;"
}
#table_info;


#$PGHOME/bin/psql -p $PGPORT -d $db -c "select count(*) as Table_count from $tabl;"


schemas_info()
{
db_info;
echo  "\n Enter Your Database Name to connect [ex.postgres] : \c "
read db
SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -d $db -c "select schema_name as schemaname from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema');"`
echo  "\n **************** List of Available Schemas to count tables ***************** "
echo  "\n$SCHEMAS"
echo  "\n Enter Your Schema Name to connect [ex.public] : \c "
#echo  "\n ******************* Table count of schemas : $sc ************************"
#$PGHOME/bin/psql -p $PGPORT -d $db -c "select schemaname, count(*) as Number_of_table from pg_tables where schemaname not in ('pg_catalog','information_schema') and schemaname= '$sc' group by schemaname;"
read sc
echo  "\n ******************* Table count of schemas : $sc ************************"
#$PGHOME/bin/psql -p $PGPORT -d $db -c "select schemaname, count(*) as Number_of_table from pg_tables where schemaname not in ('pg_catalog','information_schema') and schemaname= '$sc' group by schemaname;"
$PGHOME/bin/psql -p $PGPORT -d $db -c "set search_path to $sc; select schemaname,tablename as tablename, btrim(xpath('/table/row/count/text()',x)::text,'{}')::integer as rowcount from (
 select schemaname,tablename,query_to_xml('select count(*) from '||tablename,false,false,'') as x 
     from pg_tables where schemaname = '$sc' order by 1
 ) as z;"

}
#schemas_info;

echo "*********************************************************************************"
echo  "\n Menu Options scripts to get the count information of each database: \n  1. table info \n  2. schema info \n  3. Exit "
echo  "\nEnter your Options: \c"
read op
case $op in
      1) table_info;
            ;;
     2) schemas_info;
	        ;;
    3) exit;
       ;;
esac


#echo  "\n ******************* Table count of schemas : $sc ************************"
#$PGHOME/bin/psql -p $PGPORT -d $db -c "select schemaname, count(*) as Number_of_table from pg_tables where schemaname not in ('pg_catalog','information_schema') and schemaname= '$sc' group by schemaname;"


#echo "******************* Table count of database : $db ************************"

#$PGHOME/bin/psql -p $PGPORT -d $db -c "select count(*) as Number_of_table from pg_tables where schemaname not in ('pg_catalog','information_schema');"

#$PGHOME/bin/psql -p $PGPORT -d $db -c "set search_path to $sc; select schemaname,tablename as tablename, btrim(xpath('/table/row/count/text()', x)::text,'{}')::integer as rowcount from (
# select schemaname,tablename,query_to_xml('select count(*) from '||tablename,false,false,'') as x 
 #    from pg_tables where tablename = '$tabl' order by 1
 #) as z;"  | tee -a $logs

end_time
exec_time
