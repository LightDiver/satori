cls
@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
@ if not exist cfg\message_commits.txt copy cfg\message_commits.git cfg\message_commits.txt
call cfg\setvars_scripts.cmd

REM Commit to local repository
"%git_install%\bin\git" add ..\..\.
start /wait "¬ведите комментарий" "%git_editor%" cfg\message_commits.txt
"%git_install%\bin\git" commit -a -F cfg\message_commits.txt


