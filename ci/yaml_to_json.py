#!/usr/bin/env python

import yaml
import json
import os


with open(os.getcwd()+"/index.yaml", 'r') as s, open(os.getcwd()+"/index.json", "w") as o:
    try:
        doc = yaml.safe_load(s) 
        o.write(json.dumps(doc, sort_keys = True, indent = 2))
        print("\n Created index.json file from index.yaml.")
    except yaml.YAMLError as exc:
        print(exc)