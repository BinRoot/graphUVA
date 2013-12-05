import json
import glob
import pymongo
import sys

MONGODB_URI = "mongodb://%(user)s:%(pass)s@ds053788.mongolab.com:53788/graphuva" % {"user": "hermes", "pass": "hermes" }

def update(person):
    client = pymongo.MongoClient(MONGODB_URI)
    db = client.graphuva
    db.people2.update({"_id": person["computingId"]}, 
                      {"_id": person["computingId"], 
                       "firstName": person["firstName"],
                       "lastName" : person["lastName"],
                       "email" : person["email"],
                       "computingId": person["computingId"] }, 
                      upsert=True)
    client.close()

if __name__ == '__main__':
    p = {"comp_id": "test" ,
         "firstName": "fn",
         "lastName": "ln",
         "email": "e",
         "computingId": "c" }
    print sys.argv[0]
    ff = sys.argv[0]

    print "reading "+ff
    f = open(ff, 'rw')
    lines = f.readlines()
    for line in lines:
        if line[1]=='#' or line=='"done!"':
            continue
        else:
            per = {}
            spl = line.split(",")
            per["firstName"] = spl[0].replace('"', "")
            per["lastName"] = spl[1]
            per["email"] = spl[2]
            per["computingId"] = spl[-1].replace("\n", "").replace('"', "")
            update(per)
    f.close()
