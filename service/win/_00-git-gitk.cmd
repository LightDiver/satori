@ if not exist cfg\setvars_scripts.cmd copy cfg\setvars_scripts.git cfg\setvars_scripts.cmd
call cfg\setvars_scripts.cmd
@start "gitk" "%git_install%\cmd\gitk" -- %*



