#!/bin/bash


check_for_update() {
  return 0
}
#Main Program
# set Date and time for pom.xml file 
file=./.pom.status

if [ -f $file ] ; then
  #file exists check to see if the dates changed
  rc=check_for_update()
  if [ $rc gt 0 ]
    ./validate.sh
else
  # get timestamps for the pom.xml file
  eval $(stat -s .profile)
  echo $st_mtimespec > .pom.status
fi
  
