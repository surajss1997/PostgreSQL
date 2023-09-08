#!bin/bash
source /var/lib/pgsql/script/pg_env_94.sh

n=`$PGHOME/bin/psql -qAtc "select count(*) from pg_stat_activity where state='idle'"`
echo -e "\nNumber of Idle Connections on host-$HOSTNAME: $n"
if [ $n -gt 0 ]
then
echo -e "\nList of Idle connections: "
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid as \"Pid\",(extract(epoch from  localtimestamp-backend_start)/60)::numeric(5,2)|| ' minutes' as \"Idle Since\" from pg_stat_activity where state='idle' order by backend_start"
echo -e "Please select option to release Idle connections:\n1. ALL\n2. Enter pid's to release Idle connections \n3. Exit"
echo -e "\nChoice: \c "
read choice
choice=${choice:-3333}
if [ "$choice" -eq 1 ]
then
echo -e "\nAre you sure???[y]: \c"
read sure
sure=${sure:-y}
if [ "$sure" = y ]
then
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from pg_stat_activity where state='idle'"
echo -e "\nAll Idle sessions are cancelled\n"
fi
elif [ "$choice" -eq 2 ]
then
echo -e "Please enter comma seperated pid's of idle sessions: \c"
read pid
pid=${pid:-0,0}
if [ "$pid" = "0,0" ]
then
echo -e "\nNo pid supplied exiting\n"
else
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pg_terminate_backend(pid) from pg_stat_activity where state='idle' and pid in ($pid)" 
fi
elif [ "$choice" = "3333" ]
then
echo -e "\nNo choice selected\n"
elif [ "$choice" -gt 3 -o "$choice" -lt 1 ]
then  
echo -e "\nWrong Choice exiting\n"
else 
#--
#n=`$PGHOME/bin/psql -qAtc "select count(*) from pg_stat_activity where  state='idle'"`
if [ "$choice" -eq 3 ]
then
echo -e "\n"
exit
fi
fi
echo -e "\nFollowing Sessions are still Idle\n"
$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select pid as \"Pid\',(extract(epoch from  localtimestamp-backend_start)/60)::numeric(5,2)|| ' minutes' as \"Idle Since\" from pg_stat_activity where state='idle' order by backend_start"

else
echo -e "\nNo idle sessions found \n"
fi


#--
#n=`$PGHOME/bin/psql -qAtc "select count(*) from pg_stat_activity where  state='idle'"`
#if [ "$n" -eq 1 ]
#then
#echo -e "\n$n Session is still idle\n"
#else
#echo -e "\n$n Sessions are still idle\n"
#fi

