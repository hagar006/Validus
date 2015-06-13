#!/bin/bash

HOME=/data/jenkins/workspace/ValidusRom
DEVICE=$1
VERSION=$2
DAY=$(date +%Y%m%d)

cd $HOME/out/target/product/$DEVICE

mv Validus-*.zip Validus-Build-$VERSION-$DAY.zip