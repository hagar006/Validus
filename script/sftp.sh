#!/bin/bash

DEVICE=$1
ZIP=Validus-*.zip
DELTA=Validus-*.delta
SIGN=Validus-*.sign
UPDATE=Validus-*.update
	
	echo -e "Starting transfert"
	cd /data/opendelta/publish/$DEVICE
	
	sftp -oPort=5212 -oIdentityFile=/data/jenkins/.ssh/id_dsa gothdroid@gothdroid.com <<EOF
	cd /data/opendelta/publish/$DEVICE
	put *
	bye
	EOF