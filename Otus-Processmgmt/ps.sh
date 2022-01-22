#!/bin/bash
# Задаем формат таблицы
fmt="%-10s%-30s%-10s%-20s%-20s%-100s\n"
printf "$fmt" PID NAME TTY USERNAME STAT COMMAND
for proc in `ls /proc/ | egrep "^[0-9]" | sort -n`
do

    if [[ -f /proc/$proc/status ]]
        then
        PID=$proc

   if [[ -f /proc/$proc/stat ]]
        then
   CMD=`cat /proc/$proc/cmdline | tr '\0' '\n'` # Обработка от ошибки line 14: warning: command substitution: ignored null byte in input
        else
        CMD=`n\a`
    fi
    Name=`cat /proc/$proc/status | awk '/Name/{print $2}'`
    User=`awk '/Uid/{print $2}' /proc/$proc/status`
    Stat=`cat /proc/$proc/status | awk '/State/{print $2}'`
    TTY=`cat /proc/$proc/stat | rev | awk '{print $46}' | rev` # В cat /proc/$proc/stat параметр {print $2} может быть пустым поэтому вместо {print $7 }го берем {print $46} параметр с конца.
    if [[ User -eq 0 ]]
       then
       UserName='root'
    else
       UserName=`grep $User /etc/passwd | awk -F ":" '{print $1}'`
    fi
    printf "$fmt" $PID $Name $TTY $UserName $Stat $CMD
    fi
done
