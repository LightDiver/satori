cls
@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
call cfg\setvars_scripts.cmd

REM  Push to remote repository
"%git_install%\bin\git" push origin %Branch%:%Branch%
"%git_install%\bin\git" push --tags origin %Branch%:%Branch%