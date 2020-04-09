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
echo ""

echo "Starting the CNC server"
echo ""
echo ""
nohup python3 ./botnet/server.py &
echo "The CNC Server is up and running"
echo ""
echo ""
echo "Find the logs in <project root>/logs/server.log"
echo ""
echo ""
echo "sleeping for 3 seconds"
sleep 5


echo "Starting the loader"
python3 ./loader/install/installer.py > logs/loader.out &
echo "Loader booted"
echo ""
echo ""
echo "Find the logs in <project root>/logs/loader.log"
echo ""
echo ""
echo "sleeping for 5 seconds"
sleep 5

echo ""
echo ""
echo "staring the run.sh process"
./botnet/run.sh > ./logs/run.log 2>&1 &
echo ""
echo ""
echo "Find the logs in <project root>/logs/run.log"
echo ""
echo ""
echo "Starting the victim server"
echo ""
echo ""
nohup python3 ./victim/victim.py > ./logs/victim.log 2>&1 &
echo "The victim Server is up and running"
echo ""
echo "Find the logs in <project root>/logs/victim.log"
echo ""
sleep 5

sh ./log.sh 10


