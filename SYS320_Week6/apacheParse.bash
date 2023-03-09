#!/bin/bash

# Function: Parses a log file and formats it

# read in file

#Arguments using the position starting at 1

APACHE_LOG="$1"

#Checking if file exists

if [[ ! -f ${APACHE_LOG} ]]
then
	echo "Please specify the path to a log file"
	exit 1 
fi

# Looking for web scanners

# 81.19.44.12 - - [30/Sep/2018:06:26:56 -0500] "GET / HTTP/1.1" 200 225 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:57.0) Gecko/20100101 Firefox/57.0"
#looking for web scanners
sed -e "s/\[//g" -e "s/\"//g" ${APACHE_LOG} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
awk ' BEGIN { format = "%-15s %-20s %-6s %-6s %-5s %s\n" 
		printf format, "IP", "Date", "Method", "Status", "Size", "URI"
		printf format, "--", "----", "------", "------", "----", "---"}
		
{ printf format, $1, $4, $6, $9, $10, $7 }'
