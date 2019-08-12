#!/usr/bin/env python

import yaml
import json
import os
import fnmatch


# directory to store assets for test or release
assets_dir = os.getcwd()+"/ci/assets"

for file in os.listdir(assets_dir):
    if fnmatch.fnmatch(file, '*index.yaml'): 
        with open(assets_dir + "/" + file, 'r') as s, open(assets_dir + "/" + os.path.splitext(file)[0] +".json", "w") as o:
            try:
                doc = yaml.safe_load(s) 
                o.write(json.dumps(doc, sort_keys = True, indent = 2))
                print("\n Created " + os.path.splitext(file)[0] + ".json file from " + os.path.splitext(file)[0] + ".yaml.")
            except yaml.YAMLError as exc:
                print(exc)

