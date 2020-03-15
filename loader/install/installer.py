import subprocess
import pprint
import os
#run this script every 10 seconds or so
#get ip user password that are not loaded yet from db, currently from file

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)
    
systems = []
with open("ips.txt","r") as f:
    for line in f:
        systems.append(line.strip().split(","))

for system in systems:
    print(system)
    out = subprocess.Popen(['sh', 'getOS.sh', system[1],system[2],system[0]], 
           stdout=subprocess.PIPE, 
           stderr=subprocess.STDOUT)
    out.wait()
    stdout,stderr=out.communicate()
    output = stdout.decode('utf-8').replace('"','').split('\n')
    details ={}
    for o in output:
        if(o.find("=")!=-1):
            key,value = o.split("=")
            details[key]=value
    # print(output)
    # pprint.pprint(details)
    if("NAME" not in details.keys()):
        details["NAME"] = "Linux"
    if("ID" not in details.keys()):
        details["ID"] = "linux"
    if("VERSION_CODENAME" not in details.keys()):
        details["VERSION_CODENAME"]=""
    if("VERSION_ID" not in details.keys()):
        details["VERSION_ID"]=""
    if("ARCHITECTURE" not in details.keys()):
        details["ARCHITECTURE"]=""
    directoryName = details["ARCHITECTURE"]+"_"+details["NAME"]+"_"+details["ID"]+"_"+details["VERSION_CODENAME"]+"_"+details["VERSION_ID"]
    print(directoryName)
    if(directoryName not in os.listdir("debs")):
        print("Downloading Packages...")
        for line in execute(['sh', 'getDebs.sh', system[1],system[2],system[0],directoryName]):
            print(line, end="")
    else:
        print("Pushing Packages...")
        for line in execute(['sh', 'moveDebs.sh', system[1],system[2],system[0],directoryName]):
            print(line, end="")

    print("Installing Packages...")
    for line in execute(['sh', 'install.sh', system[1],system[2],system[0]]):
        print(line, end="")
    # print(stderr)
#update db that it is loaded