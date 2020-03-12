sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
mkdir ~/predownload
mkdir ~/predownload/install
touch ~/predownload/names.txt
EOF
packages="../getDependencies/neededDependencies.txt"
while IFS= read -r line
do
    sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
    cd  ~/predownload/install
    echo "$2" | sudo -S apt-get download $line
    cd  ~/predownload
    echo $line
    ls install -rt >> names.txt
    mv ~/predownload/install/* .
EOF
done < "$packages" 
sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
rmdir ~/predownload/install
EOF
mkdir ./debs/$4
sshpass -p "$2" scp -oStrictHostKeyChecking=no $1@$3:~/predownload/* ./debs/$4/