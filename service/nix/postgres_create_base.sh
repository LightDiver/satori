#!/bin/bash

if [ ! -f cfg/setvars_scripts.sh ]
then
   echo "Copy setvars script. Please set variables"
   cp cfg/setvars_scripts.git cfg/setvars_scripts.sh
fi

source ./cfg/setvars_scripts.sh
echo "Postgres_DB = $Postgres_DB"

SrcPath=../../source/db/postgre
cd $SrcPath
OutTemps=../../../distrib/tmp_postgres
if [ ! -d $OutTemps ]
then
   mkdir -p $OutTemps
fi

pwd

#del %OutTemps%\*.log

CLIENT_ENCODING=UTF8
PGCLIENTENCODING=UTF8

echo Створення Користувача(Роль) ...
 exec $pg_install/psql -h $pg_host -U postgres -v pg_User_name=$pg_User_name -v pg_User_pass='$pg_User_pass' -f create_work_userrole.sql -L $OutTemps/create_work_userrole.log &
wait
echo Створення BD ...
 exec $pg_install/psql -h $pg_host -U postgres -v pg_User_name=$pg_User_name -f create_data_base.sql -L $OutTemps/create_db.log &
wait
    
echo Створення Схем(потипу як в Ораклі Пакети використувуватись будуть) ...
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U postgres -v pg_User_name=$pg_User_name -f create_scheme.sql -L $OutTemps/create_scheme.log &

PGPASSWORD=$pg_User_pass
echo Наповнювання даними...
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/02-main.sql -L $OutTemps/02-main.log -o $OutTemps/02-main.log &
wait

exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/06-body/pkg_article.sql -L $OutTemps/pkg_article.log -o $OutTemps/pkg_article.log &
wait
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/06-body/pkg_systeminfo.sql -L $OutTemps/pkg_systeminfo.log -o $OutTemps/pkg_systeminfo.log &
wait
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/06-body/pkg_users.sql -L $OutTemps/pkg_users.log -o $OutTemps/pkg_users.log &
wait

exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/08-func.sql -L $OutTemps/08-func.log -o $OutTemps/08-func.log &
wait
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/09-trig.sql -L $OutTemps/09-trig.log -o $OutTemps/09-trig.log &
wait
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/20-init.sql -L $OutTemps/20-init.log -o $OutTemps/20-init.log &
wait

echo Сбір статистики
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name --command="VACUUM ANALYZE;" -L $OutTemps/vacuum_analyze.log -o $OutTemps/vacuum_analyze.log &

echo Файли логування процесу дивіться $OutTemps





