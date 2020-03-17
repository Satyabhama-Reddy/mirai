#!/bin/bash

INPUT=userPassIPFile.txt
OLDIFS=$IFS
IFS=','
uname=""
pass=""
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read ip username password
do
        ip=$ip
		uname=$username
        pass=$password
        echo "trying $ip with $username and $password for $1"
        sshpass -p "$password" ssh -oStrictHostKeyChecking=no $username@$ip "$1" &
done < $INPUT
IFS=$OLDIFS
