sshpass -p "$2" ssh -oStrictHostKeyChecking=no $1@$3 /bin/bash << EOF
killall sshpass
killall botrun.sh
killall ssh
killall ping
sleep 1
killall sshpass
killall botrun.sh
killall ssh
killall ping
EOF
echo "cleanup done"