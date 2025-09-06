#!/bin/bash

NUM_WORKERS=2

while getopts "w:" opt; do
  case $opt in
    w) NUM_WORKERS=$OPTARG ;;
    *) echo "Usage: $0 [-w NUM_WORKERS]" >&2
       exit 1 ;;
  esac
done


bash boot-servers.sh
sleep 2

bash bootvm.sh master

for i in $( seq 1 $NUM_WORKERS )
do
    bash bootvm.sh worker$i
done

sleep 2

for i in $( seq 1 $NUM_WORKERS )
do
     echo "=== setting up worker$i hostname ==="
     while [ -z $VM_IP ]
     do 
        VM_IP=$( bash get-ip.sh worker$i )
	sleep 1
     done

     ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
         -i ~/.ssh/id_internal_vm root@$VM_IP \
         "hostnamectl set-hostname worker$i; hostname; \
	  echo '127.0.0.1 worker$i' >> /etc/hosts"

     VM_IP=""
done

MASTER_IP=$( bash get-ip.sh master ) 
ssh -i ~/.ssh/id_internal_vm root@$MASTER_IP "hostnamectl set-hostname master; \
       hostname; echo '127.0.0.1 master' >> /etc/hosts"

ssh -i ~/.ssh/id_internal_vm root@$MASTER_IP "curl -sfL https://get.k3s.io | sh -"

TOKEN=$( ssh -i ~/.ssh/id_internal_vm root@$MASTER_IP "sudo cat /var/lib/rancher/k3s/server/node-token" )



for i in $( seq 1 $NUM_WORKERS )
do
     echo "=== setting up worker$i hostname ==="
     while [ -z $VM_IP ]
     do 
        VM_IP=$( bash get-ip.sh worker$i )
	sleep 1
     done

     ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
         -i ~/.ssh/id_internal_vm root@$VM_IP \
         "curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${TOKEN} sh -"

     VM_IP=""
done
