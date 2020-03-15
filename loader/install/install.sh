sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
cd ~/predownload
IFS=','
while read -r package file
do 
dpkg-query -s \$package > /dev/null 2>&1
if [ \$? -eq 1 ]
then
    echo "\$package Not there..Installing"
    echo "$2" | sudo -S dpkg -i "\$file"
else
    echo "\$package Already Present"
fi
done < names.txt  
EOF