#!/usr/bin/env python

import yaml
import json
import os
import fnmatch
import sys
from collections import OrderedDict

base_dir = os.path.abspath(os.path.dirname(sys.argv[0]))

# directory to store assets for test or release
assets_dir = base_dir + "/assets"

for file in os.listdir(assets_dir):
    if fnmatch.fnmatch(file, '*index.yaml'):
        with open(assets_dir + "/" + file, 'r') as yamlFile, open(assets_dir + "/" + os.path.splitext(file)[0] + ".json", 'w') as jsonFile:
            try:
                doc = yaml.safe_load(yamlFile)
                list = []

                if (doc['stacks'] != None):
                    for item in doc['stacks']:
                        default = item['default-template']

                        # get url for current default template
                        for n in range(0, len(item['templates'])):
                            if default == item['templates'][n]['id']:
                                url = item['templates'][n]['url']

                        # populate stack details
                        res = (OrderedDict([
                            ("displayName", "Appsody " + item['name'] + " template"),
                            ("description", item['description']),
                            ("language", ""),
                            ("projectType", "appsodyExtension"),
                            ("projectStyle", "Appsody"),
                            ("location", url),
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