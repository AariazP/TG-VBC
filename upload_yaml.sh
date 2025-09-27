#!/bin/bash

IP=$( get-ip.sh "$1" )
FILENAME=$( basename "$2" )

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm "$2" root@$IP:./

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$IP "kubectl apply -f  $FILENAME"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$IP "rm  $FILENAME"
