sshpass -p "$2" ssh -oStrictHostKeyChecking=no $1@$3 /bin/bash << EOF
echo -n "UNAME=" ; uname -a
echo -n "ARCHITECTURE=" ; dpkg --print-architecture
cat /etc/os-release
EOF
