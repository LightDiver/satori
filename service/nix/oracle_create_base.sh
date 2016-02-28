#!/bin/bash

if [ ! -f cfg/setvars_scripts.sh ]
then
   echo "Copy setvars script. Please set variables"
   cp cfg/setvars_scripts.git cfg/setvars_scripts.sh
fi

source ./cfg/setvars_scripts.sh
echo "Oracle_Instance = $Oracle_Instance"
echo "Postgres_DB = $Postgres_DB"

SrcPath=../../source/db/oracle
cd $SrcPath
OutTemps=../../../distrib/tmp_oracle
if [ ! -d $OutTemps ]
then
   mkdir -p $OutTemps
fi

pwd
echo Create user...
 exec $sql_util /nolog @create_work_user.sql $User_name $User_pass $Sysdba_name $Sysdba_pass $Oracle_Instance $SrcPath >$OutTemps/create_user.log &
wait
echo Create objects ...
 exec $sql_util /nolog @create_data_base.sql $User_name $User_pass $Sysdba_name $Sysdba_pass $Oracle_Instance $SrcPath >$OutTemps/create_object.log &

echo see logs

