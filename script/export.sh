#!/bin/bash

#export PATH

export PATH=/data/bin:$PATH

# Script

$EXP = cp $OUT/target/product/$device/Validus*.zip /data/temp_export

if [ "$EXP" == 1]; then
	rm -rf $OUT
fi


