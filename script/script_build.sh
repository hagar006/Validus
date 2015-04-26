#!/bin/bash

export PATH=/data/bin:$PATH
export USE_CCACHE=1
export CCACHE_DIR=/data/ccache/jenkins/ValidusRom
export VALIDUS_BUILDTYPE=OFFICIAL
export KBUILD_BUILD_USER=Gothdroid
export KBUILD_BUILD_HOST=Gothdroid

cd /data/jenkins/workspace/ValidusRom

#prebuilts/misc/linux-x86/ccache/ccache -M 60G

make clean

. build/envsetup.sh
lunch validus_$device-userdebug
make validus -j8
