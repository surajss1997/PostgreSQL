#!/bin/bash

. /home/postgres/SY_cronjobs/pg_env_10.sh

START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')

#sed -i "5s/^/Start Time: `date` \n/" $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
SCRIPTNAME=pg_cluster_info.sh
echo  "\n!!****************************************************************************************!!\n" > $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
#sed -i "1s/^/**************************************************************************************\n/" $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
sed -i "3s/^/\nScript: $SCRIPTNAME: Start Time: $st\n\n/" $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\nPostgreSQL Cluster Details\n\nCustomer Name = $CUSTNAME\nHost Name = $HOSTNAME\nDatabase Name = $PGDATABASE\nPort = $PGPORT\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#echo -e "PostgreSQL Cluster  Details\n\nCustomer Name = Shreeyansh Technologies\nHost Name = Localhost\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!****************************************************************************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "Script Contains Following Information:\n  1.Database Details\n  2.User Details\n  3.TableSpace Details\n  4.Languages Installed\n  5.Extensions Installed\n  6.PostgreSQL Parameter Settings\n  7.Control Data Details\n  8.PostgreSQL Host Authentication Deatils\n  9.Number of idle Connections" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!********************************[DataBase Details]*****************************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#echo -e "Size of Database Size\n"
$PGHOME/bin/psql -c "SELECT datname AS "Database",pg_size_pretty(pg_database_size(datid)) as Size FROM pg_stat_database db WHERE UPPER(db.datname) != 'TEMPLATE0' AND UPPER(db.datname) != 'TEMPLATE1';" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!*********************************[User Details]*****************************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\nUser Name | User Id  | Create db   | Superuser|  Update   | InitiateStreaming\n\t" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "select usename,usesysid,usecreatedb,usesuper, userepl as Initiate_Streaming_Replication from pg_user" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!****************************[TableSpace Details]******************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log 
echo  "TableSpace Name  |Tablespacese Size  |Tablespace Location\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "SELECT pg_tablespace.spcname as Tablespace_Name,pg_size_pretty(pg_tablespace_size(spcname))as Tablespacese_size,pg_tablespace_location(pg_tablespace.oid)  FROM  pg_tablespace;" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#echo -e "\n!!---------------------------Schema Details-------------------------------------------!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
#echo -e " Schema Name | Schema Owner | Database Name\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#DATABASES=`$PGHOME/bin/psql -h $MASTER_IP -p $PGPORT -t -c "select datname from pg_database where datname not in ('template0','template1');"`

#for i in $DATABASES; do
#$PGHOME/bin/psql -U $PGUSER -p $PGPORT -tc "select schema_name,schema_owner,catalog_name from information_schema.schemata;" >> $PGCRONLOGS/$DATE/schema_details_$DATE.log
#$PGHOME/bin/psql -U $PGUSER -d $i -p $PGPORT -tc "select schema_name,schema_owner,catalog_name from information_schema.schemata where schema_name not in('pg_toast','pg_temp_1','pg_toast_temp_1','pg_catalog','information_schema') ;" >>  $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#done
echo  "\n!!***********************************[Languages Installed]*************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#echo -e "  Name\t| Language Owner | Trusted/Untrusted Language\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT l.lanname AS "Name", pg_catalog.pg_get_userbyid(l.lanowner) as "Owner", l.lanpltrusted AS "Trusted", d.description AS "Description" FROM pg_catalog.pg_language l LEFT JOIN pg_catalog.pg_description d ON d.classoid = l.tableoid AND d.objoid = l.oid AND d.objsubid = 0 WHERE l.lanplcallfoid != 0 ORDER BY 1;" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!***********************************[Extensions Installed]*************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "SELECT e.extname AS "Name", e.extversion AS "Version", n.nspname AS "Schema", c.description AS "Description" FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass ORDER BY 1;" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log


echo  "\n!!***********************************[PostgreSQL Setting Details]*************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
echo  " Parameter Name\t\t    | Parameter Status/Values          | Non default\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "select name,setting,source from pg_settings where source in('override') or source in ('configuration file') or source in ('environment variable') and name not in('template0','template1', 'krb_server_keyfile') order by source;" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n\n!!**********************************[PostgreSQL Setting Details]*************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
echo  " Parameter Name\t\t\t     | Parameter Status/Values  | Default\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "select name,setting,source from pg_settings where source in('default') and name not in('template0','template1', 'krb_server_keyfile') order by source;" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n!!*********************************[Control Data Details]*********************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

$PGHOME/bin/pg_controldata $PGDATA/ >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
echo  "\n!!**************************[PostgreSQL Host Authentication Details]*************************!!" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

#echo "Database Information " >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
sed -n "82,97p" $PGDATA/pg_hba.conf >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

echo  "\n\n!!**********************************[Number of Idle Connections]*************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
$PGHOME/bin/psql -c "select pid, date_trunc('second',(now()-backend_start)) || ' Sec ' as Start_time from pg_stat_activity where state='idle' order by backend_start" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
echo  "\n!!*************************************[END]***********************************************!!\n" >> $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

END=$(date +"%T.%3N");
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')

StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')


#mail -s "Critical Disk Space on Partition "$partition" Space: "$space" - HOSTNAME=`hostname` " manoj.kathar@shreeyansh.com <$PGCRONLOGS/$DATE/pg_disk_space_$DATE.log

#mail -r "manoj.kathar@shreeyansh.com" -s "PostgreSQL Cluster Information - HOSTNAME=`hostname` :: Database =$PGDATABASE :: Port=$PGPORT :: Data Directory= $PGDATA " vinod.rathod@shreeyansh.com<$PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

sed -i "6s/^/Total Execution Time (HH:MM:SS:MS)    :  $Exe \n/" $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log
sed -i "5s/^/\nScript: $SCRIPTNAME: End Time  : $en \n/" $PGCRONLOGS/$DATE/pg_cluster_info_$DATE.log

