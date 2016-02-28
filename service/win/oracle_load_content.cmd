call cfg\setvars_scripts.cmd

@set SrcPath=..\..\source\db\oracle\001.01\11-load
cd %SrcPath%
@set OutTemps=..\..\..\..\..\distrib\tmp_oracle
@if not exist %OutTemps% MD %OutTemps%

@echo Загрузка в спеціальну таблицю файлів...
@call %sql_load% userid=%User_name%/%User_pass%@%Oracle_Instance% control=load_files.ctl log=%OutTemps%\lob_load.log bad=%OutTemps%\lob_load.bad
@echo Обробка...
@call %sql_util% /nolog @adaptation.sql %User_name% %User_pass% %Oracle_Instance% %SrcPath% %path_to_site% >%OutTemps%\adaptation_load_object.log

