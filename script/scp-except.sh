#!/usr/bin/expect -f

DEVICE=$1

# effectue le transfert par SCP (sur SSH)

set timeout 3600

spawn scp /data/opendelta/publish/$DEVICE/* -p 5212 gothdroid@gothdroid.com:/data/opendelta/publish/$DEVICE/
expect "100%"
exit 0
