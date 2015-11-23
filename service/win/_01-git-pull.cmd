cls
@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
call cfg\setvars_scripts.cmd

REM Pull source to local repository
"%git_install%\bin\git" pull origin %Branch%
"%git_install%\bin\git" fetch origin
"%git_install%\bin\git" fetch --tags
"%git_install%\bin\git" checkout %Branch%
"%git_install%\bin\git" merge origin/%Branch%



