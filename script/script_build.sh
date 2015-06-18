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
export KBUILD_BUILD_HOST=Gothdroid.com


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
if [ "$#" -ne 1 ]; then
    howto
fi
device="$1"

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
    rm -rf prebuilts/chromium/"$device"
    echo -e "$BLEU Prebuilt Chromium for $device removed $NORMAL"
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
    lunch "validus_$device-userdebug"
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
        git pull && repo sync -j"$opt_jobs"
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
rm -f "$OUTDIR"/target/product/"$device"/system/build.prop

# This will create a new .version for kernel version is maintained on one
rm -f "$OUTDIR"/target/product/"$device"/obj/KERNEL_OBJ/.version

# Lunch device
echo ""
echo -e "$ROUGE Lunching device $NORMAL"
lunch "validus_$device-userdebug"

echo -e "$ROUGE Starting compilation: $BLEU Building Validus $device $NORMAL"
    echo ""
    make validus -j"$opt_jobs"
