#!/bin/bash

export PATH=/data/bin:$PATH

cd /data/jenkins/workspace/ValidusRom
git pull && repo sync -j4
