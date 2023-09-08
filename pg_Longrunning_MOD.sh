#!/bin/bash

echo "\n********************************************************************************************" 
echo " Script createdb by : Shreeyansh DB Software Pvt Ltd "
echo " Script author      : Mayuri Shinde " 
echo " Script Description : This script use find out all long running queries & also to kill those queries if needed " 
echo " script name        : $0"
echo "\n********************************************************************************************"

source /var/lib/pgsql/script/pg_env_94.sh

echo -e "\n ****** Enter the time interval to findout the Queries running  more than the time interval provided by you ****** \n"
echo -e "To enter interval in Minutes, press [1] 
      To enter interval in hour, press [2]
       To enter interval in day, press [3]"
echo -e "Enter your option here:\c"
read option
if [ $option -eq 1 ];
then
{
echo -e "\nEnter Interval In Minutes[1]: \c"
read min
#min=${min:-1}
echo $min
}

elif [ $option -eq 2 ]; 
then
{
echo -e "\nEnter Interval In Hours[1]: \c"
read hr
min=$(($hr*60))
echo $min  
}

elif [ $option -eq 3 ]; 
then
{
echo -e "\nEnter Interval In Days[1]: \c"
read day
min=$(($day*1440))
echo $min
}

else 
{
echo "You entered wrong option"
}

fi

echo -e "\t\t\t\tLong Running Queries Information \n"
echo "\n\n *************************** The most waiting queries are from *************************************\n"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select  date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by \"Waiting From\" desc limit 1"

echo "\n\n *************************** Long running Queries ************************************************** \n"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid AS \"PID\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\", date_trunc('second',query_start::timestamp) AS \"Started Since\", query AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by \"Waiting From\" desc"
echo -e "\n*************************************************************************************************\n"

echo -e "\n\nWhat action you want: \c "

echo -e "\n1. Kill All pids\n2. Kill pids Dynamically\n3. Exit"

echo -e "Enter your choice:\c"
read act


if [ "$act" -eq 1 ]
then
echo -e "\nAre you sure [ Y / N ]? \c"
read s

if [ "$s" = "Y" -o "$s" = "y" ] 
then

#$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pg_terminate_backend(pid) from pg_stat_activity where waiting='t';"
#echo -e "\n******Removed all The waiting queries******* "
#$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pid,waiting,query from pg_stat_activity where waiting='t';"

$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pg_terminate_backend(pid), date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by \"Waiting From\" desc"
echo -e "\n\n********Removed all the Long running queries*************"
$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pid,waiting,query,date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting From\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' order by \"Waiting From\" desc"


elif [ "$s" = "n" -o "$s" = "N" ]
then

echo -e "No pid is killed"
fi
fi
 

if [ "$act" -eq 2 ]
then

echo -e "Please enter comma sepearted pid's of waiting sessions: \c"
read pid

pid=${pid:-0,0}

if [ "$pid" = "0,0" ]
then
echo -e "\nNo pid supplied exiting\n"
else
#$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from pg_stat_activity where waiting='t' and pid in ($pid)"
$PGHOME/bin/psql -d $PGDATABASE -U $PGUSER -p $PGPORT -c "select pg_terminate_backend(pid) from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and now() - query_start > interval '$min minutes' and pid in ($pid)"
fi
fi




