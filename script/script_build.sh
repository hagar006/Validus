#!/bin/bash

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Define colors

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

JVM=`java -version`

# Define home and rom
home=/data/jenkins/workspace/ValidusRom
#rom=validus

# Differents necessary export
export PATH=/data/bin:$PATH
export USE_CCACHE=1
export CCACHE_DIR=/data/ccache/jenkins/ValidusRom
export VALIDUS_BUILDTYPE=OFFICIAL
export KBUILD_BUILD_USER=ValidusBuilder

# KBUILD_BUILD_HOST adjust depending on the build server used (master or slave)
HOST=`hostname`
if [ $HOST = "gothdroid.com" ]; then
    export KBUILD_BUILD_HOST=Build-01
else 
    export KBUILD_BUILD_HOST=Build-02
fi

echo -e " You are using $ROUGE $JVM $NORMAL"


# Return to home
cd $home

echo -e "$ROUGE" 
echo -e           "***********************************************************************"
echo -e           "*                        Build Script                                 *"
echo -e           "*                            By                                       *"                                           
echo -e           "*    ___      _   _         _           _     _                       *"
echo -e           "*   / _ \___ | |_| |__   __| |_ __ ___ (_) __| |  ___ ___  _ __ ___   *"
echo -e           "*  / /_\/ _ \| __|  _ \ / _  |  __/ _ \| |/ _  | / __/ _ \|  _   _ \  *"
echo -e           "* / /_\| (_) | |_| | | | (_| | | | (_) | | (_| || (_| (_) | | | | | | *"
echo -e           "* \____/\___/ \__|_| |_|\__ _|_|  \___/|_|\__ _(_)___\___/|_| |_| |_| *"
echo -e           "***********************************************************************"
echo -e "$NORMAL"                                                                   

howto() {
    echo -e "$ROUGE" "Usage:$NORMAL"
    echo -e "  script_build.sh [options] device"
    echo ""
    echo -e "$BLEU  Options:$NORMAL"
    echo -e "    -b# Prebuilt Chromium options:"
    echo -e "        1 - Remove"
    echo -e "        2 - No Prebuilt Chromium"
    echo -e "    -c# Cleaning options before build:"
    echo -e "        1 - Run make clean"
    echo -e "        2 - Run make installclean"
    echo -e "    -d# Use Ccache"
    echo -e "        1 - Use Ccache"
    echo -e "        2 - Don't use Ccache"
    echo -e "    -j# Set number of jobs"
    echo -e "    -o# Build Type"
    echo -e "        1 - OFFICIAL"
    echo -e "        2 - UNOFFICIAL"
    echo -e "    -s# Sync options before build:"
    echo -e "        1 - Normal sync"
    echo ""
    echo -e "$BLEU  Example:$NORMAL"
    echo -e "    source script/script_build.sh -c1 z3"
    echo -e ""
    exit 1
}


# Default global variable values with preference to environmant.
if [ -z "${USE_PREBUILT_CHROMIUM}" ]; then
    export USE_PREBUILT_CHROMIUM=1
fi
if [ -z "${USE_CCACHE}" ]; then
    export USE_CCACHE=1
fi

# Get OS (Linux / Mac OS X)
IS_DARWIN=$(uname -a | grep Darwin)
if [ -n "$IS_DARWIN" ]; then
    CPUS=$(sysctl hw.ncpu | awk '{print $2}')
else
    CPUS=$(grep "^processor" /proc/cpuinfo -c)
fi


opt_adb=0
opt_chromium=0
opt_clean=0
opt_ccache=0
opt_jobs="$CPUS"
opt_kr=0
opt_sync=0
opt_off=0

while getopts "b:c:d:j:k:o:s:" opt; do
    case "$opt" in
    b) opt_chromium="$OPTARG" ;;
    c) opt_clean="$OPTARG" ;;
    d) opt_ccache="$OPTARG" ;;
    j) opt_jobs="$OPTARG" ;;
    k) opt_kr=1 ;;
    o) opt_off="$OPTARG" ;;
    s) opt_sync="$OPTARG" ;;
    *) howto
    esac
done

shift $((OPTIND-1))
if [ "$#" -ne 2 ]; then
    howto
fi

DEVICE="$1"


# Build_Type option
if [ "$opt_off" -eq 2 ]; then
    echo -e "$ROUGE You are building an UNOFFICIAL Device for Validus $NORMAL"
    unset VALIDUS_BUILDTYPE
    echo ""
fi

