call cfg\setvars_scripts.cmd

@set SrcPath=..\..\source\db\oracle
cd %SrcPath%
@set OutTemps=..\..\..\distrib\tmp_oracle
@if not exist %OutTemps% MD %OutTemps%

@echo Створення схеми...
@call %sql_util% /nolog @create_work_user.sql %User_name% %User_pass%  %Sysdba_name% %Sysdba_pass% %Oracle_Instance% %SrcPath% >%OutTemps%\create_work_user.log
@echo Наповнювання схеми...
@call %sql_util% /nolog @create_data_base.sql %User_name% %User_pass%  %Sysdba_name% %Sysdba_pass% %Oracle_Instance% %SrcPath% >%OutTemps%\create_object.log

