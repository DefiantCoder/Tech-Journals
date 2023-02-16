#! /bin/bash

# Storyline: Extract IPs from emergingthreats.net and create firewall ruleset

#  alert tcp [2.59.200.0/22,5.134.128.0/19,5.180.4.0/22,5.183.60.0/22,5.188.10.0/23,24.137.16.0/20,24.170.208.0/20,24.233.0.0/19,24.236.0.0/19,27.126.160.0/20,27.146.0.0/16,31.14.65.0/24,31.40.156.0/22,36.0.8.0/21,36.37.48.0/20,36.116.0.0/16,36.119.0.0/16,37.156.64.0/23,37.156.173.0/24,41.72.0.0/18] any -> $HOME_NET any (msg:"ET DROP Spamhaus DROP Listed Traffic Inbound group 1"; flags:S; reference:url,www.spamhaus.org/drop/drop.lasso; threshold: type limit, track by_src, seconds 3600, count 1; classtype:misc-attack; flowbits:set,ET.Evil; flowbits:set,ET.DROPIP; sid:2400000; rev:3028; metadata:affected_product Any, attack_target Any, deployment Perimeter, tag Dshield, signature_severity Minor, created_at 2010_12_30, updated_at 2021_09_30;)

# Regex to extract the networks
#2.		59.		200.		0/	19

# wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules


function create_badIPs() {

	# Pull the emerging-drop.suricata.rules file from the website and make it into the file emerging-drop.suricata.rules in the tmp directory
	wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules

	# read the emerging-drop.suricata.rules file and organize it to create the badips.txt file
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badips.txt

}



#See if emerging threats file exists prior to downloading from the internet
if [[ -f badIPs.txt  ]]
	then
		read -p "The badIPs.txt file already exists. Would you like to redownload it? [y][n]: " answer
		case "$answer" in
			y|Y)
				echo  "Creating badIPs.txt..."
				create_badIPs
			;;
			n|N)
				echo "Not redownloading badIPs.txt..."
			;;
			*)	
				echo "Invalid value."
				exit 1
			;;
		esac

	else
		echo "The badIPs.txt file does not exist yet. Downloading file..."
		create_badIPs
fi



#This allows for  choosing which OS things get written for
while getopts 'icnfmp' OPTION ; do

	case "$OPTION" in
		i) iptables=${OPTION}
		;;
		c) cisco=${OPTION}
		;;
		f) wfirewall=${OPTION}
		;;
		m) macOS=${OPTION}
		;;
		p) parse=${OPTION}
		;;
		*)

			echo "Invalid Value"
			exit 1
		;;

	esac
done



# If iptables is input then create the iptables drop rule
if [[ ${iptables}  ]]
then
	for eachip in $(cat badips.txt)
	do
		echo "iptables -a input -s ${eachip} -j drop" | tee -a  badips.iptables
	done
	clear
	echo "Created IPTables firewall drop rules in file \"badips.iptables\""
fi

# Cisco
if [[ ${cisco} ]]
then

#CISCO RULES
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips.nocidr
	for eachip in $(cat badips.nocidr)
	do
		echo "deny ip host ${eachip} any" | tee -a badips.cisco
	done
	rm badips.nocidr
	clear
	echo 'Created IP Tables for firewall drop rules in file "badips.cisco"'
fi



# Windows Firewall
if [[ ${wfirewall} ]]
then

#WINDOWS RULES (from before)
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badips.txt | tee badips.windowsform
	for eachip in $(cat badips.windowsform)
	do
		echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}" | tee -a badips.netsh
	done
	rm badips.windowsform
	clear
	echo "Created IPTables for firewall drop rules in file \"badips.netsh\""
fi

# MacOS
if [[ ${macOS} ]]
then

#MAC OS RULES
	echo '
	scrub-anchor "com.apple/*"
	nat-anchor "com.apple/*"
	rdr-anchor "com.apple/*"
	dummynet-anchor "com.apple/*"
	anchor "com.apple/*"
	load anchor "com.apple" from "/etc/pf.anchors/com.apple"

	' | tee pf.conf

	for eachip in $(cat badips.txt)
	do
		echo "block in from ${eachip} to any" | tee -a pf.conf
	done
	clear
	echo "Created IP tables for firewall drop rules in file \"pf.conf\""
fi

# Parse Cisco
if [[ ${parseCisco} ]]
then
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachip in $(cat threats.txt)
	do
		echo "match protocol http host \"${eachip}\"" | tee -a ciscothreats.txt
	done
	rm threats.txt
	echo 'Cisco URL filters file successfully parsed and created at "ciscothreats.txt"'
fi


#function menu2() {
#	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/blocks.csv 
#
#	tempIP=$(grep  AllowedIPs wg0.conf | sort -u | tail -1 | cut -d\. -f4 | cut -d\>
#	ip=$(expr ${tempIP} + 1)







#egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt

#firewall ruleset

#for eachIP in $(cat badIPs.txt)
#do
# 	echo "block in from ${eachIP} to any" | tee -a /etc/pf.conf
#	echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPs.iptables 
#done
