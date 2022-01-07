if  [[ `groups $PAM_USER | grep  '\badmin\b'` ]];
 then
    exit 0
fi  
elif [[ `date +%u` > 5 ]];
 then
   exit 1
else
   exit 0
fi