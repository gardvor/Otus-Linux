#!/bin/bash

lockfile=/var/local/bash.lock
logfile=access.log
security=security.log

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;then   
	trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT KILL   
	rm -f "$lockfile"  
	trap - INT TERM EXIT
else  
	echo "Failed to acquire lockfile: $lockfile."  
	echo "Held by $(cat $lockfile)"
fi

# check line file
if test -f "$security"; then
    wasLine=$(cat $security)
    curLine=$(wc -l $logfile | awk '{ print $1 }')
    diffLine=$((curLine-wasLine))
    echo $curLine > $security
else
        curLine=$(wc -l $logfile | awk '{ print $1 }')
        echo $curLine > $security
        diffLine=$curLine
fi

if [ $diffLine -ne 0 ]; then

# date range
firstNewLine=$((wasLine+1))
startDate=$(sed -n "$firstNewLine{p;q}" $logfile | awk '{print $4}' | cut -c2-)
endDate=$(sed -n "$curLine{p;q}" $logfile | awk '{print $4}' | cut -c2-)

# tops
top10=$(tail -n $diffLine $logfile | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 10)
top10URL=$(tail -n $diffLine $logfile | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 10)

# http errors only
httpErrors=()
for i in {400..511}
do
   count=$(tail -n $diffLine $logfile | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | wc -l)
   if [ $count -ne 0 ]; then
   result=$(tail -n $diffLine $logfile | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 1)
   httpErrors+=("$i - $result")
fi
done

# count all http codes
for i in {100..511}
do
   count=$(tail -n $diffLine $logfile | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | wc -l)
   if [ $count -ne 0 ]; then
        httpCodes+=("$i - $count")
fi
done

# normalization
errorhttp=$(printf '%s\n' "${httpErrors[@]}")
codeshttp=$(printf '%s\n' "${httpCodes[@]}")

# send email
echo -e "Time range:\n $startDate - $endDate\n\n Top 10 ip-addresses:\n $top10\n\n Top 10 requests:\n $top10URL\n\n HTTP errors:\n $errorhttp\n\n All HTTP codes:\n $codeshttp" | mail -s "Лог nginx" $1

else
	echo -e "Лог файл не был изменен" | mail -s "Лог nginx" $1
fi
