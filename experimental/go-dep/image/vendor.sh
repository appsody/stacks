#!/bin/bash
mkdir -p /go/src/project/user-app
ln -s /project/user-app /go/src/project/user-app 
cd /go/src/project/user-app/user-app
dep ensure
cd /project/user-app/vendor
cp -r * /go/src 2>>/dev/null