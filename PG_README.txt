******************************* Read it very carefully before scheduling DB scripts ******************************

********************** All the scheduling scripts to be copied under    - $HOME/SY_cronjobs **********************
********************* All the DBA day to day scripts to be copied under - $HOME/SY_dbascripts *********************

NOTE: $HOME represents your Postgres home directory.
NOTE: You need to create subdirectories SY_cronjobs & SY_dbascripts in your Postgres's HOME directory ($HOME)

pg_env_<pgversion>.sh file is used to set up Environment variable for your requirements and it's need to be modified as per your settings and its path to be provided in .bash_profile Or .profile of your postgres OS login.
Ex: If your Postgres version is 9.6, rename pg_env_<pgversion>.sh to pg_env_96.sh and perform your Env changes. Source it's path in your .bash_profile or .profile to invoke it. Add the below command in Postgres login's .bash_profile or .profile
source $HOME/SY_cronjobs/pg_env_96.sh
Verify all the set Environment variable using echo $PGDATA or $PGHOME commands to cross check.

NOTE: Please DO NOT run any script manually as environment source path is commented which results in error while executing script, So please follow the crontab procedure as shown below.

Cronjob Scheduling Process:

Only environment variable set should be used while scheduling cronjobs and no complete path should be provided and each scripts sholud be followed with its usage notes.
Ex: 
# ************** pg_cluster_info.sh provides complete information about PostgreSQL Cluster **************
* 	* 	*   *	*		. /home/postgres/SY_cronjobs/pg_env_<version>.sh; $PGCRONJOBS/pg_cluster_info.sh

