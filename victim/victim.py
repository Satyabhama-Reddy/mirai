from flask import Flask 
from flask import abort

import time
count = 1
app = Flask(__name__) 
  
@app.route('/') 
def hello_world(): 
    global count
    if(count>10):
        abort(503)
        return ""
    count += 1
    time.sleep(2)
    count -= 1
    return " " + str(count) + " "
  
if __name__ == '__main__': 
    app.run(host="0.0.0.0",port=5000,debug=True) 