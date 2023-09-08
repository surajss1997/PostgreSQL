#!/bin/bash
# script created by : Mayuri Shinde
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh
#source /home/postgres/script/env.sh
echo  "\n******************* ||| Active state queries ||| **************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where state='active' and pid <> pg_backend_pid();"
echo  "\n******************* ||| Idle state queries ||| ****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where state= 'idle';"
echo  "\n******************* ||| Idle in transaction state queries ******************* \n\n" 
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where state='idle in transaction';"
echo  "\n******************* ||| BIND state queries ||| ****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where state='BIND';"
echo  "\n******************* ||| PARSE state queries |||****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where state='PARSE';"
echo  "\n******************* ||| for update queries  |||****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where query like '%for update%' and pid <> pg_backend_pid();"
echo  "\n******************* ||| lock table queries |||****************************** \n\n"
$PGHOME/bin/psql -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select pid,backend_start,xact_start,query_start,wait_event_type,state,query from pg_stat_activity where query like '%lock%' and pid <> pg_backend_pid();"
echo -e "Do you want to continue ?"
echo -e "\n1 - Kill Pid\n2 - Exit"
echo -e "\nEnter Any One Option [2]: \c"
read op
op=${op:-2}
if [ $op = 1 ]; then
echo -e "Enter Pid: \c"
read pid
echo -e "\nAre you sure you want to kill? [ Y | N ]: \c"
read yn
if [ "$yn" = Y -o "$yn" = y ]; then
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from pg_stat_activity where  pid in ($pid)" >/dev/null
echo -e "Pid $pid Killed"
echo -e "\n*************************************************************************************************\n"
<<comment
echo -e "Do you want to continue? : \c"
read con
if [ "$con" = Y -o "$con" = y ] then
else
break
fi
comment
else
echo -e "\n*************************************************************************************************\n"
break;
fi
else
#exit
break
fi

#done

#comment

