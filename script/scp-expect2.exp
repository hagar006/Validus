#!/usr/bin/expect -f

DEVICE=$1
# Defini le temps avant d'envoyer le mot de passe
set timeout 3
 
spawn ssh -p 5212 gothdroid@gothdroid.com
interact

cd /data/opendelta/last/$DEVICE
rm -rf *
exit


spawn scp /data/opendelta/last/$DEVICE/*zip -p 5212 gothdroid@gothdroid.com:/data/opendelta/last/$DEVICE/
expect "100%"
exit 0
