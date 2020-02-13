#!/usr/bin/env python3

import yaml
import json
import os
import fnmatch
from collections import OrderedDict
import argparse
from argparse import ArgumentDefaultsHelpFormatter

parser = argparse.ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)

parser.add_argument("-n", "--namePrefix", help="Display name prefix.", default="Appsody")
parser.add_argument("-f", "--file", help="Location of yaml files.", default=os.getcwd())

args = parser.parse_args()

displayNamePrefix = args.namePrefix

yaml_dir = args.file + "/"

def generate_json():
    with open(yaml_dir + file, 'r') as yamlFile, open(yaml_dir + os.path.splitext(file)[0] + ".json", 'wb') as jsonFile:
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

if os.path.isdir(yaml_dir):
    for file in os.listdir(yaml_dir):
        if fnmatch.fnmatch(file, '*.yaml'):
            generate_json()
else:
    yaml_dir = yaml_dir.rsplit('/', 2)[0] + "/"
    file = args.file.split('/')[-1]
    generate_json()