# Ccache options
if [ "$opt_ccache" -eq 2 ]; then
    echo -e "$BLEU Ccache not be used in this build $NORMAL"
    unset USE_CCACHE
    echo ""
    else 
    prebuilts/misc/linux-x86/ccache/ccache -M 60G
fi


# Chromium options
if [ "$opt_chromium" -eq 1 ]; then
    rm -rf prebuilts/chromium/"$DEVICE"
    echo -e "$BLEU Prebuilt Chromium for $DEVICE removed $NORMAL"
    echo ""
elif [ "$opt_chromium" -eq 2 ]; then
    unset USE_PREBUILT_CHROMIUM
    echo -e "$BLEU Prebuilt Chromium will not be used $NORMAL"
    echo ""
fi

# Cleaning out directory
if [ "$opt_clean" -eq 1 ]; then
    echo -e "$ROUGE Cleaning output directory $NORMAL"
    make clean >/dev/null
    echo -e "$BLEU Output directory is: $ROUGE Clean $NORMAL"
    echo ""
elif [ "$opt_clean" -eq 2 ]; then
    . build/envsetup.sh
    lunch "validus_$DEVICE-userdebug"
    make installclean >/dev/null
    echo -e "$BLEU Output directory is: $ROUGE Dirty $NORMAL"
    echo ""
else
    if [ -d "$OUTDIR/target" ]; then
        echo -e "$BLEU Output directory is: $ROUGE Untouched $NORMAL"
        echo ""
    else
        echo -e "$BLEU Output directory is: $ROUGE Clean $NORMAL"
        echo ""
    fi
fi

# Repo sync
if [ "$opt_sync" -eq 1 ]; then
    # Sync with latest sources
    echo -e "$ROUGE Fetching latest sources $NORMAL"
    
    # Remove validus_manifest.xml in folder
        file=validus_*.xml
        cd $home/.repo/local_manifests/

            if [ -f $file ]; then
                echo -e "$ROUGE Deleting validus_manifest.xml inside local_manifests $NORMAL"
                rm -rf $file
                
            else
                echo -e "No files found ...."
            fi
cd $home
    # implementation of any amendments to the default.xml and initiating synchronization
        rm -rf .repo/repo
        repo init -u git://github.com/TV-LP51/android.git -b lp5.1
        git stash
        git pull && repo sync --force-sync -j"$opt_jobs" && repo sync -j"$opt_jobs"
        echo ""
else 
        echo -e "$BLEU No repo sync $NORMAL"
fi

# Setup environment
echo -e "$ROUGE Setting up environment $NORMAL"
echo -e "$BLEU ${line} $NORMAL"
. build/envsetup.sh
echo -e "$BLEU ${line} $NORMAL"

# This will create a new build.prop with updated build time and date
rm -f "$OUTDIR"/target/product/"$DEVICE"/system/build.prop

# This will create a new .version for kernel version is maintained on one
rm -f "$OUTDIR"/target/product/"$DEVICE"/obj/KERNEL_OBJ/.version

# Lunch device
echo ""
echo -e "$ROUGE Lunching device $NORMAL"
lunch "validus_$DEVICE-userdebug"

echo -e "$ROUGE Starting compilation: $BLEU Building Validus $device $NORMAL"
    echo ""
    make validus -j"$opt_jobs"
	
echo -e "$ROUGE" 
echo -e           "***********************************************************************"
echo -e           "*                        Rename of ZIP                                *"                         
echo -e           "***********************************************************************"
echo -e "$NORMAL"

VERSION="$2"
DAY="$(date +%Y%m%d)"
HOME=/data/jenkins/workspace/ValidusRom

cd $HOME/out/target/product/$DEVICE

mv Validus-*.zip Validus-$DEVICE-Build-$VERSION-$DAY.zip

# echo -e "$ROUGE" 
# echo -e           "***********************************************************************"
# echo -e           "*                     Applying OpenDelta Configuration                *"                         
# echo -e           "***********************************************************************"
# echo -e "$NORMAL"

# # Script to generate delta files for OpenDelta - by Jorrit 'Chainfire' Jongma
# # Modified by Gothdroid to adapt on Validus Rom for Team GZR

# # Get device either from $DEVICE set by calling script, or first parameter

# if [ "$DEVICE" == "" ]; then
	# if [ "$1" != "" ]; then
		# DEVICE=$1
	# fi
# fi

# if [ "$DEVICE" == "" ]; then
	# echo "Abort: no device set" >&2
	# exit 1
# fi

# # ------ CONFIGURATION ------

# HOME=/data/jenkins/workspace/ValidusRom
# HOME2=/data/opendelta

