#!/bin/bash

if [ ! -f cfg/setvars_scripts.sh ]
then
   echo "Copy setvars script. Please set variables"
   cp cfg/setvars_scripts.git cfg/setvars_scripts.sh
fi

source ./cfg/setvars_scripts.sh

SrcPath=../../source/db/postgre
cd $SrcPath

OutTemps=../../../distrib/tmp_postgres
if [ ! -d $OutTemps ]
then
   mkdir -p $OutTemps
fi

CLIENT_ENCODING='UTF8'
PGCLIENTENCODING='UTF8'
PGPASSWORD=$pg_User_pass

echo "Створення таблиць для імпорту"
 exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -f 001.01/11-load_table.sql -L $OutTemps/11-load.log -o $OutTemps/11-load.log &
wait

echo "Імпорт файлів"
path_to_file=$PWD/001.01/11-load
echo $path_to_file
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name -v path_to_file=\'$path_to_file -v path_to_site=\'$path_to_site\' -f 001.01/11-load/load_files.sql -L $OutTemps/11-load_files.log -o $OutTemps/11-load_files.log &
wait

echo "Сбір статистики"
exec $pg_install/psql -h $pg_host -d $Postgres_DB -U $pg_User_name --command="VACUUM ANALYZE VERBOSE article;" -L $OutTemps/vacuum_analyze_article.log -o $OutTemps/vacuum_analyze_article.log &

echo "Файли логування процесу дивіться $OutTemps"
