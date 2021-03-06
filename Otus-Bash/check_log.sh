#!/bin/bash
# Защита от повторного запуска
lockfile=/tmp/lockfile
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

    # Считывание значения из файла
    linesquantity=$(cat ./lines 2>/dev/null)
    status=$?

    # Сколько строк в файле
    checkLines=$(wc ./access-4560-644067.log | awk '{print $1}')

    # Если возвращается пустое значение, т.е. его нет, тогда считаем количество строк и записываем значение в файл
    if ! [ -n "$linesquantity" ]
    then
        # Дата начала и конца
        timeHead=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n 1p)
        timeLast=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
        # Запись количества строк в файле
        echo $checkLines > ./lines
        # Определение количества запросов с IP адресов (Выводим адрес если запросов с адреса было от 5 и больше)
        IP=$(awk "NR>$checkLines"  access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов:" $1, "IP:" $2 } }')
        # Количество запрашиваемых адресов (Выводим если запрашиваемых адресов было от 10 и больше)
        addresses=$(awk "NR>$checkLines" access-4560-644067.log | awk '($9 ~ /200/)' | awk '{print $7}'| sort |uniq -c | sort -rn | awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
        # все ошибки c момента последнего запуска (Ошибками считаю коды от 400 и выше)
        errors=$(awk "NR>$checkLines" access-4560-644067.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn | awk '{ if ( $2 >= 400 ) { print "Колличество ошибок:" $1, "Код ошибки:" $2}}')
        # Отправка почты
        echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost

        rm -f "$lockfile"
        trap - INT TERM EXIT

    else
        # Дата начала и конца
        timeHead=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$(($number+1))"p)
        timeLast=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
        # Определение количества запросов с IP адресов (Выводим адрес если запросов с адреса было от 5 и больше)
        IP=$(awk "NR>$(($number+1))"  access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 5 ) { print "Количество запросов:" $1, "IP:" $2 } }')
        # Количество запрашиваемых адресов (Выводим если запрашиваемых адресов было от 10 и больше)
        addresses=$(awk "NR>$(($number+1))" access-4560-644067.log | awk '($9 ~ /200/)' | awk '{print $7}'| sort |uniq -c | sort -rn | awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
        # все ошибки c момента последнего запуска (Ошибками считаю коды от 400 и выше)
        errors=$(awk "NR>$(($number+1))" access-4560-644067.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn | awk '{ if ( $2 >= 400 ) { print "Колличество ошибок:" $1, "Код ошибки:" $2}}')
        # Запись количества строк в файле
        echo $checkLines > ./lines
        # Отправка почты
        echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost
        
        rm -f "$lockfile"
        trap - INT TERM EXIT
    fi
else
  echo "Failed to acquire lockfile: $lockfile"
  echo "Held by $(cat $lockfile)"

fi
