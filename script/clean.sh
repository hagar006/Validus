#!/bin/bash

export PATH=/data/bin:$PATH

cd /data/jenkins/workspace/ValidusRom

repo forall -vc "git reset --hard" && repo forall -vc "git clean -df"
