#!/bin/bash

if [ ! -f cfg/setvars_scripts.sh ]
then
   echo "Copy setvars script. Please set variables"
   cp cfg/setvars_scripts.git cfg/setvars_scripts.sh
fi

source ./cfg/setvars_scripts.sh

SrcPath=../../source/db/oracle/001.01/11-load
cd $SrcPath
OutTemps=../../../../../distrib/tmp_oracle
if [ ! -d $OutTemps ]
then
   mkdir -p $OutTemps
fi



echo Загрузка в спеціальну таблицю файлів...
 exec $sql_load userid=$User_name/$User_pass@$Oracle_Instance control=load_files.ctl log=$OutTemps/lob_load.log bad=$OutTemps/lob_load.bad &
 wait
echo Обробка...
 exec $sql_util /nolog @adaptation.sql $User_name $User_pass $Oracle_Instance $SrcPath $path_to_site >$OutTemps/adaptation_load_object.log &

