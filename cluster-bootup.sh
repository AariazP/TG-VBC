#!/bin/bash

NUM_WORKERS=2
NUM_MASTERS=1

while getopts "w:m:" opt; do
  case $opt in
    w) NUM_WORKERS=$OPTARG ;;
    m) NUM_MASTERS=$OPTARG ;;
    *) echo "Usage: $0 [-w NUM_WORKERS] [-m NUM_MASTERS]" >&2
       exit 1 ;;
  esac
done

bash boot-servers.sh
sleep 3

NAMES=( load-balancer master worker  )
VALUES=( 1 $NUM_MASTERS $NUM_WORKERS )

for idx in {0..2}
do
        name=${NAMES[$idx]}
	value=${VALUES[$idx]} 

	for i in $( seq 1 $value )
	do
	    bash bootvm.sh $name$i
	done

	sleep 2

	for i in $( seq 1 $value )
	do
	     echo "=== setting up $name$i hostname ==="
	     while [ -z $VM_IP ]
	     do 
		VM_IP=$( bash get-ip.sh $name$i )
		sleep 1
	     done

	     ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
		 -i ~/.ssh/id_internal_vm root@$VM_IP \
		 "hostnamectl set-hostname $name$i; hostname; \
		  echo '127.0.0.1 $name$i' >> /etc/hosts"

	     VM_IP=""
	done
done

MASTER_IP=$( bash get-ip.sh master1 )
LB_IP=$( bash get-ip.sh load-balancer1 )

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$MASTER_IP \
     "curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san ${LB_IP}"

TOKEN=$( ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
         -i ~/.ssh/id_internal_vm root@$MASTER_IP \
         "sudo cat /var/lib/rancher/k3s/server/node-token" )



ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$LB_IP "apt install haproxy -y"


config="frontend k3s-api
    bind *:6443
    default_backend k3s-masters

backend k3s-masters
    balance roundrobin
"

for i in $( seq 1 $NUM_MASTERS ); do
    ip=$( bash get-ip.sh master$i )
    config+="    server master${i} ${ip}:6443 check 
"
done

echo "_____________________"
echo "$config"
echo "_____________________"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$LB_IP \
    "cat > /etc/haproxy/haproxy.cfg" <<< "$config"


ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$LB_IP "sudo systemctl restart haproxy"


NAMES=( master worker  )
VALUES=( $NUM_MASTERS $NUM_WORKERS )
MODES=( "-s - server" "-" )

for idx in {0..1}
do
        name=${NAMES[$idx]}
	value=${VALUES[$idx]}
	mode=${MODES[$idx]}

	for i in $( seq 1 $value )
	do
	     [[ ${name}${i} == "master1" ]] && continue

	     echo "=== joining host $name$i to cluster ==="
	     while [ -z $VM_IP ]
	     do 
		VM_IP=$( bash get-ip.sh $name$i )
		sleep 1
	     done

	     ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
		 -i ~/.ssh/id_internal_vm root@$VM_IP \
		 "curl -sfL https://get.k3s.io | K3S_URL=https://${LB_IP}:6443 K3S_TOKEN=${TOKEN} sh ${mode}"

	     VM_IP=""
	done
done
