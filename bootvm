#!/bin/bash

if [ $# -lt 1 ]
then
   echo "usage: bootvm <vm-name>"
   exit 0
fi

# instala una vm a partir de una plantilla
VM_UUID=$(xe vm-install template=0c838875-cb93-dfe3-8c36-a2f42183b434 new-name-label="$1")

xe vm-start uuid=$VM_UUID
