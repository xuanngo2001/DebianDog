#!/bin/sh
# Description: Create a custom live Debian operating system. It will create an ISO.
#               The main idea is to replace the SQUASHFS file with a custom one.
# Author: Xuan Ngo
# Usage:
#   Change the following parameters accordingly:
#     -EXTRACTED_ISO_DIR: Location you want the extract ISO to be located.
#     -ISO_FILE_PATH: Location of the original DebianDog ISO.
#     -NEW_SQUASHFS: Location of the new SQUASHFS file generated by RemasterDog application ran within Debian Dog.

### Check input arguments
FILESYSTEM_SQUASHFS_NEW=$1
KERNEL=$2

if [ ! -z ${FILESYSTEM_SQUASHFS_NEW} ]; 
then
  # Not empty

  if [ ! -f ${FILESYSTEM_SQUASHFS_NEW} ];
  then
    echo "ERROR: ${FILESYSTEM_SQUASHFS_NEW} is not a file. Please provide a valid '01-filesystem.squashfs' file."
    exit 1;
  fi
  
else
  # Is empty
  echo "ERROR: Please provide '01-filesystem.squashfs' file."
  exit 1;
fi

if [ -z ${KERNEL} ]; 
then
  # Is empty
  echo "ERROR: Please provide kernel version(e.g. 386, 686)."
  exit 1;
fi

if [ ${KERNEL} = "686" ] || [ ${KERNEL} = "386" ];
then
  echo ""
else
  echo "ERROR: Invalid kernel version. Kernel version available: 386, 686."
  exit 1;
fi


### Extract ISO.
EXTRACTED_ISO_DIR=/media/sf_shared/moddebdogdir
ISO_FILE_PATH=/media/sf_shared/DebianDog-Wheezy-openbox_xfce.iso
./extract-deb-iso.sh ${ISO_FILE_PATH} ${EXTRACTED_ISO_DIR}

### Add kernel, only 1 at a time.
INSTALL_00_00_SCRIPT=./post-boot/install-00-00.sh
if [ ${KERNEL} = "686" ];
then
  echo "Adding ${KERNEL}."
  #./add-new-kernel-3.14-686-Pae.sh ${EXTRACTED_ISO_DIR}/live ${EXTRACTED_ISO_DIR}/isolinux/live.cfg
  ./add-new-kernel-3.2.0-4-686-Pae.sh ${EXTRACTED_ISO_DIR}/live ${EXTRACTED_ISO_DIR}/isolinux/live.cfg
  sed -i 's/^.*sh install-00-kernel.*\.sh/sh install-00-kernel-686.sh/' ${INSTALL_00_00_SCRIPT}
else
  # 386
  sed -i 's/^.*sh install-00-kernel.*\.sh/#sh install-00-kernel.sh/' ${INSTALL_00_00_SCRIPT}
fi

exit 1;
  
### Add new 01-filesystem.squashfs
FILESYSTEM_SQUASHFS=${EXTRACTED_ISO_DIR}/live/01-filesystem.squashfs
rm -f ${FILESYSTEM_SQUASHFS}
cp ${FILESYSTEM_SQUASHFS_NEW} ${FILESYSTEM_SQUASHFS}
    
### Make ISO
DATE_STRING=`date +"%Y-%m-%d_%0k.%M.%S"`
OUTPUT_ISO_DIR=/media/sf_shared
OUTPUT_ISO=${OUTPUT_ISO_DIR}/cust-debdog-${DATE_STRING}.iso

# Make ISO
rm -f ${OUTPUT_ISO}
genisoimage  -r -V "cust-debdog" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ${OUTPUT_ISO} ${EXTRACTED_ISO_DIR}


# Display info
echo "***************** Done *****************"
echo "Created ${OUTPUT_ISO}."