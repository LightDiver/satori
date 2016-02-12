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
@call "%pg_install%"\psql.exe -h %pg_host% -U postgres -v User_name=%User_name% -v User_pass='%User_pass%' -f create_work_userrole.sql -o %OutTemps%\create_work_userrole.log
@echo Створення BD ...
@call "%pg_install%"\psql.exe -h %pg_host% -U postgres -v User_name=%User_name% -f create_data_base.sql -o %OutTemps%\create_db.log


@echo Створення Схем(потипу як в Ораклі Пакети використувуватись будуть) ...
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U postgres -v User_name=%User_name% -f create_scheme.sql -o %OutTemps%\create_scheme.log

@set PGPASSWORD=%User_pass%
@echo Наповнювання даними...
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %User_name% -f 001.01\02-main.sql -o %OutTemps%\02-main.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %User_name% -f 001.01\06-body.sql -o %OutTemps%\06-body.log
@call "%pg_install%"\psql.exe -h %pg_host% -d %Postgres_DB% -U %User_name% -f 001.01\20-init.sql -o %OutTemps%\20-init.log



