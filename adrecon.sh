#!/bin/bash

# Setting IP variable
ip=$1
domain=$2
dcname=$3

if [ "$1" == "" ];then
	echo "Syntax is: adrecon <IP Address> <Host Name> <DC Name>"
	exit
fi

if [ "$2" == "" ];then
	echo "Syntax is: adrecon <IP Address> <Host Name> <DC Name>"
	exit
fi

if [ "$3" == "" ];then
	echo "Syntax is: adrecon <IP Address> <Host Name> <DC Name>"
	exit
fi

# Create new directory/files
if [ ! -d "adrecon" ];then
	mkdir adrecon
	cd adrecon
	mkdir ldap
	mkdir enum4linux
	mkdir smbclient
	cd ..
fi

# Enumerate LDAP
echo "[+] Enumerating ldap ..."
nmap -n -sV --script "ldap* and not brute" -p 389 -oA adrecon/ldap/ldap $ip > /dev/null
echo "[+] Finished enumerating ldap, output in $PWD/adrecon/ldap"

# Enumerating Shares
echo -ne '\n\n'
echo "[+] Listing shares with smbclient ..."
smbclient -L \\\\$ip\\ -N > adrecon/smbclient/smbclient 2>/dev/null
echo "[+] Finished listing shares, output in $PWD/adrecon/smbclient" 
echo -ne '\n\n'

# enum4linux
echo "[+] Running enum4linux ..."
enum4linux -a $ip | tee adrecon/enum4linux/enum4linux.log > /dev/null 2>/dev/null
echo "[+] Finished running enum4linux, output in $PWD/adrecon/enum4linux"
echo -ne '\n\n'

# ZeroLogon Checker
echo "[+] Checking if host if vulnerable to ZeroLogon ..."
if [[ $(python3 /opt/ZLtester/zerologon_tester.py $dcname $ip) = *Success!* ]];then
	echo "Host is VULNERABLE to ZeroLogon"
else
	echo "Host is NOT vulnerable to ZeroLogon"
fi
echo -ne '\n\n'

# Ask for kerbrute
echo "Would you like to run kerbrute? (y/n): "
read response
if [[ $response == "y" ]];then
	echo "[+] Running kerbrute (This will take some time) ..."
	/opt/kerbrute_linux_amd64 userenum -d $domain --dc $domain /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt
else
	echo "Goodbye!"
fi
