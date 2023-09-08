#!/bin/bash

#!/bin/bash -x

spath=/home/postgres/restore.sh

mainmenu()
{
bash "$spath"
}


. /home/postgres/pg_env_96.sh

SCRIPTNAME=restore.sh
logs=$PGRESTORE/pg_restore.log

echo "" > $logs
echo "***************************************************************************************************" | tee -a $logs
echo "***************************************************************************************************\n" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Saiprasad Dasarwar " | tee -a $logs
echo " \t\tscript name        : PG_Database_Restore" | tee -a $logs  
#echo " \n\t\t\t\t [ Restore Details ]     \n\t\t\n\t\tRestore PATH = $PGRESTORED \n\t\tBackup PATH = $PGBACKUP/$DATE" | tee -a $logs
echo "\n"  | tee -a $logs
echo "***************************************************************************************************\n" | tee -a $logs

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


db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"` | tee -a $logs
echo  "\n **************** List of Available Databases in Production Server ***************** " | tee -a $logs
echo  "\n$DATABASES" | tee -a $logs
echo  "\n Enter Your Database Name for Restore : \c "
read db
}

start_server()
{
$PGHOME/bin/pg_ctl -D $PGRESTORE start
read -p "" yn
echo "\n"
$PGHOME/bin/pg_ctl -D $PGRESTORE status
$PGHOME/bin/psql -p $port

}

#################################################################################

all_db_size()
{
#echo "$warning" | tee -a $logs
echo " All database information of production server along with DB size :" | tee -a $logs 
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;" | tee -a $logs
}

all_schema_size()
{
db_info;
for i in $DATABASES; do
echo " \n ************* All schema size in $i databases ***************************" | tee -a $logs
sc1="SELECT schema_name, pg_size_pretty(sum(table_size)::bigint) as schema_size FROM (SELECT pg_namespace.nspname as schema_name, pg_relation_size(pg_class.oid) as table_size FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid where pg_namespace.nspname not like 'pg_%' and pg_namespace.nspname not in('information_schema'))t GROUP BY schema_name ORDER BY schema_name;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $i -c "$sc1" | tee -a $logs
done
}

db_info()
{
DATABASES=`$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -t -c "select datname from pg_database where datname not in ('template0','template1');"`
}

all_table_size()
{
db_info;
for i in $DATABASES; do
echo " \n ************* All tables size in $i databases ***************************" | tee -a $logs
script="select t.table_catalog as database, t.table_schema as schema, t.table_name as tablename, u.usename as owner,pg_size_pretty(pg_relation_size('' ||t.table_schema || '"."' || t.table_name ||'')) as size from information_schema.tables t join pg_catalog.pg_class c on (t.table_name = c.relname) join pg_catalog.pg_user u on (c.relowner = u.usesysid) where table_schema not like 'pg_%' and table_schema not in ('information_schema') and table_type='BASE TABLE' order by table_schema;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $i -c "$script" | tee -a $logs
done
}


all_db_object_counts()
{
echo "\n             **************** After restore Backup Summary Report **********\n" | tee -a $logs
echo "\n*******************  Global objects information   ******************\n" | tee -a $logs
echo "*********************     [User Details]            ******************" | tee -a $logs

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select usename as username,usesysid as userId, usecreatedb as Createdb,usesuper as Superuser, userepl as Initiate_Streaming_Replication, passwd as password, valuntil as validity from pg_user" | tee -a $logs

echo "\n*******************  [TableSpace Details]      ****************** " | tee -a $logs 

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT pg_tablespace.spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size(spcname))as Tablespacese_size,pg_tablespace_location(pg_tablespace.oid) FROM pg_tablespace;" | tee -a $logs 

echo "********************** Logical objects information ***************************" 

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT n.nspname as schema_name, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END as object_type ,count(1) as object_count FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace  WHERE c.relkind IN ('r','v','i','S','s','m') and n.nspname not like 'pg_%' and n.nspname not in ('information_schema') GROUP BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END ORDER BY n.nspname, CASE c.relkind WHEN 'r' THEN 'Tables' WHEN 'v' THEN 'Views' WHEN 'i' THEN 'Indexes' WHEN 'S' THEN 'Sequences' WHEN 's' THEN 'Special' WHEN 'm' THEN 'Materialized_view' END;"

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT routine_schema as schema,count(routine_name) as function_count FROM information_schema.routines where routine_schema not like 'pg_%'and routine_schema not in ('information_schema') group by routine_schema;"

