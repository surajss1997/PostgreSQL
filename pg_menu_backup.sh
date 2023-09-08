#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGBACKUP/$DATE/pg_allbackup_$DATE.log
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj Kathar" | tee -a $logs
echo " \t\tScript Description : This is menu driven script to take all types of backup i.e.Global, logical,\n\t\t\t\t\tphysical, archives as well as barman backups in PostgreSQL " | tee -a $logs
echo " \t\tscript name        : $0" | tee -a $logs  
echo "\n\t\t\t ***** Environmental Details *****\n "
echo " \t\tServer Details     : Database Name=$PGDATABASE \n\t\tPort = $PGPORT \n\t\tLocation of Data Directory = $PGDATA" | tee -a $logs
echo " \t\tBackup storage location : Output Log File = $logs \n\t\tBackup Storage Directory = $PGBACKUP/$DATE " | tee -a $logs
echo "\t***********************************************************************************************************\n" | tee -a $logs
SCRIPTNAME="$0"
warning()
{
echo "\n Warning : Before taking backups need to verify your backup storage location with appropriate read & write permission to postgres user\n " | tee -a $logs
}
#echo "\n Hint    : Read the options carefully and then enter your options if allready backup there then new backup must be overwrite " | tee -a $logs

ds=`df -h $PGBACKUP | awk {'print $4'} | sed s'/G//'| tail -1`  # Check disk space mount point size

start_time()
{
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
echo " ******************* Script Start Time: $START *************************\n " | tee -a $logs
}
end_time()
{
END=$(date +"%T.%3N");
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
echo " ******************* Script END Date:$END ************************* \n " | tee -a $logs
}
exec_time()
{
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N")
echo  " ********************** Total Execution Time :$Exe *************************** \n " | tee -a $logs
}

global_backup_summary()
{
echo "\t\t *********** Backup Summary Report **********\n" | tee -a $logs
echo "********************* Global objects information *****************************\n" | tee -a $logs
echo "*********************************[User Details] *****************************************" | tee -a $logs
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select usename as username,usesysid as userId, usecreatedb as Createdb,usesuper as Superuser, userepl as Initiate_Streaming_Replication, passwd as password, valuntil as validity from pg_user" | tee -a $logs
echo "\n****************************[TableSpace Details]****************** " | tee -a $logs 
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT pg_tablespace.spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size(spcname))as Tablespacese_size,pg_tablespace_location(pg_tablespace.oid) FROM pg_tablespace;" | tee -a $logs 
}
db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -d $PGDATABASE -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo  "\n **************** List of Available Databases in Production Server ***************** "
echo  "\n$DATABASES"
echo  "\n Enter Your Database Name to take the Backup [ex.postgres] : \c "
read db
}

