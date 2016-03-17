@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
call cfg\setvars_scripts.cmd

@set SrcPath=..\..\source\db\postgre
cd %SrcPath%

@set OutTemps=..\..\..\distrib\tmp_postgres
@if not exist %OutTemps% MD %OutTemps%

@set CLIENT_ENCODING = 'UTF8'
@set PGCLIENTENCODING = 'UTF8'
@set PGPASSWORD=%pg_User_pass%

@echo Створення таблиць для імпорту
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\11-load_table.sql -L %OutTemps%\11-load.log -o %OutTemps%\11-load.log

@echo Імпорт файлів
@set path_to_file=%cd%\001.01\11-load
echo %path_to_file%
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -v path_to_file='%path_to_file% -v path_to_site='%path_to_site%' -f 001.01\11-load\load_files.sql -L %OutTemps%\11-load_files.log -o %OutTemps%\11-load_files.log

@echo Сбір статистики
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% --command="VACUUM ANALYZE VERBOSE article;" -L %OutTemps%\vacuum_analyze_article.log -o %OutTemps%\vacuum_analyze_article.log

@echo Файли логування процесу дивіться %OutTemps%
