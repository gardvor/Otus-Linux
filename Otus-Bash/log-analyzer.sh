#!/usr/bin/env bash

lockfile=/tmp/lockfile
 
function display_help () {
    echo -e "\n#### Help guide ####"
    echo -e "\nThis script parse nginx access log and send mail with following information:\n"
    echo -e "  Requests count by status code"
    echo -e "  Top 10 User IP by accessing server"
    echo -e "  Top 10 URL Address"
    echo -e "  List with all errors"
    echo -e "\n## How to use it ##"
    echo -e "  ./log-analyzer.sh /path/to/logfile"
}


function make_report () {
    check_file="cat $1"
    mail_report=./mail.txt
    last_parsed_line_number=$(wc -l $1 | awk '{print $1}')
    
    if [[ -e "./parsed_line_number.tmp" ]]; then
        previous_parsed_line=$(cat ./parsed_line_number.tmp)
        echo "Last parsed line - #$previous_parsed_line."

        if [[ "$previous_parsed_line" = "$last_parsed_line_number" ]]; then
            echo "Log file is already parsed."
            echo "It was run at $(date)"
            exit 2
        else
            check_file="tail --lines=+$previous_parsed_line $1"
        fi
    fi
    
    last_parsed_string=$($check_file | tail -1)
    
    first_event=$($check_file | awk 'NR==1{print $4}' | sed 's/\[//')
    last_event=$($check_file | awk 'END{print $4}' | sed 's/\[//')

    echo $last_parsed_line_number > ./parsed_line_number.tmp
    echo $last_parsed_string > ./parsestr.tmp

    # Form the body of the mail
    echo "### Report statistics ###" > mail_report
    echo -e "\nLog analize events between $first_event - $last_event" >> mail_report
    echo -e "\nRequests count by CODE:" >> mail_report
    
    all_codes=$($check_file | awk '{print $9}' | sort -u | grep -v -)
    for i in $all_codes; do 
        code_count=$($check_file | awk '{ print $9}' | grep $i | wc -l; )
        echo "    Code $i requests count - $code_count" >> mail_report
    done;
    
    echo -e "\nTop 10 User IP by accessing server:" >> mail_report
    $check_file | awk '{print "  " $1}' | sort -nr | uniq -c | sort -rn | head >> mail_report
    echo "" >> mail_report
    
    echo "Top 10 URL Address:" >> mail_report
    $check_file | awk '{print $7}' | sort | uniq -c | sort -nr | head >> mail_report
    echo "" >> mail_report
    
    echo -e "All errors list:" >> mail_report
    $check_file | awk '($9 !~ /200|301/) && $6 ~ /GET|POST|HEAD/' | awk '{print "    "$1" "$4" "$5" "$6" "$7" "$8" "$9}' >> mail_report
    echo "" >> mail_report
    
    echo -e "Last parsed line in log - #$last_parsed_line_number" >> mail_report
    echo -e "Line: $last_parsed_string" >> mail_report
    echo -e "\nRun at $(date)" >> mail_report
}

##!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Main script
##!!!!!!!!!!!!!!!!!!!!!!!!!!!!

if [[ "$1" = "help" ]] ; then
    display_help
else
    if [[ -e "$lockfile" ]]; then 
        echo "Failed to acquire lockfile: $lockfile."
        echo -e "Locked by:\n $(ps aux | grep log-analyzer.sh)"
    else
        echo 1 > $lockfile
        trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

        make_report $1
        mail -s "Report from nginx server" vagrant < mail_report

        rm -f "$lockfile"
        trap - INT TERM EXIT
    fi
fi