global_backup()
{
info="Global level backup contains all global information like DB roles, users and tablespaces information need to for the restoration"
echo "$info" | tee -a $logs
warning; 
start_time;
echo  " ****************** Global backup started ***************************************** " | tee -a $logs
$PGHOME/bin/pg_dumpall -v -g -p $PGPORT -h $PGHOST -U $PGUSER -f $PGBACKUP/$DATE/globaldump_$DATE.sql  2>&1 | tee -a $logs   
GFILENAME=$PGBACKUP/$DATE/globaldump_$DATE.sql
GFILESIZE=$(stat -c%s "$GFILENAME")
GDUMPNAME=globaldump_$DATE.sql
echo "\n\tGlobal Dump File Name: $GDUMPNAME " | tee -a $logs
echo "\n\tGlobal Dump File Location : $PGBACKUP/$DATE/globaldump_$DATE.sql " | tee -a $logs
echo "\tGlobal Dump File Size: \c" | tee -a $logs
echo " ${GFILESIZE} Bytes" | tee -a $logs
end_time;
exec_time;
}
all_db_backup()
{
echo  "\n *********************All Databases Logical Backup started ************************************************ \n" | tee -a $logs
start_time;
DATABASES=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -t -c "select datname from pg_database where datname not in ('template0','template1');"`
for i in $DATABASES; do
echo  "\n***********************************************Logical Dump of $i DB************************************************\n" | tee -a $logs
$PGHOME/bin/pg_dump -v -p $PGPORT -h $PGHOST -U $PGUSER -d $i -C -Fc -f $PGBACKUP/$DATE/$i"_"database"_"$DATE.dump 2>&1 | tee -a $logs 
echo  "\n********************************************************************************" | tee -a $logs
FILENAME=$PGBACKUP/$DATE/$i"_"database"_"$DATE.dump
FILESIZE=$(stat -c%s "$FILENAME")
DUMPNAME=$i"_"database"_"$DATE.dump
echo  "\n\tDump File Name: $DUMPNAME \n"  | tee -a $logs
echo  "\tDump File Size: \c" | tee -a $logs
echo " $((${FILESIZE}/1024/1024)) MB" | tee -a $logs
done
echo  "\n***************************************************BACKUP COMPLETED**************************************************\n" | tee -a $logs
cd $PGBACKUP/$DATE
echo  "Compress the below dump files using tar\t" | tee -a $logs
tar -cvf pg_logicalbackup_$DATE.tar *.dump *.sql | tee -a $logs
if [ $? -eq 0 ]
then
rm *.dump *.sql
echo  "\n********************************************************************************" | tee -a $logs
echo  "\nMerged all dump into pg_logicalbackup_$DATE.tar "  | tee -a $logs
echo  "\nTar File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/pg_logicalbackup_$DATE.tar | awk '{print $1}'  | tee -a $logs
else
echo  "\nTar is Unsuccessful   : \c " | tee -a $logs
fi
end_time
exec_time
echo "\t*****All Database Backup File Summary Report****** " | tee -a $logs
sh /opt/PostgreSQL/9.5/SY_dbascripts/demo_scripts/count_all_objects.sh
echo " to see all the Backup summary objects log information under the /tmp/pg_relation_size.log files"
}

particular_database()
{
db_info;
start_time
echo  "\n*********************************************** Logical Dump of $db Database ************************************************\n" | tee -a $logs
$PGHOME/bin/pg_dump -v -p $PGPORT -h $PGHOST -U $PGUSER -d $db -C -Fc -f $PGBACKUP/$DATE/$db"_"database"_"$DATE.dump 2>&1 | tee -a $logs 
end_time
exec_time
echo  "\n*********************************************** Backup completed $db Database ************************************************\n" | tee -a $logs
echo " backup is stored at $PGBACKUP$DATE/$db"_"database"_"$DATE.dump " | tee -a $logs
echo  "\nBackup Tar File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/$db"_"database"_"$DATE.dump | awk '{print $1}'  | tee -a $logs
}
database_count()
{
echo " ****** List of objects count in $db database ******\n "
script="SELECT n.nspname as schema_name, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END as object_type ,count(1) as object_count FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace  WHERE c.relkind IN ('r','v','i','S','s','m') and n.nspname not like 'pg_%' and n.nspname not in ('information_schema') GROUP BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END ORDER BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -h $PGHOST -d $db -c "$script"
echo " ******* List of Functions count in $db database ******\n"
script1="SELECT routine_schema as schema,count(routine_name) as function_count FROM information_schema.routines where routine_schema not like 'pg_%'and routine_schema not in ('information_schema') group by routine_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -h $PGHOST -d $db -c "$script1"
}

particular_table()
{
db_info;
echo  "\n ******* list of schema available in $db database ***********\n"
SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -d $db -t -c "select schema_name from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema');"`
echo  "\n$SCHEMAS"
echo  "\n Enter your schema to get list of tables in schema:\c "
read sc
TABLES=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -d $db -t -c "select table_name from information_schema.tables where table_schema='$sc' and table_type='BASE TABLE';"`
echo  "\n$TABLES"
read -p "Enter your single or multiple tables with space separated for backup (ex. emp dept) :" table
start_time
ta=$(for i in $table
do
echo -n "-t $i "
done)
cnt=0
for i in $table
do
cnt=$(($cnt+1))
done
#echo  "\n *********************************************** Logical Dump of $table in $sc schema on $db database ********************************\n" | tee -a $logs
#$PGHOME/bin/pg_dump -v -p $PGPORT -d $db -t $sc.$table -Fc -f $PGBACKUP/$DATE/$table"_"table"_"$db"_"$DATE.dump 2>&1 | tee -a $logs 
$PGHOME/bin/pg_dump -v -p $PGPORT -h $PGHOST -U $PGUSER -d $db $ta -Fc -f $PGBACKUP/$DATE/$db"_"$sc"_"$cnt"_"tables"_"$DATE.dump 2>&1 >> $logs 2>&1 
end_time
exec_time
#echo "\n*********************************************** Backup completed $table in $sc on $db Database ************************************\n" | tee -a $logs
echo  "backup is stored at location : $PGBACKUP/$DATE/$db"_"$sc"_"$cnt"_"tables"_"$DATE.dump " | tee -a $logs
echo  "\nBackup Tar File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/$db"_"$sc"_"$cnt"_"tables"_"$DATE.dump | awk '{print $1}' | tee -a $logs
echo "\t\t\n ******* $table table backup summary in $db database **********"
echo "\t\t -----------------------------------------------"
tb=$(for k in $table
do
echo -n "'$k',"
done)
tb1=`echo "${tb%,}  "`
#table1=`echo "'$table'"`
script="select t.table_catalog as database, t.table_schema as schema, t.table_name as tablename, u.usename as owner,c.reltuples as rows_count, pg_size_pretty(pg_relation_size('' ||t.table_schema || '"."' || t.table_name ||'')) as size from information_schema.tables t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE'and table_name in ($tb1) order by table_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $db -c "$script"
}

particular_schema()
{
db_info;
echo  "\n ******* list of schema available in $db ***********\n"
SCHEMAS=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -d $db -t -c "select schema_name from information_schema.schemata where schema_name not like 'pg_%' and schema_name not in ('information_schema');"`
echo  "\n$SCHEMAS"
read -p "Enter schema name (single or multiple schemas with space separated for backup ex. public hr) : " sc
start_time
sa=$(for p in $sc
do
echo -n "--schema=$p "
done)
cnt=0
for q in $sc
do
cnt=$(($cnt+1))
done
echo  "\n*********************************************** Logical Dump of $sc schema in $db database ******************************************\n" | tee -a $logs
#$PGHOME/bin/pg_dump -v -p $PGPORT -d $db  -n $sc -Fc -f $PGBACKUP/$DATE/$sc"_"$db"_"schema"_"$DATE.dump 2>&1 | tee -a $logs 
$PGHOME/bin/pg_dump -v -p $PGPORT -U $PGUSER -h $PGHOST -d $db $sa -Fc -f $PGBACKUP/$DATE/$db"_"$cnt"_"schemas"_"$DATE.dump 2>&1 >> $logs 2>&1
if [ "$?" -eq "0" ]
then
end_time
exec_time
echo  "\n*********************************************** Backup completed $sc in $db Database*****************************\n" | tee -a $logs
echo " backup is stored at $PGBACKUP$DATE/$db"_"$cnt"_"schemas"_"$DATE.dump " | tee -a $logs
echo  "\nBackup Tar File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/$db"_"$cnt"_"schemas"_"$DATE.dump | awk '{print $1}'  | tee -a $logs
echo "\t\t\n ******* $sc schema backup summary **********"
echo "\t\t -----------------------------------------------"
#sc1=`echo "'$sc'"`
tb1=$(for k in $sc
do
echo -n "'$k',"
done)
sc1=`echo "${tb1%,}  "`
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -h $PGHOST -d $db -c "SELECT n.nspname as schema_name, CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'm' THEN 'materialized_view' END as object_type ,count(1) as object_count FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relkind IN ('r','v','i','S','s','m') and n.nspname not like 'pg_%' and n.nspname not in ('information_schema') and n.nspname in ($sc1) GROUP BY n.nspname, CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'm' THEN 'materialized_view' END ORDER BY n.nspname, CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'm' THEN 'materialized_view' END;"
script1="SELECT routine_schema as schema,count(routine_name) as function_count FROM information_schema.routines where routine_schema not like 'pg_%'and routine_schema not in ('information_schema') and routine_schema in ($sc1) group by routine_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -h $PGHOST -d $db -c "$script1"
else 
echo "Please enter correct schema name :"
fi
}

