# Created by Shreeyansh

#!/bin/sh

#source /home/postgres/SY_dbascripts/pg_env_96.sh
. /opt/PostgreSQL/9.5/SY_dbascripts/pg_env_96.sh



echo -e "\n*************************************************************************************************"
echo -e "\t\t\t\tLong Running Locking/Waiting Queries Information\n"
echo -e "\nEnter database name [postgres]: \c"
read db
db=${db:-postgres}
#echo -e "\t\t\tLocking Queries Information\n" 
count=$($PGHOME/bin/psql -p $PGPORT -d $db -Atc "WITH t_wait AS (SELECT a.mode, a.locktype, a.database, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a, transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND NOT a.granted and b.datname='$db'), t_run AS (Select a.mode, a.locktype, a.database, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a, transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND a.granted and b.datname='$db') SELECT count(distinct r.pid) \"Count\" from t_wait w, t_run r where r.locktype is not distinct from w.locktype and r.database is not distinct from w.database and r.relation is not distinct from w.relation and r.page is not distinct from w.page and r.tuple is not distinct from w.tuple and r.classid is not distinct from w.classid and r.objid is not distinct from w.objid and r.objsubid is not distinct from w.objsubid")
#echo -e "$count"

#<<comment
#while [ $count = ]
#for (( i=0; i<=$count; i++ ))
for i in count
do

echo -e "\n"
echo -e "\t\t\t\t\t      ************************"
echo -e "\t\t\t\t\t      * Long Running Queries *"
echo -e "\t\t\t\t\t      ************************\n"

# use below query <=9.4

#$PGHOME/bin/psql -d $db -c "select pid AS \"PID\", date_trunc('second',query_start::timestamp) AS \"Started Since\", waiting AS \"Waiting\", date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting Since\", substr(query,1) AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and waiting='f' and state not in ('idle','active') and now() - query_start > interval '1 minutes' and datname='$db' order by pid limit 25"

# use below query >=9.5

$PGHOME/bin/psql -p $PGPORT -d $db -c "select pid AS \"PID\", date_trunc('second',query_start::timestamp) AS \"Started Since\", state AS \"State\",date_trunc('second',now()::timestamp) - date_trunc('second',query_start::timestamp) AS \"Waiting Since\", substr(query,1) AS \"Query\" from pg_stat_activity where pid<>pg_backend_pid() and state != 'idle' and now() - query_start > interval '1 minutes' and datname='$db' order by pid limit 25"

#Parent
echo -e "\t\t\t\t\t  **********************************"
echo -e "\t\t\t\t\t  * Parent Locking/Waiting Queries *"
echo -e "\t\t\t\t\t  **********************************\n"
$PGHOME/bin/psql -p $PGPORT -d $db -c "WITH t_wait AS (SELECT a.mode, a.locktype, a.database, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a, transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND NOT a.granted and b.datname='$db'), t_run AS (Select a.mode, a.locktype, a.database, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a, transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND a.granted and b.datname='$db') SELECT distinct r.pid \"Pid\", r.relation :: regclass \"Table Name\", r.locktype \"Lock Type\", r.mode \"Lock Mode\", r.usename \"User Name\", date_trunc('second',r.query_start::timestamp) \"Started Since\", r.query \"Query\" from t_wait w, t_run r where r.locktype is not distinct from w.locktype and r.database is not distinct from w.database and r.relation is not distinct from w.relation and r.page is not distinct from w.page and r.tuple is not distinct from w.tuple and r.classid is not distinct from w.classid and r.objid is not distinct from w.objid and r.objsubid is not distinct from w.objsubid order by r.pid"

#Child
echo -e "\t\t\t\t\t***************************************"
echo -e "\t\t\t\t\t* Child Locking Queries Due to Parent *"
echo -e "\t\t\t\t\t***************************************\n"
$PGHOME/bin/psql -p $PGPORT -d $db -c "WITH t_wait AS (SELECT a.mode, a.locktype, a.DATABASE, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a.transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname	FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND NOT a.granted and b.datname='$db'), t_run AS (SELECT a.mode, a.locktype, a.DATABASE, a.relation, a.page, a.tuple, a.classid, a.objid, a.objsubid, a.pid, a.virtualtransaction, a.virtualxid, a.transactionid, b.query, b.xact_start, b.query_start, b.usename, b.datname FROM pg_locks a, pg_stat_activity b WHERE a.pid = b.pid AND a.granted and b.datname='$db') SELECT distinct w.pid \"Child Pid\", r.pid \"Parent Pid\", w.mode \"Lock Mode\", w.usename \"User Name\", date_trunc('second',w.query_start::timestamp) \"Start Since\", date_trunc('second',now()::timestamp) - date_trunc('second',w.query_start::timestamp) AS \"Waiting Duration\", w.query \"Query\" FROM t_wait w, t_run r WHERE r.locktype IS NOT DISTINCT FROM w.locktype AND r.DATABASE IS NOT DISTINCT FROM w.DATABASE	AND r.relation IS NOT DISTINCT FROM w.relation AND r.page IS NOT DISTINCT FROM w.page AND r.tuple IS NOT DISTINCT FROM w.tuple	AND r.classid IS NOT DISTINCT FROM w.classid AND r.objid IS NOT DISTINCT FROM w.objid AND r.objsubid IS NOT DISTINCT FROM w.objsubid order by w.pid"

echo -e "\n*************************************************************************************************\n"

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
			$PGHOME/bin/psql -p $PGPORT -d $db -c "select pg_terminate_backend(pid) from pg_stat_activity where datname='$db' and pid in ($pid)" >/dev/null
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
#	exit
	break
fi
done
#comment
