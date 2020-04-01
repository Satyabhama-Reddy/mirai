sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
rm -rf ~/predownload
mkdir ~/predownload
mkdir ~/predownload/install
touch ~/predownload/names.txt
EOF
sshpass -p "$2" scp -oStrictHostKeyChecking=no "loader/getDependencies/neededDependencies.txt" $1@$3:~/predownload/

    sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
cd ~/predownload
packages="neededDependencies.txt"
while IFS= read -r line
do
    cd  ~/predownload/install
    echo "$2" | sudo -S apt-get download \$line
    cd  ~/predownload
    echo \$line
    echo \$line,\$(ls install) >> names.txt
    # ls install -rt >> names.txt
    mv ~/predownload/install/* .
done < "\$packages"
EOF
 
sshpass -p "$2" ssh $1@$3 -oStrictHostKeyChecking=no /bin/bash << EOF
rmdir ~/predownload/install
EOF
mkdir loader/install/debs/$4
sshpass -p "$2" scp -oStrictHostKeyChecking=no $1@$3:~/predownload/* loader/install/debs/$4/