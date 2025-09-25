#!/bin/bash

IP=$( get-ip.sh "$1" )
FILENAME=$( basename "$2" )

scp -i ~/.ssh/id_internal_vm "$2" root@$IP:./

ssh -i ~/.ssh/id_internal_vm root@$IP "kubectl apply -f  $FILENAME"
