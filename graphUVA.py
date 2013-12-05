from flask import Flask
from flask import request
import subprocess
import os
import json
import pymongo
import datetime
import copy
from pytz import timezone

graphUVA = Flask(__name__)
graphUVA.config.from_envvar('SETTINGS')

os.chdir('graphUVA')

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
MONGODB_URI = "mongodb://%(user)s:%(pass)s@ds053788.mongolab.com:53788/graphuva" % {"user": graphUVA.config['USER'], "pass": graphUVA.config['PASSWORD'] }

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

@graphUVA.route('/update')
def update():
    client = pymongo.MongoClient(MONGODB_URI)
    try:
        db = client.graphuva
        comp_id = request.args.get('id')
        cur_eastern = datetime.datetime.now(timezone('US/Eastern')).strftime(DATETIME_FORMAT)
        db.people.update({"_id": comp_id},  {"$inc": {"count": 1}, "$set": {"last_searched": cur_eastern}})
        return json.dumps({"state": "success"})
    except:
        return json.dumps({"state": "error", "message": "Problem with id - %(id)s" % request.args.get('id')})
    finally:
        client.close()

@graphUVA.route('/top')
def top():
    client = pymongo.MongoClient(MONGODB_URI)
    try:
        db = client.graphuva
        cursor = db.people.find().sort([("count", -1)]).limit(10)
        results = []
        for doc in cursor:
            person = copy.copy(doc)
            results.append(person)
        return json.dumps(results)
    except:
        return json.dumps({"state": "error", "message": "Problem retrieving top 10"})
    finally:
        client.close()

@graphUVA.route('/')
def index():
    return "landing page yo"

if __name__ == '__main__':
    graphUVA.run(debug=True)
