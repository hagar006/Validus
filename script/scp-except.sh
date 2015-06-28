#!/usr/bin/expect -f

DEVICE=$1

# effectue le transfert par SCP (sur SSH)

set timeout 3600

spawn scp /data/opendelta/publish/$DEVICE/* gothdroid@gothdroid.com:/data/opendelta/publish/$DEVICE/
expect "password:"
send -- "AmyLee$33450\r"
expect "100%"
exit 0
