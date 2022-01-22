# Otus-Process Management
Домашнее задание OTUS Linux Professional по теме "Управление процессам"

## Что требуется
Домашнее задание выполнялось на CentOS 8


## Домашнее задание
Реализация ps

Вывод команды ps ax
```
[root@server vagrant]# ps ax
    PID TTY      STAT   TIME COMMAND
      1 ?        Ss     0:05 /usr/lib/systemd/systemd --switched-root --system --deserialize 17
      2 ?        S      0:00 [kthreadd]
      3 ?        I<     0:00 [rcu_gp]
      4 ?        I<     0:00 [rcu_par_gp]
      6 ?        I<     0:00 [kworker/0:0H-kblockd]
      8 ?        I<     0:00 [mm_percpu_wq]
 ...
 ```
 * Откуда берутся данные
 
 * PID 
 Числовое имя директории 
 ```
 /proc/<PID>/
 ```
* TTY
7й параметр в выводе cat /proc/[pid]/stat
```
man proc
/proc/[pid]/stat
 (7) tty_nr  %d
                        The controlling terminal of the process.  (The minor device number is contained in the combination of bits 31 to 20 and 7 to 0; the major device number is in bits 15 to 8.)                   
``` 
Например
```
[root@server vagrant]# cat /proc/649/stat
649 (systemd-logind) S 1 649 649 _0_ -1 4194560 1462 0 195 0 34 91 0 0 20 0 1 0 3065 98828288 574 18446744073709551615 94314495643648 94314495869010 140733281150400 0 0 0 16387 4096 0 1 0 0 17 0 0 0 14 0 0 94314497968208 94314497982480 94314513412096 140733281152735 140733281152767 140733281152767 140733281152984 0
```




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
