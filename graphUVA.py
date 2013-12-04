from flask import Flask
from flask import request
import subprocess
import os
import json

graphUVA = Flask(__name__)
os.chdir('graphUVA')

@graphUVA.route('/search')
def query():
    try:
        q = request.args.get('q')
        process = subprocess.Popen(["./main", q], stdout=subprocess.PIPE)
        output = process.communicate()[0]
        out = json.loads(json.loads(str(output)))

        if 'Right' in out:
            results = out.get("Right")
            transformed = []
            for result in results:
                person = {}
                person["email"] = None if result.get("email") == "" else result.get("email")
                person["phoneNumber"] = result.get("other").get("phoneNumber")
                person["status"] = result.get("other").get("status")
                person["department"] = result.get("other").get("department")
                person["value"] = result.get("firstName") + " " + result.get("lastName") + ("" if person["email"] is None else " " + "(" + person["email"][0:person["email"].find("@")] + ")")
                person["name"] = result.get("firstName") + " " + result.get("lastName")
                person["tokens"] = [result.get("firstName"), result.get("lastName"), result.get("email")]
                transformed.append(person)
            return json.dumps(transformed)
        else:
            return "[]"
    except:
        return "[]"

@graphUVA.route('/')
def index():
    return "Landing"

if __name__ == '__main__':
    graphUVA.run()
