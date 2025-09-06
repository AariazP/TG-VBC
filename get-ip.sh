#!/bin/bash

if [ $# -lt 1 ]
then
   echo "usage: get-ip.sh <vm-name>"
   exit 0
fi

if [[ "$1" == "NAT-Master" ]]
then
   echo "172.30.29.2"
   exit 0
fi

VM_UUID=$( xe vm-list name-label="$1" --minimal )
VM_MAC=$( xe vif-list vm-uuid="$VM_UUID" params=MAC --minimal )
MACS=( $( echo $VM_MAC | cut -d, -f1 ) $( echo $VM_MAC | cut -d, -f2 ) )
VM_IP=$( ssh -i ~/.ssh/id_nat_server debian@172.30.29.2 "ip n | fgrep -e ${MACS[0]} -e ${MACS[1]}" | cut -d" " -f1 )

echo -n $VM_IP
