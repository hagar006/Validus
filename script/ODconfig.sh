echo "========================================"
echo "OpenDelta Configurator for Validus"
echo "========================================"

DAY=$(date +%Y%m%d)

if [ "$VERSION" == "" ]; then
    if [ "$1" != "" ]; then
       VERSION=$1
    fi
fi
		
if [ "$DEVICE" == "" ]; then
	if [ "$2"!= "" ]; then
		DEVICE=$2
	fi
fi


if [ "$VERSION" == "" ]; then
    echo "Abort: no version number, use future version instead this build version ( 1.0.2 | 8 |...)" >&2
    exit 1
fi

if [ "$DEVICE" == "" ]; then 
	echo "Abort : no device specified" >&2
	exit 1
fi

sed -i 's/^\(.*ro.delta.version=\).*/\1'"$DEVICE-Build-$VERSION-$DAY"'/' vendor/validus/config/common.mk
echo "Version number verification:"
sed -n '/ro.delta.version=/p' vendor/validus/config/common.mk