# BIN_JAVA=java
# BIN_MINSIGNAPK=$HOME2/lib/minsignapk.jar
# BIN_XDELTA=$HOME2/lib/xdelta3-3.0.7/xdelta3
# BIN_ZIPADJUST=$HOME2/lib/zipadjust

# FILE_MATCH=Validus-$DEVICE-*.zip
# PATH_CURRENT=$HOME/out/target/product/$DEVICE
# PATH_LAST=$HOME2/last/$DEVICE

# KEY_X509=$HOME/.keys/platform.x509.pem
# KEY_PK8=$HOME/.keys/platform.pk8

# # ------ PROCESS ------

# getFileName() {
	# echo ${1##*/}
# }

# getFileNameNoExt() {
	# echo ${1%.*}
# }

# getFileMD5() {
	# TEMP=$(md5sum -b $1)
	# for T in $TEMP; do echo $T; break; done
# }

# getFileSize() {
	# echo $(stat --print "%s" $1)
# }

# nextPowerOf2() {
    # local v=$1;
    # ((v -= 1));
    # ((v |= $v >> 1));
    # ((v |= $v >> 2));
    # ((v |= $v >> 4));
    # ((v |= $v >> 8));
    # ((v |= $v >> 16));
    # ((v += 1));
    # echo $v;
# }

# FILE_CURRENT=$(getFileName $(ls -1 $PATH_CURRENT/$FILE_MATCH))
# FILE_LAST=$(getFileName $(ls -1 $PATH_LAST/$FILE_MATCH))
# FILE_LAST_BASE=$(getFileNameNoExt $FILE_LAST)

# if [ "$FILE_CURRENT" == "" ]; then
	# echo "Abort: CURRENT zip not found" >&2
	# exit 1
# fi

# if [ "$FILE_LAST" == "" ]; then
	# echo "Abort: LAST zip not found" >&2
	# mkdir -p $PATH_LAST
	# cp $PATH_CURRENT/$FILE_CURRENT $PATH_LAST/$FILE_CURRENT
	# exit 0
# fi

# if [ "$FILE_LAST" == "$FILE_CURRENT" ]; then
	# echo "Abort: CURRENT and LAST zip have the same name" >&2
	# exit 1
# fi

# rm -rf $HOME2/work
# mkdir -p $HOME2/work
# rm -rf $HOME2/out
# mkdir -p $HOME2/out

# $BIN_ZIPADJUST --decompress $PATH_CURRENT/$FILE_CURRENT $HOME2/work/current.zip
# $BIN_ZIPADJUST --decompress $PATH_LAST/$FILE_LAST $HOME2/work/last.zip
# $BIN_JAVA -Xmx1024m -jar $BIN_MINSIGNAPK $KEY_X509 $KEY_PK8 $HOME2/work/current.zip $HOME2/work/current_signed.zip
# $BIN_JAVA -Xmx1024m -jar $BIN_MINSIGNAPK $KEY_X509 $KEY_PK8 $HOME2/work/last.zip $HOME2/work/last_signed.zip
# SRC_BUFF=$(nextPowerOf2 $(getFileSize $HOME2/work/current.zip));
# $BIN_XDELTA -B ${SRC_BUFF} -9evfS none -s $HOME2/work/last.zip $HOME2/work/current.zip $HOME2/out/$FILE_LAST_BASE.update
# SRC_BUFF=$(nextPowerOf2 $(getFileSize $HOME2/work/current_signed.zip));
# $BIN_XDELTA -B ${SRC_BUFF} -9evfS none -s $HOME2/work/current.zip $HOME2/work/current_signed.zip $HOME2/out/$FILE_LAST_BASE.sign

# MD5_CURRENT=$(getFileMD5 $PATH_CURRENT/$FILE_CURRENT)
# MD5_CURRENT_STORE=$(getFileMD5 $HOME2/work/current.zip)
# MD5_CURRENT_STORE_SIGNED=$(getFileMD5 $HOME2/work/current_signed.zip)
# MD5_LAST=$(getFileMD5 $PATH_LAST/$FILE_LAST)
# MD5_LAST_STORE=$(getFileMD5 $HOME2/work/last.zip)
# MD5_LAST_STORE_SIGNED=$(getFileMD5 $HOME2/work/last_signed.zip)
# MD5_UPDATE=$(getFileMD5 $HOME2/out/$FILE_LAST_BASE.update)
# MD5_SIGN=$(getFileMD5 $HOME2/out/$FILE_LAST_BASE.sign)

