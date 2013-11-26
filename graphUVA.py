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
    q = request.args.get('q')
    process = subprocess.Popen(["./main", q], stdout=subprocess.PIPE)
    output = process.communicate()[0]
    out = json.loads(json.loads(str(output)))

    if 'Right' in out:
        results = out.get("Right")
        transformed = []
        for result in results:
            person = {}
            person["value"] = result.get("firstName") + " " + result.get("lastName")
            person["email"] = None if result.get("email") == "" else result.get("email")
            person["phoneNumber"] = result.get("other").get("phoneNumber")
            person["status"] = result.get("other").get("status")
            person["department"] = result.get("other").get("department")
            person["tokens"] = [result.get("firstName"), result.get("lastName"), result.get("email"), result.get("other").get("phoneNumber")]
            transformed.append(person)
        return json.dumps(transformed)
    else:
        return "[]"

if __name__ == '__main__':
    app.run(debug=True)
