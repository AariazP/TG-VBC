#!/bin/bash

BACKUP=0

while getopts "b" opt; do
  case $opt in
    b) BACKUP=1 ;;
    *) echo "Usage: $0 [-w NUM_WORKERS] [-m NUM_MASTERS] [-b NAT server backup?]" >&2
       exit 1 ;;
  esac
done

# instala master y backup a traves de una plantilla
MASTER_UUID=$(xe vm-install template="nat-server" new-name-label="NAT-Master")
[[ $BACKUP > 0 ]] && BACKUP_UUID=$(xe vm-install \
		 template="nat-server" new-name-label="NAT-Backup")

xe vm-start uuid=$MASTER_UUID
sleep 2
[[ $BACKUP > 0 ]] && xe vm-start uuid=$BACKUP_UUID
