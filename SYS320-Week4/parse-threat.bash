#!/bin/bash

# Storyline: Use EmergingThreats.net to make firewall rules

# Options for running script, add them when running to get desired outcome

helptext="Menu Options:
-i : Iptables
-c : Cisco
-w : Windows
-m : Mac
-u : Parse URL
-h : Help
"

while getopts 'Menu' OPTION ; do

    case $OPTION in

        i) iptables=${OPTION}
        ;;
        c) cisco=${OPTION}
        ;;
        w) windows=${OPTION}
        ;;
        m) mac=${OPTION}
        ;;
        u) url=${OPTION}
        ;;
        h)
            echo "${helptext}"
            exit 0
        ;;
        *)
            echo "${helptext}"
            exit 1
        ;;

    esac

done



if [[ -z "${iptables}${cisco}${windwos}${mac}${url}" ]]
then
    echo "${helptext}"
    exit 1
fi


# Regex to extract the networks

if [[ -f 'tmp/emerging-drop.suricata.rules' ]]
then

    # Prompt if we need to redownload the file
    echo 'The IP rules file already exists.'
    echo -n 'Do you want to redownload it? (y/N) '
    read to_redownload

    if [[ "${to_redownload}" == 'y' || "${to_redownload}" == 'Y' ]]
    then
        wget 'https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules' -O tmp/emerging-drop.suricata.rules
    fi
else
    mkdir tmp
    wget 'https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules' -O tmp/emerging-drop.suricata.rules
fi


grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' tmp/emerging-drop.suricata.rules | sort -u | > badIPs.txt


# Create iptables firewall

if [[ -n ${iptables} ]]; then
    for eachIP in $(cat badIPs.txt)
    do
        echo "iptables -A INPUT -s ${eachIP} -j DROP" | >> badIPs.iptables
    done
fi

#####################################################




if [[ -n ${cisco} ]]; then
    for eachIP in $(cat badIPs.txt)
    do
        echo echo "deny ip host ${eachIP} any" | >> badips.cisco # copied from JQExample
    done
fi

#######################################################




if [[ -n ${windows} ]]; then
    for eachIP in $(cat badIPs.txt)
    do
        echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachIP}\" dir=in action=block remoteip=${eachIP}" | >> badips.netsh # copied from JQExample
    done
fi
#######################################################



if [[ -n ${mac} ]]; then
    echo '
    scrub-anchor "com.apple/*"
    nat-anchor "com.apple/*"
    rdr-anchor "com.apple/*"
    dummynet-anchor "com.apple/*"
    anchor "com.apple/*"
    load anchor "com.apple" from "/etc/pf.anchors/com.apple"

    ' | > pf.conf

    for eachIP in $(cat badIPs.txt)
    do
        echo  "block in from ${eachIP} to any" | >> pf.conf
    done
fi


#######################################################




# #3 parse this file
if [[ -n ${url} ]]; then
    if [[ -f 'tmp/targetedthreats.csv' ]]
    then
        # Prompt  to redownload the file
        echo 'The URL rules file already exists.'
        echo -n 'Do you want to redownload it? (y/N) '
        read to_redownload

        if [[ "${to_redownload}" == 'Y' || "${to_redownload}" == 'y' ]]
        then
            wget 'https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv' -O tmp/targetedthreats.csv
        fi
    else
        mkdir tmp
        wget 'https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv' -O tmp/targetedthreats.csv
    fi

    echo 'class-map match-any BAD_URLS' | > badURLs.cisco

    for eachIP in $(grep '"domain"' tmp/targetedthreats.csv | awk -F , '{print $2}')
    do
        echo "match protocol http host ${eachIP}" >> badURLs.cisco
    done

fi
