#!/bin/bash

# Different export
export PATH=/data/bin:$PATH

# Remove all local_manifests in folder
file=*.xml
chemin=/data/jenkins/workspace/ValidusRom/.repo/local_manifests

if [ -f $chemin/$file ]; then
  echo -e "Deleting all files in local_manifests"
  rm -rf $chemin/$file
  
else
  echo -e "No files found ...."
fi

cd /data/jenkins/workspace/ValidusRom
git pull && repo sync -j4
