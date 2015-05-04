#!/bin/bash

# Different export
export PATH=/data/bin:$PATH

# Remove roomservice.xml in folder
file=roomservice.xml
chemin=/data/jenkins/workspace/ValidusRom/.repo/local_manifests

if [ -f $chemin/$file ]; then
  echo -e "Deleting roomservice.xml inside local_manifests"
  rm -rf $chemin/$file
  
else
  echo -e "No files found ...."
fi

# Return to the root folder
cd /data/jenkins/workspace/ValidusRom

# implementation of any amendments to the default.xml and initiating synchronization
git pull && repo sync -j4
