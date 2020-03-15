sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
rm -rf ~/predownload
mkdir ~/predownload
EOF
sshpass -p "$2" scp -oStrictHostKeyChecking=no ./debs/$4/* $1@$3:~/predownload/