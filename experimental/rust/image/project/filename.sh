#!/bin/bash
while read line
do 
    #if the line ends 
    if [[ "$line" == "name"* ]] 
    then
    export filename=$line
    fi
done < Cargo.toml

echo "$filename" | sed -e 's/name = "\(.*\)"/\1/'