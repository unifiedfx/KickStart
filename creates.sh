#!/bin/bash
mountPath="/mnt/almalinux/"
tempPath="/tmp/almalinux-custom/"

while getopts s:d: flag
do
    case "${flag}" in
        s) source=${OPTARG}
           sourcePath="$(dirname "$source")"
           sourceFile="$(basename "$source")"
           sourceLabel="${sourceFile%.*}";;
        d) destination=${OPTARG}
           destinationPath="$(dirname "$destination")"
           destinationFile="$(basename "$destination")"
           destinationLabel="${destinationFile%.*}";;
    esac
done
sourceLabel="AlmaLinux-9-3-aarch64-dvd"

echo "SourcePath: $sourcePath";
echo "SourceFile: $sourceFile";
echo "DestinationPath: $destinationPath";
echo "DestinationFile: $destinationFile";
# echo "DestinationLabel: ${destinationFile%.*}";
echo "DestinationLabel: $destinationLabel";

# Download ISO if not already in the destination, prompt first?
rm -r $mountPath
mkdir $mountPath
rm -r $tempPath
mkdir $tempPath

mount -o loop $source $mountPath
rsync -av $mountPath $tempPath > /dev/null
umount $mountPath

menuitem="menuentry 'Install AlmaLinux 9.3 Github' --class red --class gnu-linux --class gnu --class os {\n	linux /images/pxeboot/vmlinuz inst.ks=https://raw.githubusercontent.com/unifiedfx/KickStart/main/ks.cfg inst.stage2=hd:LABEL=$destinationLabel ro\n	initrd /images/pxeboot/initrd.img\n}"
sed -i "s/$sourceLabel/$destinationLabel/g" $tempPath"EFI/BOOT/grub.cfg"
sed -i "28 a $menuitem" $tempPath"EFI/BOOT/grub.cfg"

# Note: Had to read the source code to figure out the correct arguments, check method aarch64LiveImageCreator here: https://github.com/livecd-tools/livecd-tools/blob/main/imgcreate/live.py

mkisofs -o $destination -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -hide-rr-moved -rational-rock -joliet -volid "$destinationLabel" $tempPath

implantisomd5 $destination

# cp $destination /mnt/hgfs/Projects/AlmaLinuxISO1

# sudo dnf -y install yum-utils
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin

