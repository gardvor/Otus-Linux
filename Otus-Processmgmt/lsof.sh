#!/bin/bash
# Простой аналог lsof

fmt="%-10s %-20s %-30s %15s\n"

printf "$fmt" PID USER NAME COMM

for proc in `ls  /proc/ | egrep "^[0-9]" | sort -n`
    do
    test="/proc/$proc"
   if [[ -d "$test" ]]
    then
    User=`awk '/Uid/{print $2}' /proc/$proc/status`

    comm=`cat /proc/$proc/comm`

    if [[ User -eq 0 ]]
    then
    UserName='root'
    else
    UserName=`grep $User /etc/passwd | awk -F ":" '{print $1}'`
    fi

    map_files=`readlink /proc/$proc/map_files/*; readlink /proc/$proc/cwd`
    if ! [[ -z "$map_files" ]]
    then
    for num in $map_files
    do
    printf "$fmt" $proc $UserName $num $comm
    done
    fi

   fi
done
