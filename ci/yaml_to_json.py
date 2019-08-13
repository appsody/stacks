#!/usr/bin/env python

import yaml
import json
import os
import fnmatch
from collections import OrderedDict 

# directory to store assets for test or release
assets_dir = os.getcwd() + "/ci/assets"

for file in os.listdir(assets_dir):
  if fnmatch.fnmatch(file, '*index.yaml'):
    with open(assets_dir + "/" + file, 'r') as s, open(assets_dir + "/" + os.path.splitext(file)[0] + ".json", "w") as o:
        try:
            doc = yaml.safe_load(s)
            #print doc
            i = 0
            if (doc['stacks'] != None):
                
                for item in doc['stacks']:
                    # print item
                    # print
                    
                    res = (OrderedDict([
                        ("displayName", item['name']),
                        ("description", item['description']),
                        ("language", item['id']),
                        ("projectType", "appsodyExtension"),
                        ("projectStyle", "Appsody"),
                        ("location", item['templates'][0]['url']),
                        ("links", OrderedDict([
                                                ("self", "/devfiles/" + item['id'] + "/devfile.yaml")
                        ]))
                    ]))
                    i += 1
                    # print i
                    # print len(doc['stacks'])
                    # print item
                    # print
                    # print
                    
                    if i == 1:
                        o.write("[\n")
                        o.write(json.dumps(res, indent = 5))
                        o.write(",")
                    else:
                        o.write("\n")
                        o.write(json.dumps(res, indent = 5))
                        if i == len(doc['stacks']):
                            o.write("]")
                        else:
                            o.write(",")

        except yaml.YAMLError as exc:
            print(exc)