#!/bin/bash

# Different export
export PATH=/data/bin:$PATH

# Remove all local_manifests in folder
$file = *.xml
$chemin = /data/jenkins/workspace/ValidusRom/.repo/local_manifests/

if [ -f $chemin/$file ]; then
  rm -rf $file
fi

cd /data/jenkins/workspace/ValidusRom
git pull && repo sync -j4
