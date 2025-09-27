#!/bin/bash

NUM_WORKERS=2
NUM_MASTERS=1
BACKUP=0
HAS_LB=0

while getopts "w:m:b" opt; do
  case $opt in
    w) NUM_WORKERS=$OPTARG ;;
    m) NUM_MASTERS=$OPTARG ;;
    b) BACKUP=1;;
    *) echo "Usage: $0 [-w NUM_WORKERS] [-m NUM_MASTERS] [-b NAT server backup?]" >&2
       exit 1 ;;
  esac
done

[[ $NUM_MASTERS > 1 ]] && HAS_LB=1 
[[ $BACKUP > 0 ]] && bash boot-servers.sh -b || bash boot-servers.sh 

sleep 3

NAMES=( master worker  )
VALUES=( $NUM_MASTERS $NUM_WORKERS )

if [[ $HAS_LB > 0 ]]
then
	NAMES=( load-balancer master worker  )
	VALUES=( 1 $NUM_MASTERS $NUM_WORKERS )
fi

for idx in $( seq 0 ${#NAMES[@]} | head -n -1 )
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
[ $HAS_LB -gt 0 ] && LB_IP=$( bash get-ip.sh load-balancer1 )

if [ $HAS_LB -gt 0 ]
then
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$MASTER_IP \
     "curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san ${LB_IP}"
else

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ~/.ssh/id_internal_vm root@$MASTER_IP \
     "curl -sfL https://get.k3s.io | sh -"

fi

while [ -z $TOKEN ]
do

TOKEN=$( ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
         -i ~/.ssh/id_internal_vm root@$MASTER_IP \
         "sudo cat /var/lib/rancher/k3s/server/node-token" )

done


if [[ $HAS_LB > 0 ]]
then

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

fi

NAMES=( master worker  )
VALUES=( $NUM_MASTERS $NUM_WORKERS )
MODES=( "-s - server" "-" )

JOIN_IP=${LB_IP}

[ $HAS_LB -eq 0 ] && JOIN_IP=$MASTER_IP

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
		 "curl -sfL https://get.k3s.io | K3S_URL=https://${JOIN_IP}:6443 K3S_TOKEN=${TOKEN} sh ${mode}"

	     VM_IP=""
	done
done
