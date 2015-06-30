#!/bin/bash

DEVICE=$1
ZIP=Validus-*.zip
DELTA=Validus-*.delta
SIGN=Validus-*.sign
UPDATE=Validus-*.update
	
	echo -e "Starting transfert"
	cd /data/opendelta/publish/$DEVICE
	
	lftp<<END_SCRIPT
	open sftp://gothdroid@gothdroid.com
	cd /data/opendelta/publish/$DEVICE
	mput *
	bye
	`END_SCRIPT'
	
	
	