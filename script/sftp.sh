#!/bin/bash

cd $HOME2/last/$DEVICE
	
	echo -e "Starting transfert"
	
	/usr/bin/sftp -oPORT=5212 -oIdentityFile=/data/jenkins/.ssh/id_dsa gothdroid@gothdroid.com << EOF	
	lcd /data/opendelta/last/$DEVICE
	cd /data/opendelta/last/$DEVICE
	rm -rf *.zip
	put *.zip
	bye
	bye
	EOF

	