$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;"

}

#################################################


global_restore()
{

echo "\n**********************************************************************\n*                                                                    *\n* All Global Backups including with all Users, Roles and Tablespace  *\n*                                                                    *\n**********************************************************************\n"

echo "\n In following path Global file exists with size\n" | tee -a $logs

du -sh $PGBACKUP/$DATE/globaldump_$DATE.sql   | tee -a $logs

echo "\n"
 read -p "Do you wish to Restore Global file (y/n)...?   " yn
    case $yn in
     #[Yy]* ) break;;
      [Nn]* ) exit;;
     esac
      $PGHOME/bin/psql -p $PGPORT -v -d $rdbnamm -U $PGUSER -f $PGBACKUP/$DATE/globaldump_$DATE.sql;  

echo "\n\n Successfully Restore Golbal file in to Your "$rdbnamm" Database \n\n" | tee -a $logs

echo "********************* Global objects information *****************************\n" | tee -a $logs
echo "*********************************[User Details] *****************************************" | tee -a $logs
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select usename as username,usesysid as userId, usecreatedb as Createdb,usesuper as Superuser, userepl as Initiate_Streaming_Replication, passwd as password, valuntil as validity from pg_user" | tee -a $logs
echo "\n****************************[TableSpace Details]****************** " | tee -a $logs
$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT pg_tablespace.spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size(spcname))as Tablespacese_size,pg_tablespace_location(pg_tablespace.oid) FROM pg_tablespace;" | tee -a $logs

}


