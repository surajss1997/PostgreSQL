
#!/bin/bash

. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
logs=$PGCRONLOGS/$DATE/pg_user_details_$DATE.log
touch $logs
echo "" > $logs
echo "\t***********************************************************************************************************" | tee -a $logs
echo " \t\tScript createdb by : Shreeyansh DB Software Pvt Ltd " | tee -a $logs
echo " \t\tScript author      : Manoj Kathar " | tee -a $logs
echo " \t\tScript Description : This script use to findout user roles in PostgreSQL " | tee -a $logs
echo " \t\tscript name        : $0" | tee -a $logs  

echo "\t***********************************************************************************************************\n" | tee -a $logs

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

echo " \t****** List of users and it's role in PostgreSQL *******\n"
script="SELECT rolname as user, CASE WHEN rolcanlogin THEN 'user' ELSE 'group' END AS Role, CASE WHEN rolsuper THEN 'SUPERUSER' ELSE 'normal' END AS  super FROM pg_authid ORDER BY rolcanlogin , rolname;"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "$script" | tee -a $logs
end_time
exec_time
