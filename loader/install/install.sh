sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
cd ~/predownload
while IFS= read -r line
do 
echo "\$line"
echo "$2" | sudo -S dpkg -i "\$line"
done < names.txt  
EOF