All_DB_restore()
{

#NAME=sam echo "$NAME"
cmd=$($PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;") 

$PGHOME/bin/psql -p $PGPORT -v -d $PGDATABASE -f $PGBACKUP/$DATE/globaldump_$DATE.sql; 2>&1 | tee -a $logs 

tar -xf $PGBACKUP/$DATE/pg_logicalbackup_$DATE.tar -C $PGRESTORE

v=$PGRESTORE/*.dump 

for i in $v;do

$PGHOME/bin/pg_restore -p $PGPORT -v -d $PGDATABASE -C $i; 

done

echo "\n             **************** Before restore Database size ***************** " | tee -a $logs

echo "$cmd" | tee -a $logs 

all_db_object_counts;

}

particular_Database()
{
#db_info;
echo "\n**********************************************************************\n"

echo "\nPerticular Database file exists with size\n"

cd $PGBACKUP/$DATE/
du -sh *.dump *.sql

echo "\n"

read -p "Do you wish to Restore Global file (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])

echo "\n"
read -p "Enter Global file ----> " gb

$PGHOME/bin/psql -p $PGPORT -v -d $rdbnamm -U $PGUSER -f $PGBACKUP/$DATE/$gb;
echo "\n"
read -p  "After Global restore Enter dump file to restore into your database --> " utarname
echo "\nThis is Your Database where you want to restore "
echo "**************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"
echo "*************************"

read -p "Enter your Databae name for restore --> " rdbname
$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U $PGUSER $PGBACKUP/$DATE/$utarname; 

echo "\n **** successfully restore **** "
#$PGHOME/bin/psql -p $PGPORT -c "select count(*) as database_count from pg_database;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;"

;;

[nN][oO]|[nN])
echo "\n"
read -p  "Enter Database.dump file to restore into your database --> " utarname
echo "\nThis is Your Database where you want to restore "
echo "*************************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"

echo "*************************"

read -p "Enter your Databae name for restore --> " rdbname
$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U postgres $PGBACKUP/$DATE/$utarname; 

echo "\n **** successfully restore **** "
#$PGHOME/bin/psql -p $PGPORT -c "select count(*) as database_count from pg_database;"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select datname As Database_Name, pg_get_userbyid(datdba) as Owner, pg_encoding_to_char(encoding) as Encoding, datcollate as Collate, datctype as Ctype, array_to_string(datacl, E'\n') AS Access_privileges, pg_size_pretty(pg_database_size(datname)) as SIZE from pg_database where datname not in ('template0','template1') order by pg_database_size(datname) desc;"
;;
esac

}

particular_Table()
{
echo "\n**********************************************************************\n"

echo "\nPerticular Table file exists with size\n"

cd $PGBACKUP/$DATE/
du -sh *.dump *.sql

echo "\n"

read -p "Do you wish to Restore Global file (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])

echo "\n"
read -p "Enter Global file ----> " gb

$PGHOME/bin/psql -p $PGPORT -v -d $rdbnamm -U postgres -f $PGBACKUP/$DATE/$gb;
echo "\n"
read -p "After Global restore Then Enter Table .dump file to restore into your database --> " utarname
echo "\n This is Your Database where you want to restore "
echo "**************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"
echo "*************************"

read -p "Enter your Databae name for restore --> " rdbname

read -p "Enter your single or multiple tables with space separated for backup (ex. emp dept) :" table
#read table
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

$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U $PGUSER $ta $PGBACKUP/$DATE/$utarname;  
end_time
exec_time

echo "\n **** successfully restore **** "
$PGHOME/bin/psql -p $PGPORT -t -c "select table_schema,count(table_name) as table_count from information_schema.tables group by table_schema;" | tee -a $logs

;;

[nN][oO]|[nN])
echo "\n"
read -p  " Enter Table.dump file to restore into your database --> " utarname
echo "\nThis is Your Database where you want to restore "
echo "*************************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"
echo "*************************"

read -p "Enter your Databae name for restore --> " rdbname

read -p "Enter your single or multiple tables with space separated for backup (ex. emp dept) :" table
#read table
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

$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U $PGUSER $ta $PGBACKUP/$DATE/$utarname;  
end_time
exec_time

echo "\n **** successfully restore **** "
$PGHOME/bin/psql -p $PGPORT -t -c "select table_schema,count(table_name) as table_count from information_schema.tables group by table_schema;" | tee -a $logs

;;
esac
}

particular_schema()
{

echo "\n**********************************************************************\n"

echo "\nPerticular schema file exists with size\n"

cd $PGBACKUP/$DATE/
#du -sh *.dump 
du -sh *.dump *.sql

echo "\n"

read -p "Do you wish to Restore Global file (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])

echo "\n"
read -p "Enter Global file ----> " gb

$PGHOME/bin/psql -p $PGPORT -v -d $rdbnamm -U postgres -f $PGBACKUP/$DATE/$gb;
echo "\n"

echo "\nThis is Your Database where you want to restore "
echo "****************************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"
echo "****************************"

read -p "Enter your Databae name for restore schema --> " rdbname

echo "\n"

du -sh *.dump *.sql
echo "\n"
read -p "Then Enter postgres_schemas .dump  --> " utarname
read -p "Enter single or multiple schemas with space separated for backup [public ] : " sc
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
echo $sa

$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U postgres $sa $PGBACKUP/$DATE/$utarname; 
end_time
exec_time

echo "\n **** successfully restore **** "
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT schema_name, pg_size_pretty(sum(table_size)::bigint) as schema_size FROM (SELECT pg_namespace.nspname as schema_name, pg_relation_size(pg_class.oid) as table_size FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid where pg_namespace.nspname not like 'pg_%' and pg_namespace.nspname not in('information_schema'))t GROUP BY schema_name ORDER BY schema_name;"

;;

[nN][oO]|[nN])
echo "\n"
read -p " Enter postgres_schemas .dump file --> " utarname
echo "\nThis is Your Database where you want to restore "
echo "*************************"
$PGHOME/bin/psql -p $PGPORT -c "select datname as \"Database\" ,pg_size_pretty(pg_database_size(datname)) as \"Database_size\" from pg_database;"
echo "*************************"

read -p "Enter your Databae name for restore --> " rdbname
echo "\n"

read -p "Enter single or multiple schemas with space separated for backup [public ] : " sc
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
echo $sa

$PGHOME/bin/pg_restore -p $PGPORT -v -d $rdbname -U postgres $sa $PGBACKUP/$DATE/$utarname; 
end_time
exec_time

echo "\n **** successfully restore **** "
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT schema_name, pg_size_pretty(sum(table_size)::bigint) as schema_size FROM (SELECT pg_namespace.nspname as schema_name, pg_relation_size(pg_class.oid) as table_size FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid where pg_namespace.nspname not like 'pg_%' and pg_namespace.nspname not in('information_schema'))t GROUP BY schema_name ORDER BY schema_name;"

;;
esac
}


complete_restore()
{

#if [ -f $PGBACKUP/$DATE/physical_backup_$DATE/base.tar.gz ]
if [ -f $PGBACKUP/$DATE/pg_online_archivebackup_$DATE.tar ]
then
tar -xvf $PGBACKUP/$DATE/pg_online_archivebackup_$DATE.tar -C $PGBACKUP/$DATE
echo "\n Physical Base Tar file exists with size\n"
echo "**********************"
du -sh $PGBACKUP/$DATE/physical_backup_$DATE/*tar.gz  
echo "**********************"
fi
echo "\n"
echo "Restore Location :-- PGBACKUP/Data "
df -h --output=used,avail /tmp/ 

read -p "Restore Full Backup into Restore location (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])

tar -xf $PGBACKUP/$DATE/physical_backup_$DATE/base.tar.gz -C $PGRESTORE
chmod 700 $PGRESTORE
echo "\nsuccessfully restore\n"
cd $PGRESTORE 
#echo "Restore Path  $PGBACKUP/Data \n"
ls -lrth 
echo "\nchange setting in PostgreSQL.conf "
read -p "Enter new cluster port (5432) --->" port
#echo "\nthis is your port $port  "

config_path=$PGRESTORE/postgresql.conf
sed -i 's/port = 5451/#port = 5451/g' $config_path
sed -i 's/#hot_standby = off/hot_standby = on/g' $config_path
echo port = $port >> $config_path

if [ -f $PGRESTORE/recovery.conf ]
then
#rm $PGBACKUP/Data/recovery.conf
echo "restore_command='cp $PGARCH%f %p' " >> $PGRESTORE/recovery.conf
else
echo "restore_command='cp $PGARCH%f %p' " >> $PGRESTORE/recovery.conf
fi

echo "\nsuccessfully assign port $port to postgresql.conf file\n"
#echo "\nsuccessfully assign restore_command to recovery.conf file\n"

start_server;
;;

[nN][oO]|[nN])
echo "exit"
;;
esac
}

restore_archive()
{
if [ -f $PGBACKUP/$DATE/*.tar.gz ]
then
#echo "\n In the following list there is Base Tar file exists\n"
tar -xvf $PGBACKUP/$DATE/pg_online_archivebackup_$DATE.tar -C $PGBACKUP/$DATE
echo "**********************"
cd $PGBACKUP/$DATE/
du -sh *.tar.gz
echo "**********************"
TARCOUNT=`tar -tzf $PGBACKUP/$DATE/pg_archivebackup_$DATE.tar.gz | wc -l`
DIRCOUNT=`find $PGARCH/* -daystart -not -mtime 0 | wc -l`
echo "\nBefore restore archive count\n"
echo "Dircount = $DIRCOUNT \nTarcount = $TARCOUNT "

read -p "Do you wish to Restore archive in to archive location (y/n)...?   " yn
    case $yn in
     #[Yy]* ) break;;
      [Nn]* ) exit;;
     esac

tar -xf $PGBACKUP/$DATE/pg_archivebackup_$DATE.tar.gz -C $PGARCH
DIRCOUNTS=`find $PGARCH/* -daystart -not -mtime 0 | wc -l`
echo "archive restore succussfully completed"
echo "After completion Dircount = $DIRCOUNTS"
fi
}

all_schema_backup()
{

echo "\n Schema level file exists with size\n"
cd $PGBACKUP/$DATE
du -sh *.sql *.tar

echo "\n"
read -p "Do you wish to Restore schema (SQL Queries) backup file (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])

read -p "Enter pg_schemabackup .tar file ----> " sm
$PGHOME/bin/psql -p $PGPORT -v -U $PGUSER -f $PGBACKUP/$DATE/$sm;

;;
[nN][oO]|[nN])
echo "exit"
;;
esac
}

pitr_restore()
{

read -p " Wish You PITR Restore (y/n)...?   " input

case $input in
    [yY][eE][sS]|[yY])
tar -xvf $PGBACKUP/$DATE/pg_online_archivebackup_$DATE.tar -C $PGBACKUP/$DATE
tar -xf $PGBACKUP/$DATE/physical_backup_$DATE/base.tar.gz -C $PITRDATA
chmod 700 $PITRDATA
echo "\nsuccessfully restore\n"
#echo "\nchange setting in PostgreSQL.conf "
#read -p "Enter new cluster port (5432) --->" port
#echo "\nthis is your port $port  "
#config_path=/tmp/db949/postgresql.conf
#sed -i 's/port = 5451/#port = 5451/g' $config_path
#echo port = $port >> $config_path

read -p " Enter Your Target_Time to recover ---> " i
touch $PITRDATA/recovery.conf
echo "restore_command='cp $PGARCH%f %p' " >> $PITRDATA/recovery.conf 
echo "recovery_target_time='$i'" >> $PITRDATA/recovery.conf 

$PGHOME/bin/pg_ctl -D $PGDATA stop
read -p "" yn
echo "\n"
$PGHOME/bin/pg_ctl -D $PITRDATA start
echo "successfully recover"
read -p "" yn
$PGHOME/bin/psql -p $PGPORT

;;

[nN][oO]|[nN])
echo "exit"
;;
esac


#$PGHOME/bin/pg_basebackup -x -v -p $PGPORT -D /tmp/db949       #pitr_restore_directory
#read -p " Enter Your Target_Time to recover ---> " i
#touch /tmp/db949/recovery.conf
#echo "restore_command='cp $PGARCH%f %p' " >> /tmp/db949/recovery.conf
#echo "recovery_target_time='$i'" >> /tmp/db949/recovery.conf
#echo "\n"
#$PGHOME/bin/pg_ctl -D $PGDATA stop
#read -p "" yn
#echo "\n"
#$PGHOME/bin/pg_ctl -D /tmp/db949/ start
#echo "successfully recover"
#read -p "" yn
#$PGHOME/bin/psql -p $PGPORT

}


full_backup_barman()
{

read -p " Enter your barman server user name : " usr
read -p " Enter your barman server host name or ip : " ip

echo  " \n ************************ Barman  backup started ***************** \n" 
ssh -l $usr $ip barman recover main-db-server latest /tmp/barmandata/ 
#echo  " \n ************************ Barman  restore completed ************** \n" 
}

pitr_barman()
{
read -p " Enter your barman server user name : " usr
read -p " Enter your barman server host name or ip : " ip

echo  " \n ************************  Barman PITR started ******************* \n" 
ssh -l $usr $ip barman backup recover --target-time='2018-07-20 16:42:11.589273+05:30' main-db-server 20180720T170909 /tmp/barmanpitrs
#echo  " \n ************************ Barman PITR completed ****************** \n" 
}

echo " ***********************************************************************" | tee -a $logs
echo " List of options to get Restore:\n 1. Logical Restore \n 2. Physical Restore \n 3. Backup tool \n 5. Exit " | tee -a $logs
echo " ***********************************************************************" | tee -a $logs
echo "Enter your option [5] : \c" | tee -a $logs

read op
case $op in 

1) Logical Info;

echo "\n *************************** Chose Restore option **************************** \n" | tee -a $logs

      printf '1.Global Restore :\n2.All Databases Including with Global Backup \n3.Invidual Database Restore with Global backup \n4.Invidual Table Restore with Global Backup \n5.Invidual Schema Restore with Global Backup \n6.Only cluster level Schema Restore (SQL Queries/Commands) \n7.Exit' | tee -a $logs
      echo "Enter your option [6] : \c"   
      read op1
      case $op1 in
      1) 
        global_restore;
      ;;
      2)
      #echo "\nAll Database with Global Backup files \n"
      All_DB_restore;
      ;;
      3)
       #echo "\nParticular Database with Global Backup file exits  \n"
      particular_Database;
      ;;
      4)
      #echo "\nParticular Table with Global Backup file \n"
      particular_Table;
      ;;
      5)
      #echo "\nParticular schema with Global Backup file \n"
      particular_schema;
      ;;
      6)
      all_schema_backup;
      ;;
      7)
      mainmenu;
      esac
;;

2) 

   echo "\n***********************************************************************"
   echo " 1. Restore Full backup with complete recovery \n 2. Restore only archive \n 3. PITR \n 4. Exit "
   echo "\n***********************************************************************"
   echo " Enter you options [3] : \c"
      read op2
      case $op2 in
      1)  #echo "\n Restore Full backup with complete recovery \n"
          complete_restore;
       ;;
       2) echo "\n Restore only archive \n" 
           restore_archive;
       ;;
       3) #echo "\n PITR \n"
            pitr_restore;
       ;;
       4) exit
       ;;
       esac
;;

3) echo "\n**************************************************************************"
   echo " Perform PostgreSQL Restore using Barman tool :\n 1. Full Backup Restore using barman  \n 2. Exit "
   echo "\n*************************************************************************"
   echo " Enter you options [3] \c"
      read op4
      case $op4 in
      1)  echo "\n Restor Full Backup using Barman \n" 
          full_backup_barman;
          ;;
      #2) echo "\n Restore Incremental (PITR) Backup using Barman \n"
         #echo "\nhint :\n"
      #   pitr_barman;

      #;;
      2) exit
      esac
;;
5) exit
;;
6)
mainmenu;
;;

esac


