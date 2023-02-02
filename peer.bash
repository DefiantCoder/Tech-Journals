#! /bin/bash

#storyline: Create peer vpn configuration file


# whats peers name
echo -n "What is the peer's name? "
read the_client

# filename variable
pFile="${the_client}-wg0.conf"

echo "${pFile}"

# check if the peer file exist
if [[ -f "${pFile}" ]]
then

    # prompt if need to overwrite file
    echo "The file ${pFile} exist."
    echo -n "Do you want to overwrite it? [Y|N]"
    read to_overwrite

if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
    then

        echo "Exit..."
        exit 0

    elif [[ "${to_overwrite}" == "Y" ]]
    then
        echo "Creating the wireguard configuration file..."

    # if the admin doean't specify a y or a n then error
    else

        echo "Invalid value"
        exit 1

    fi

fi

# generate key
p="$(wg genkey)"

# gen pub key
clientPub="$(echo ${p} | wg pubkey)"

# gen preshared key
pre="$(wg genpsk)"

# endpoint
end="$(head -1 wg0.conf  | awk ' { print $3 } ')"

# Server public key
pub="$(head -1 wg0.conf  | awk ' { print $4 } ')"

# DNS servers
dns="$(head -1 wg0.conf  | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf  | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf  | awk ' { print $7 } ')"

# ListenPort
lport="$(shuf -n1 -i 40000-50000)"

tempIP=$(grep  AllowedIPs wg0.conf | sort -u | tail -1 | cut -d\. -f4 | cut -d\/ -f1)
ip=$(expr ${tempIP} + 1)

# defualt routes for VPN
routes="$(head -1 wg0.conf  | awk ' { print $8 } ')"

# create client config file
echo "[Interface]
Address = 10.254.132.${ip}/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[peer]
AllowedIps = ${routes}
peersistentKeepAlive = ${keep}
Presharedkey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# add peer config to the server
echo "
# adam begin
[peer]
Publickey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.${ip}/32
# adam end" | tee -a wg0.conf