# SIZE_CURRENT=$(getFileSize $PATH_CURRENT/$FILE_CURRENT)
# SIZE_CURRENT_STORE=$(getFileSize $HOME2/work/current.zip)
# SIZE_CURRENT_STORE_SIGNED=$(getFileSize $HOME2/work/current_signed.zip)
# SIZE_LAST=$(getFileSize $PATH_LAST/$FILE_LAST)
# SIZE_LAST_STORE=$(getFileSize $HOME2/work/last.zip)
# SIZE_LAST_STORE_SIGNED=$(getFileSize $HOME2/work/last_signed.zip)
# SIZE_UPDATE=$(getFileSize $HOME2/out/$FILE_LAST_BASE.update)
# SIZE_SIGN=$(getFileSize $HOME2/out/$FILE_LAST_BASE.sign)

# DELTA=$HOME2/out/$FILE_LAST_BASE.delta

# echo "{" > $DELTA
# echo "  \"version\": 1," >> $DELTA
# echo "  \"in\": {" >> $DELTA
# echo "      \"name\": \"$FILE_LAST\"," >> $DELTA
# echo "      \"size_store\": $SIZE_LAST_STORE," >> $DELTA
# echo "      \"size_store_signed\": $SIZE_LAST_STORE_SIGNED," >> $DELTA
# echo "      \"size_official\": $SIZE_LAST," >> $DELTA
# echo "      \"md5_store\": \"$MD5_LAST_STORE\"," >> $DELTA
# echo "      \"md5_store_signed\": \"$MD5_LAST_STORE_SIGNED\"," >> $DELTA
# echo "      \"md5_official\": \"$MD5_LAST\"" >> $DELTA
# echo "  }," >> $DELTA
# echo "  \"update\": {" >> $DELTA
# echo "      \"name\": \"$FILE_LAST_BASE.update\"," >> $DELTA
# echo "      \"size\": $SIZE_UPDATE," >> $DELTA
# echo "      \"size_applied\": $SIZE_CURRENT_STORE," >> $DELTA
# echo "      \"md5\": \"$MD5_UPDATE\"," >> $DELTA
# echo "      \"md5_applied\": \"$MD5_CURRENT_STORE\"" >> $DELTA
# echo "  }," >> $DELTA
# echo "  \"signature\": {" >> $DELTA
# echo "      \"name\": \"$FILE_LAST_BASE.sign\"," >> $DELTA
# echo "      \"size\": $SIZE_SIGN," >> $DELTA
# echo "      \"size_applied\": $SIZE_CURRENT_STORE_SIGNED," >> $DELTA
# echo "      \"md5\": \"$MD5_SIGN\"," >> $DELTA
# echo "      \"md5_applied\": \"$MD5_CURRENT_STORE_SIGNED\"" >> $DELTA
# echo "  }," >> $DELTA
# echo "  \"out\": {" >> $DELTA
# echo "      \"name\": \"$FILE_CURRENT\"," >> $DELTA
# echo "      \"size_store\": $SIZE_CURRENT_STORE," >> $DELTA
# echo "      \"size_store_signed\": $SIZE_CURRENT_STORE_SIGNED," >> $DELTA
# echo "      \"size_official\": $SIZE_CURRENT," >> $DELTA
# echo "      \"md5_store\": \"$MD5_CURRENT_STORE\"," >> $DELTA
# echo "      \"md5_store_signed\": \"$MD5_CURRENT_STORE_SIGNED\"," >> $DELTA
# echo "      \"md5_official\": \"$MD5_CURRENT\"" >> $DELTA
# echo "  }" >> $DELTA
# echo "}" >> $DELTA

# mkdir $HOME2/publish >/dev/null 2>/dev/null
# mkdir $HOME2/publish/$DEVICE >/dev/null 2>/dev/null
# cp $HOME2/out/* $HOME2/publish/$DEVICE/.

# rm -rf $HOME2/work
# rm -rf $HOME2/out

# rm -rf $PATH_LAST/*
# mkdir -p $PATH_LAST
# cp $PATH_CURRENT/$FILE_CURRENT $PATH_LAST/$FILE_CURRENT

# echo -e "$ROUGE" 
# echo -e           "***********************************************************************"
# echo -e           "*            Synchronize folder in case of build in slave             *"                         
# echo -e           "***********************************************************************"
# echo -e "$NORMAL"

# if [ $HOST != "gothdroid.com" ]; then
	
	# cd $HOME/script
		# ./sftp.sh $DEVICE
# fi

echo -e "$ROUGE" 
echo -e           "***********************************************************************"
echo -e           "*                     Thanks to use my script ;)                      *"                         
echo -e           "***********************************************************************"
echo -e "$NORMAL"

exit 0             
