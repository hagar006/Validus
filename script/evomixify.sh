cd $OUT
rm -rf $OUT/kernel_zip
mkdir -p $OUT/kernel_zip/META-INF/com/google/android
echo "Copying boot.img..."
cp $OUT/boot.img $OUT/kernel_zip/
echo "Fetching update-binary..."
cd $OUT/kernel_zip/META-INF/com/google/android
wget https://raw.githubusercontent.com/EvoMix/updater_script/master/com/google/android/update-binary
echo "Fetching updater-script..."
wget https://raw.githubusercontent.com/EvoMix/updater_script/master/com/google/android/updater-script
cd $OUT/kernel_zip
zip -qr ../evomix-$(date +%Y%m%d)-DEVICE.zip ./
croot
