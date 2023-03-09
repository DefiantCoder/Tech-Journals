#!/bin/bash

# checks if the file exists
read -p "Please enter an apache log file " tFile
if [[ ! -f ${tFile} ]]
then
  echo "File doesn't exists."
  exit 1
fi

# grabs  the IP addresses from the log file
while read p; do 
    echo "${p}" | awk '{print $1}' >> IPruleset.txt
done < "$tFile"



sort IPruleset.txt > IPruleset_2.txt #sort IPs
awk '!x[$0]++' IPruleset_2.txt > IPruleset.txt #remove duplicates IPs

# Creates the ruleset for iptables using ip addresses
while read p; do 
    echo "iptables -A INPUT -s ${p} -j DROP" | tee -a badIPs.iptables 
    
done < IPruleset.txt
