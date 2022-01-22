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
 ### Откуда берутся данные
 
 ### PID 
 * Числовое имя директории 
 ```
 /proc/[pid]/
 ```
### TTY
* 7й параметр в выводе cat /proc/[pid]/stat
```
man proc
/proc/[pid]/stat
 (7) tty_nr  %d
                        The controlling terminal of the process.  (The minor device number is contained in the combination of bits 31 to 20 and 7 to 0; the major device number is in bits 15 to 8.)                   
```
* В cat /proc/$proc/stat параметр {print $2} может быть пустым поэтому вместо {print $7 } берем {print $46} параметр с конца через двойной rev.
 
### COMMAND
* Параметр из cat /proc/[pid]/cmdline
```
[root@server vagrant]# cat /proc/649/cmdline
/usr/lib/systemd/systemd-logind
```
 

### User
* Строка UID из cat /proc/[pid]/status
* Берем и  сравниваем со строками /etc/passwd
    
```
[root@server vagrant]# cat /proc/649/status 
Name:   systemd-logind
Umask:  0022
State:  S (sleeping)
Tgid:   649
Ngid:   0
Pid:    649
PPid:   1
TracerPid:      0
Uid:    0       0       0       0
Gid:    0       0       0       0
```
### Stat
Строка State из cat /proc/[pid]/status 
```
[root@server vagrant]# cat /proc/649/status 
Name:   systemd-logind
Umask:  0022
State:  S (sleeping)
```
## Проблемы
* TTY выдается числом, как узнать из этого числа строку типа tty1 пока не понял судя по man proc как-то кодируется.
* COMMAND вывод выдает ошибку 
```
line 14: warning: command substitution: ignored null byte in input
```
* ошибку убрал обработкой строки tr '\0' '\n' но из-за этого у вывода команды съезжают на новую строку параметры запуска. 
