#!/bin/bash

if [ $# -lt 1 ]
then
   echo "usage: bootvm <vm-name>"
   exit 0
fi

VM_UUID=$(xe vm-install template=73c3dcba-5a6b-58af-b833-7ea36c9dfce5 new-name-label="$1")


mkdir -p /tmp/hostname-iso
echo "$1" > /tmp/hostname-iso/hostname.txt
ISO_NAME="hostname-$1.iso"
genisoimage -o $ISO_NAME -V cidata /tmp/hostname-iso

mv $ISO_NAME /var/opt/xen/iso_import/

xe sr-scan uuid=0bc185a2-bcf3-77d1-e942-1957c6be626f

xe vm-cd-add vm="$1" cd-name=$ISO_NAME device=2

xe vm-start uuid=$VM_UUID
