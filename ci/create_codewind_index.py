#!/usr/bin/env python3

import yaml
import json
import os
import fnmatch
import sys
from collections import OrderedDict

base_dir = os.path.abspath(os.path.dirname(sys.argv[0]))

displayNamePrefix = "Appsody"
if len(sys.argv) > 1:
    displayNamePrefix = sys.argv[1]

# directory to store assets for test or release
assets_dir = base_dir + "/assets/"

for file in os.listdir(assets_dir):
    if fnmatch.fnmatch(file, '*index.yaml'):
        with open(assets_dir + file, 'r') as yamlFile, open(assets_dir + os.path.splitext(file)[0] + ".json", 'wb') as jsonFile:
            try:
                doc = yaml.safe_load(yamlFile)
                list = []

                if (doc['stacks'] != None):
                    for item in doc['stacks']:

                        # get template name 
                        for n in range(0, len(item['templates'])):
                            if len(item['templates'])==1:
                                template = ""
                            else:
                                template = " " + item['templates'][n]['id']

                            # populate stack details
                            res = (OrderedDict([
                                ("displayName", displayNamePrefix + " " + item['name'] + template + " template"),
                                ("description", item['description']),
                                ("language", item['language']),
                                ("projectType", "appsodyExtension"),
                                ("projectStyle", "Appsody"),
                                ("location", item['templates'][n]['url']),
                                ("links", OrderedDict([
                                    ("self", "/devfiles/" +
                                        item['id'] + "/devfile.yaml")
                                ]))
                            ]))
                            list.append(res)

                jsonFile.write(json.dumps(list, indent=4, ensure_ascii=False).encode('utf8'))
                print("Generated: " + os.path.splitext(file)[0] + ".json")

            except yaml.YAMLError as exc:
                print(exc)
