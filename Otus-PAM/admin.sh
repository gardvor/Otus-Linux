#!/bin/bash

if  [[ `groups $PAM_USER | grep  '\badmin\b'` ]]; # Проверяем нахождение пользователя в группе admin
 then
    exit 0
elif [[ `date +%u` > 5 ]];                        # Проверяем попадание дня на выходные.
 then
   exit 1
else
   exit 0
fi