#             scripts is created by Shreeyansh DB Software Pvt Ltd.                                                                                                                                 
#             Author Name: Emilesh                                                                                                                                                                                               
#             Script Name: pg_database_parameter.sh                                                                                                                                                                                                     
#             Version 1.0                                                                                                                                                                                                
#             This script will give you the username and DDL command fired by them
################################################################################################################################

#!/bin/bash
#TIME=$(date +"%T.%2N")
#DATE=`date +%Y-%m-%d`
SCRIPTNAME=pg_database_parameter.sh 

. /home/postgres/SY_cronjobs/pg_env_10.sh

LOG=$PGCRONLOGS/$DATE/pg_database_parameter.log

start_time()
{
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
echo "*******************Name of the script: $SCRIPTNAME  Script Start Time:$st*************************" | tee -a $LOG
}

end_time()
{
END=$(date +"%T.%3N");
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
echo "*******************Name of the script: $SCRIPTNAME  Script End Time:$en*************************" | tee -a $LOG
}

exec_time()
{
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N")
echo "Total Execution Time :$Exe" | tee -a $LOG
}

start_time;

echo "PostgreSQL Cluster  Details\n\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\n" | tee -a $LOG                              

echo "\nScript contains following information:\n  :- Database Paramater List\n " | tee -a $LOG                                                            

echo "\n!!--------------------------------PostgreSQL Paramater Setting Details-------------------------------------------!!\n" | tee -a $LOG

echo " Parameter Name\t\t\t     | Parameter Status/Values\t\t\t       | Default/Nondefault\n" | tee -a $LOG

psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "select name,setting,source from pg_settings where name not in('template0','template1', 'krb_server_keyfile') order by source; " | tee -a $LOG

#$PARAMETER_SETTING/setting_all_$TODAY.log 

end_time;
exec_time;



