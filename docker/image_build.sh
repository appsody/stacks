#!/bin/bash

docker build -t kabanero/ubi8-openjdk -t kabanero/ubi8-openjdk:0.9.0 -f ./Dockerfile-ubi8-openJDK .

docker build -t kabanero/ubi8-maven -t kabanero/ubi8-maven:0.9.0 -f ./Dockerfile-maven .
