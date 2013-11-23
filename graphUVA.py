from flask import Flask
import subprocess
import os
import sys

app = Flask(__name__)
os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))

@app.route('/')
def index():
    p = subprocess.Popen(["./main", "jasdev"], stdout=subprocess.PIPE)
    return p.communicate()[0]

if __name__ == '__main__':
    app.run(debug=True)