all_object_count()
{
echo "\t\t *********** Backup Summary Report **********\n" | tee -a $logs
echo "********************* Global objects information *****************************\n" | tee -a $logs
echo "*********************************[User Details] *****************************************" | tee -a $logs
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select usename as username,usesysid as userId, usecreatedb as Createdb,usesuper as Superuser, userepl as Initiate_Streaming_Replication, passwd as password, valuntil as validity from pg_user" | tee -a $logs
echo "\n****************************[TableSpace Details]****************** " | tee -a $logs 
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT pg_tablespace.spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size(spcname))as Tablespacese_size,pg_tablespace_location(pg_tablespace.oid) FROM pg_tablespace;" | tee -a $logs 
echo "********************** Logical objects information ***************************" 
DATABASES=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "select datname from pg_database where datname not in ('template0','template1');"`
echo " All database information of production server along with DB size :" | tee -a $logs 
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;" | tee -a $log
for i in $DATABASES; do
echo " \n ************* All schema size in $i databases ***************************" | tee -a $logs
sc1="SELECT schema_name, pg_size_pretty(sum(table_size)::bigint) as schema_size FROM (SELECT pg_namespace.nspname as schema_name, pg_relation_size(pg_class.oid) as table_size FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid where pg_namespace.nspname not like 'pg_%' and pg_namespace.nspname not in('information_schema'))t GROUP BY schema_name ORDER BY schema_name;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $i -c "$sc1" | tee -a $logs
done
for i in $DATABASES; do
echo " ****** List of objects count in $i database ******\n "
script="SELECT n.nspname as schema_name, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END as object_type ,count(1) as object_count FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace  WHERE c.relkind IN ('r','v','i','S','s','m') and n.nspname not like 'pg_%' and n.nspname not in ('information_schema') GROUP BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END ORDER BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $i -c "$script"
echo " ******* List of Functions count in $i database ******\n"
script1="SELECT routine_schema as schema,count(routine_name) as function_count FROM information_schema.routines where routine_schema not like 'pg_%'and routine_schema not in ('information_schema') group by routine_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $i -c "$script1"
done
}

physical_backup()
{
echo  " ********************************** ONLINE BACKUP STARTED ***************************************************************** \n" | tee -a $logs
start_time;
$PGHOME/bin/pg_basebackup -h $HOSTNAME -PR -p $PGPORT -h $PGHOST -x -Ft -D $PGBACKUP/$DATE/physical_backup_$DATE -v -U $PGUSER 2>&1 | tee -a $logs 
echo " online backup is stored at $PGBACKUP/$DATE/physical_backup_$DATE" | tee -a $logs
if [ $? -eq 0 ]
then
cd $PGBACKUP/$DATE/physical_backup_$DATE
echo  "\nOnline Backup File Name : pgbackup_$DATE" | tee -a $logs
/bin/gzip base.tar --fast
echo  "File Size: \c" | tee -a $logs
du -h | awk '{print $1}' | tee -a $logs
fi
end_time
exec_time
echo  "\n\n\n***************************ONLINE BACKUP COMPLETED*****************************\n" | tee -a $logs
}
pg_archive_backup()
{
echo "\n Backup of archives file under the $PGARCH directory " | tee -a $logs
cd $PGARCH/
#if test `find -type f -daystart -not -mtime 0`
#then
start_time;
list=`ls -lrth` | tee -a $logs
echo "list of archive files available and need to take all files backup for safety" | tee -a $logs
echo "$list" | tee -a $logs
echo "list of archive files available and need to take all files backup for safety" | tee -a $logs
echo "$list" | tee -a $logs
echo "location for to store all above files on $PGBACKUP/$DATE/pg_arachivebackup_$DATE.tar.gz " | tee -a $logs
#find -type f -daystart | xargs tar -cvzf $PGBACKUP/$DATE/pg_archivebackup_$DATE.tar.gz
find -type f -daystart -not -mtime 0 | xargs tar -cvzf $PGBACKUP/$DATE/pg_archivebackup_$DATE.tar.gz # Copy files upto yesterday's date.
cd $PGBACKUP/$DATE
echo  "\nArchive File Name : pg_archivebackup_$DATE.tar.gz" | tee -a $logs
echo  "Archive File Size : \c" | tee -a $logs
du -h pg_archivebackup_$DATE.tar.gz | awk '{print $1}' | tee -a $logs
echo  "\nStatus of archive files under directory $PGARCH is :" | tee -a $logs
TARCOUNT=`tar -tzf $PGBACKUP/$DATE/pg_archivebackup_$DATE.tar.gz | wc -l`
#DIRCOUNT=`find $PGARCH/* -daystart | wc -l`
DIRCOUNT=`find $PGARCH/* -daystart -not -mtime 0 | wc -l`
echo "DIRCOUNT = $DIRCOUNT \nTARCOUNT = $TARCOUNT " | tee -a $logs
if [ $TARCOUNT -eq $DIRCOUNT ]
then
echo  "Compared tar files with directory files both are same" | tee -a $logs
cd $PGARCH/
#find -daystart -mtime 1 -exec ls -l {} \; | tee -a $logs
#find -type f -daystart -not -mtime 0 -exec ls -l {} \; | tee -a $logs
ar=`du -ch /pgdata/archive/ | grep total | awk {'print $1'}`
DIRCOUNT1=`find $PGARCH/* -daystart | wc -l`
echo "Before removing files $PGARCH size = $ar and files count = $DIRCOUNT1" | tee -a $logs
echo -e "\n ******************* Deleting Up to previous days Files in $PGARCH *********************" | tee -a $logs
find -type f -daystart -not -mtime 0 -exec ls -l {} \; | tee -a $logs
read -p "Are you sure to remove archives file (y/n)...? " yn 
   case $yn in
        [Yy]* ) find -type f -daystart -not -mtime 0 -exec rm -f {} \; | tee -a $logs
        ;;
        [Nn]* ) echo "no archives removes"
   esac
ar1=`du -ch /pgdata/archive/ | grep total | awk {'print $1'}`
DIRCOUNT2=`find $PGARCH/* -daystart | wc -l`
echo "After removing files $PGARCH size = $ar1 and files count = $DIRCOUNT2" | tee -a $logs
echo " Available file in $PGARCH"
ls -l | tee -a $logs
else
echo  "File count is different" | tee -a $logs
fi
#else
#echo " No old archives there"
#fi
end_time;
exec_time;
}

physical_archives_backup()
{
physical_backup;
pg_archive_backup;
cd $PGBACKUP/$DATE
tar -cf pg_online_archivebackup_$DATE.tar pg_archivebackup_$DATE.tar.gz physical_backup_$DATE
if [ $? -eq 0 ]
then
rm -rf pg_archivebackup_$DATE.tar.gz physical_backup_$DATE
echo  "\n\nMerged pg_archivebackup_$DATE.tar.gz, physical_backup_$DATE into pg_online_archivebackup_$DATE.tar" | tee -a $logs
echo  "\nFile Size   : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/pg_online_archivebackup_$DATE.tar | awk '{print $1}' | tee -a $logs
else
echo  "\nTar is Unsuccessful and the backup files still exists on disk!!! " |tee -a $logs
fi
}

barman_server_details()
{
echo " Enter your barman server user [barman] :"
read usr;
echo " Enter your barman server host name or ip [127.0.0.1] :"
read ip;
bk=`ssh -l $usr $ip barman show-server main-db-server | grep backup_directory | awk '{ print $2}'`
echo " Barman server backup storage location is :$bk"
ds=`ssh -l $usr $ip df -h $bk | awk '{ print $4}' | sed s'/G//' | tail -1`
echo " Available disk space on barman server is :$ds GB"
}
barman_backup()
{
start_time;
echo  "\n *********************** Performed Full Backup using Barman ************ \n" | tee -a $logs
echo  " \n barman backup location stored the barman backup server $ip under $usr home directory\n" | tee -a $logs
echo  " \n barman server have /etc/barman.conf to setup the postgresql and barman configurtion" | tee -a $logs
echo  " \n ************************  barman  backup started ************************************ \n" | tee -a $logs
ssh -l $usr $ip barman backup main-db-server 2>&1 | tee -a $logs 
echo  " \n ************************  barman  backup completed ************************************ \n" | tee -a $logs
end_time;
exec_time;
echo  " backup is stored at $usr:$ip:/var/lib/barman/main-db-server" | tee -a $logs
echo  " to see the latest backup information in barman backup server" | tee -a $logs
ssh -l $usr $ip barman show-backup main-db-server latest | tee -a $logs
}

barman_incremental_backup()
{
start_time;
echo  "\n *********************** Performed Incremental Backup using Barman ************ \n" | tee -a $logs
echo  " \n barman backup location stored the barman backup server $ip under $usr home directory\n" | tee -a $logs
echo  " \n barman server have /etc/barman.conf to setup the postgresql and barman configurtion for incremetal backup" | tee -a $logs
echo  " \n ************************ Incremental barman  backup started ************************************ \n" | tee -a $logs
ssh -l $usr $ip barman backup --reuse-backup=link main-db-server 2>&1 | tee -a $logs 
echo  " \n ************************  Incremental barman  backup completed ************************************ \n" | tee -a $logs
end_time;
exec_time;
echo  " backup is stored at $usr:$ip:/var/lib/barman/main-db-server " | tee -a $logs
echo  " to see the latest backup information in barman backup server" | tee -a $logs
ssh -l $usr $ip barman show-backup main-db-server latest | tee -a $logs
}

all_schema_backup()
{
start_time;
echo  "\n ********************* Schema Backup started ************************************************ \n" | tee -a $logs
DATABASES=`$PGHOME/bin/psql -p $PGPORT -h $PGHOST -U $PGUSER -t -c "select datname from pg_database where datname not in ('template0','template1');"`
for i in $DATABASES; do
echo  "\n********************************************** Logical Dump of $i DB ***********************************************\n" | tee -a $logs
$PGHOME/bin/pg_dump -v -p $PGPORT -h $PGHOST -U $PGUSER -d $i -s -f $PGBACKUP/$DATE/schema"_"$i"_"$DATE.sql 2>&1 | tee -a $logs 
echo  "\n********************************************************************************" | tee -a $logs
FILENAME=$PGBACKUP/$DATE/schema"_"$i"_"$DATE.sql
FILESIZE=$(stat -c%s "$FILENAME")
DUMPNAME=schema"_"$i"_"$DATE.sql
echo  "\n\tDump File Name: $DUMPNAME \n" | tee -a $logs
echo  "\tDump File Size: \c" | tee -a $logs
echo " $((${FILESIZE}/1024/1024)) KB" >>  $logs
done
echo  "\n***************************************************BACKUP COMPLETED**************************************************\n" | tee -a $logs
cd $PGBACKUP/$DATE
echo  "Compress the below sql files using tar\t" | tee -a $logs
tar -cvf pg_schemabackup_$DATE.tar *.sql | tee -a $logs
if [ $? -eq 0 ]
then
rm *.sql
echo  "\n********************************************************************************" | tee -a $logs
echo  "\nMerged all dump into pg_schemabackup_$DATE.tar "  | tee -a $logs
echo  "\nTar File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/pg_schemabackup_$DATE.tar | awk '{print $1}'  | tee -a $logs
else
echo  "\nTar is Unsuccessful : \c " | tee -a $logs
fi
end_time;
exec_time;
}

particular_schema_backup()
{
db_info;
start_time;
echo  "\n*********************************************** Schema Backup of $db Database ************************************************\n" | tee -a $logs
$PGHOME/bin/pg_dump -v -p $PGPORT -h $PGHOST -U $PGUSER -d $db -s -f $PGBACKUP/$DATE/schema"_"$db"_"$DATE.sql 2>&1 | tee -a $logs 
end_time;
exec_time;
echo  "\n*********************************************** Schema Backup completed $db Database *****************************\n" | tee -a $logs
echo " backup is stored at $PGBACKUP$DATE/schema"_"$db"_"$DATE.dump " | tee -a $logs
echo  "\nBackup Sql File Size : \c " | tee -a $logs
du -h $PGBACKUP/$DATE/schema"_"$db"_"$DATE.sql | awk '{print $1}' | tee -a $logs
}

logical_continue()
{
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you want to continue logical backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) logical_menu
           ;;
         [Nn]* ) main_menu
           ;;
         esac
done
}
physical_continue()
{
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you want to continue physical backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) physical_menu
           ;;
         [Nn]* ) main_menu
           ;;
         esac
done
}
barman_continue()
{
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you want to continue barman backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) barman_menu
           ;;
         [Nn]* ) main_menu
           ;;
         esac
done
}
logical_menu()
{
echo " \t\t************************* Logical Backup Sub Menu ****************************************"
echo " Logical Backups in PostgreSQL :\n 1. Only global backup \n 2. Invidual database backup including global backup \n 3. Invidual schema backup \n 4. Invidual table backup \n 5. Only Schema/Structure backup(SQL Queries/Commands) \n 6. All databases backup including global backup \n 7. Exit(Return back to main menu)"
echo " Enter you choice : "
   echo "\n******************************************************************************************"
      read op1
      case $op1 in
      1) echo "\nAll global backups including with all user or roles and tablespace info\n"
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         echo " "$ds"GB Disk space available on $PGBACKUP."
         global_backup;
         global_backup_summary;
         fi
      ;;
      6) echo "all db backup"
        echo "\nAll Database backups including with global backup \n"
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         #echo " Disk space available on $PGBACKUP and now you take the all database backup including global backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
         echo "Hint: Mandatory need to global backup before taking database dump backup"
         echo " *******************************************************************\n" | tee -a $logs
         global_backup;
         echo  " ******************************************************************\n" | tee -a $logs
         all_db_backup;
         fi
      ;;
      2) echo "inv.db backup"
        echo "Taking invidual Database backup including global backup which you want\n "
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
        # echo " Disk space available on $PGBACKUP and now you take the invidual DB backup including global backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
         echo "Hint: Mandatory need to global backup before taking database dump backup"
         echo " *******************************************************************\n" | tee -a $logs
         global_backup;
         echo  " ******************************************************************\n" | tee -a $logs
         particular_database;
         global_backup_summary;
         database_count;
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you continue to take another Database backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) particular_database;
                 database_count;
           ;;
        [Nn]* ) break;;
         esac
done
         fi
      ;;
      3) echo "inv.schema backup"
echo "\nInvidual schema backup in specific database which you want\n"
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         #echo " Disk space available on $PGBACKUP and now you take the schema backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
         #echo "Hint: Mandatory need to global backup before taking database dump backup"
         #echo " *******************************************************************\n" | tee -a $logs
         #global_backup;
         echo  "******************************************************************\n" | tee -a $logs
         particular_schema;

i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you continue to take another schema backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) particular_schema;
           ;;
        [Nn]* ) break;;
         esac
done
fi
      ;;
      4) echo "inv.table backup"
echo "\n Invidual Table backup in specific schema and specific database which you want \n" 
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         #echo " Disk space available on $PGBACKUP and now you take the table backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
         #echo "Hint: Mandatory need to global backup before taking database dump backup"
         #echo " *******************************************************************\n" | tee -a $logs
         #global_backup;
         echo  " ******************************************************************\n" | tee -a $logs
         particular_table;
i=[Yy]*
while  [ $i="[Yy]*" ]
do
         read -p "do you continue to take another table backup (y/n)...? " yn 
         case $yn in
         [Yy]* ) particular_table;
           ;;
        [Nn]* ) break;;
         esac
done
fi
      ;;
      5) echo "structure backup"
       echo "\n Taking only the schema/structure backups of all Database \n" 
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         #echo " Disk space available on $PGBACKUP and now you take the all DB schema backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
         all_schema_backup;
         fi
      ;;
      7) echo " return main menu";
         main_menu;
      ;;
      * ) tput setf 7;echo "Please enter choice between 1..7 ";tput setf 7;
     esac
logical_continue;
}

physical_menu()
{
echo " \n ************************* Physical Menu *********************************************** "
echo " Physical(Online) Backups Types available in PostgreSQL :\n 1. Full Backup (With Archives)  \n 2. Full Backup (Without Archives) \n 3. ONLY Archives Backup \n 4. return back to main menu "
echo " Enter you choice : "
   echo "\n******************************************************************************************"
      read op1
      case $op1 in
      1) echo "full backup with archives"
        echo "\n Take Full backup with archives backups \n"
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else
         echo " "$ds"GB Disk space available on $PGBACKUP."
        #echo " Disk space available on $PGBACKUP and now you take the full backup of server "
          physical_archives_backup;
          all_object_count;
         fi
      ;;
      2) echo "full backup without archives"
        echo "\n Take Full backup without archives backup\n"
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else 
         #echo " Disk space available on $PGBACKUP and now you take the full backup "
         echo " "$ds"GB Disk space available on $PGBACKUP."
          physical_backup;
          all_object_count;
          fi
      ;;
      3) echo "only archives backup"
        echo "\n Take only archives backups\n" 
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $PGBACKUP. Provide another backup location on pg_env.sh file "
         else
         echo " "$ds"GB Disk space available on $PGBACKUP."
         # echo " Disk space available on $PGBACKUP and now you take the archives backup "
          pg_archive_backup;
         fi
      ;;
      4) echo " return main menu"
         main_menu;
      ;;
      * ) tput setf 4;echo "Please enter 1, 2, 3, or 4";tput setf 4;
      ;;
      esac
physical_continue;
}

barman_menu()
{
#until [ "$option" = "3" ]; do
echo " \n ************************* barman Menu *********************************************** "
echo " Perform PostgreSQL Backups using barman tool :\n 1. Full backup using barman \n 2. Incremental Backup using barman\n 3. return back to main menu "
echo " Enter you choice : "
   echo "\n******************************************************************************************"
      read op1
      case $op1 in
      1) echo "full barman backup"
     echo "\n Take Full backup using the barman tool \n" 
          barman_server_details;
          if [ "$ds" -lt "1" ] 
          then 
          echo " Disk space not available on $bk. Provide another backup location on /etc/barman.conf file "
          else 
          echo " Disk space available on $bk and now you take the barman full backup "
          barman_backup;
          all_object_count;
          fi
      ;;
      2) echo "incremental barman backup"
         echo "\n Take Incremental backup using barman tool\n"
          barman_server_details;
         if [ "$ds" -lt "1" ] 
         then 
         echo " Disk space not available on $bk. Provide another backup location on /etc/barman.conf file "
         else 
         echo " Disk space available on $bk and now you take the incremental barman backup "
          barman_incremental_backup;
          all_object_count;
          fi
      ;;
      3) echo " return main menu"
        main_menu;
      ;;
      * ) tput setf 3;echo "Please enter 1, 2, or 3";tput setf 3;
      ;;    
      esac
barman_continue;
}

main_menu()
{
option=0
until [ "$option" = "4" ]; do
echo " \t\t ************************* PostgreSQL Backup Main Menu **************************************** "
echo " 1. Logical Backup \n 2. Physical Backup (Online Backup) \n 3. Barman Backup \n 4. Exit"
read -p "Enter your choice: " op
case $op in
1) logical_menu;
;;
2) physical_menu;
;;
3) barman_menu;
;;
4) exit
;;
* ) echo "Please enter 1, 2, 3, or 4" 
esac
done
}
main_menu;
