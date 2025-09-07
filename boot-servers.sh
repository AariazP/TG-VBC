#!/bin/bash

# instala master y backup a traves de una plantilla
MASTER_UUID=$(xe vm-install template="nat-server" new-name-label="NAT-Master")
BACKUP_UUID=$(xe vm-install template="nat-server" new-name-label="NAT-Backup")

xe vm-start uuid=$MASTER_UUID
sleep 2
xe vm-start uuid=$BACKUP_UUID
