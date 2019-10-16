#!/bin/bash

docker build -t kabanero/ubi8-openjdk -f ./Dockerfile-ubi8-openJDK .

docker build -t kabanero/ubi8-maven -f ./Dockerfile-maven .
