#!/bin/bash

DEVICE=$1
	
	echo -e "Starting transfert"
	cd /data/opendelta/publish/$DEVICE
	
	sftp -oPort=5212 -oIdentityFile=/data/jenkins/.ssh/id_dsa gothdroid@gothdroid.com <<EOF
	cd /data/opendelta/publish/$DEVICE
	put *
	bye
	EOF