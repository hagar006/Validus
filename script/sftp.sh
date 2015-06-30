#!/bin/bash

DEVICE='$1'
ZIP='Validus-*.zip'
DELTA='Validus-*.delta'
SIGN='Validus-*.sign'
UPDATE='Validus-*.update'
	
	echo -e "Starting transfert"
	
	/usr/bin/sftp -oPORT=5212 -oIdentityFile=/data/jenkins/.ssh/id_dsa gothdroid@gothdroid.com <<EOF	
	lcd /data/opendelta/last/$DEVICE
	cd /data/opendelta/last/$DEVICE
	rm -rf $ZIP
	put $ZIP
	lcd /data/opendelta/publish/$DEVICE
	cd /data/opendelta/publish/$DEVICE
	put $DELTA
	put $SIGN
	put $UPDATE
	
	bye
	bye
	EOF
	

	