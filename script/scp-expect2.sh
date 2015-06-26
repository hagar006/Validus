#!/usr/bin/expect -f

$DEVICE=$1

# effectue le transfert par SCP (sur SSH)

set timeout 3600

#connect and delete old build
spawn ssh -p 5212 gothdroid@gothdroid.com
expect "password:"
send -- "AmyLee$33450\r"
expect "100%"

cd /data/opendelta/last/$DEVICE
rm -rf *

#connect and copy new build to keep folder up to date
spawn scp /data/opendelta/last/$DEVICE/*.zip gothdroid@gothdroid.com:/data/opendelta/last/$DEVICE/
expect "password:"
send -- "AmyLee$33450\r"
expect "100%"

exit 0
