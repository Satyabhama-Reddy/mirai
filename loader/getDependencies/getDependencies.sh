packages="packages.txt"
echo > "neededDependencies.txt"
while IFS= read -r line
do
    apt-cache depends "$line" | grep -E 'Depends|Recommends|Suggests' | cut -d ':' -f 2,3 | sed -e s/'<'/''/ -e s/'>'/''/ | tr -d "[:blank:]" >> neededDependencies.txt
    echo "$line" >> neededDependencies.txt
done < "$packages"

