@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
call cfg\setvars_scripts.cmd

@set SrcPath=..\..\source\db\postgre
cd %SrcPath%

@set OutTemps=..\..\..\distrib\tmp_postgres
@if not exist %OutTemps% MD %OutTemps%

del %OutTemps%\*.log

@set CLIENT_ENCODING = 'UTF8'
@set PGCLIENTENCODING = 'UTF8'

@echo Створення Користувача(Роль) ...
@call "%pg_install%"\psql.exe -h %pg_host% -U postgres -v pg_User_name=%pg_User_name% -v pg_User_pass='%pg_User_pass%' -f create_work_userrole.sql -o %OutTemps%\create_work_userrole.log
@echo Створення BD ...
@call "%pg_install%"\psql.exe -h %pg_host% -U postgres -v pg_User_name=%pg_User_name% -f create_data_base.sql -o %OutTemps%\create_db.log


@echo Створення Схем(потипу як в Ораклі Пакети використувуватись будуть) ...
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U postgres -v pg_User_name=%pg_User_name% -f create_scheme.sql -o %OutTemps%\create_scheme.log

@set PGPASSWORD=%pg_User_pass%
@echo Наповнювання даними...
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\02-main.sql -o %OutTemps%\02-main.log

@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\06-body\pkg_article.sql -o %OutTemps%\pkg_article.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\06-body\pkg_systeminfo.sql -o %OutTemps%\pkg_systeminfo.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\06-body\pkg_users.sql -o %OutTemps%\pkg_users.log

@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\08-func.sql -o %OutTemps%\08-func.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\09-trig.sql -o %OutTemps%\09-trig.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% -f 001.01\20-init.sql -o %OutTemps%\20-init.log

@echo Сбір статистики
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %pg_User_name% --command="VACUUM ANALYZE;" -o %OutTemps%\vacuum_analyze.log




