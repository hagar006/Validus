#!/bin/bash

# Définition du OUT

OUT='/data/jenkins/workspace/ValidusRom/out/target/product/$device'

# Ajout des permissions

chmod -R 775 $OUT

# On rentre dans le dossier OUT

cd $OUT

# Suppression du ZIP existant

rm -rf Evomix*.zip

# Création d'un dossier 

mkdir -p $OUT/kernel_zip

# Création du dossier pour les scripts 

mkdir -P $OUT/kernel_zip/META-INF/com/google/android

# Copie de boot.img

echo -e "Copying boot.img ..."
cp $OUT/boot.img $OUT/kernel_zip

# Ajout des binaires
echo "Fetching update-binary..."
cd $OUT/kernel_zip/META-INF/com/google/android
wget https://raw.githubusercontent.com/EvoMix/updater_script/master/com/google/android/update-binary
echo "Fetching updater-script..."
wget https://raw.githubusercontent.com/EvoMix/updater_script/master/com/google/android/updater-script

# Retour au dossier
cd $OUT/kernel_zip

# Zip de l'archive
zip -qr ../Evomix-$(date +%Y%m%d)-$device.zip ./
