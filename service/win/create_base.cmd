call cfg\setvars_script.cmd

@set SrcPath=..\..\source\db\oracle
@set OutTemps=..\..\distrib\tmp_oracle
@if not exist %OutTemps% MD %OutTemps%

@echo ��������� �����...
@call %sql_util% /nolog @%SrcPath%\create_work_user.sql %User_name% %User_pass%  %Sysdba_name% %Sysdba_pass% %Oracle_Instance% %SrcPath% >%OutTemps%\create_work_user.log
@echo ������������ �����...
@call %sql_util% /nolog @%SrcPath%\create_data_base.sql %User_name% %User_pass%  %Sysdba_name% %Sysdba_pass% %Oracle_Instance% %SrcPath% >%OutTemps%\create_object.log

