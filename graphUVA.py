from flask import Flask
from flask import request
import subprocess
import os
import sys
import json

app = Flask(__name__)
os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))

@app.route('/search')
def query():
    query = request.args.get('q')
    process = subprocess.Popen(["./main", query], stdout=subprocess.PIPE)
    out = str(process.communicate()[0])
    return json.loads(out)

if __name__ == '__main__':
    app.run(debug=True)
