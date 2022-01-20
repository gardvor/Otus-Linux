# Otus-Process Management
Домашнее задание OTUS Linux Professional по теме "Управление процессам"

## Что требуется
Домашнее задание выполнялось на CentOS 8


## Домашнее задание
Реализация ps

```
fmt="%-10s%-30s%-10s%-20s%-20s%-10s%-500s\n"
printf "$fmt" PID NAME  TTY USERNAME  STAT RSS COMMAND
for proc in `ls /proc/ | egrep "^[0-9]" | sort -n`
do

    if [[ -f /proc/$proc/status ]]
        then
        PID=$proc

    if  [[ -f /proc/$proc/stat ]]
        then
    CMD=`cat /proc/$proc/cmdline  | tr '\0' '\n' 
    else
        CMD=`n\a`
    fi

    Name=`cat /proc/$proc/status | awk '/Name/{print $2}'`
    TTY=`cat /proc/$proc/stat | rev | awk '{print $46}' | rev`
    User=`awk '/Uid/{print $2}' /proc/$proc/status`
    Stat=`cat /proc/$proc/status | awk '/State/{print $2}'`
    RSS=`cat /proc/$proc/status | awk '/VmRSS/{print $2}'`
    if [[ User -eq 0 ]]
       then
       UserName='root'
    else
       UserName=`grep $User /etc/passwd | awk -F ":" '{print $1}'`
    fi
    printf "$fmt" $PID $Name $TTY $UserName $Stat $RSS "$CMD"
    fi
done
```
