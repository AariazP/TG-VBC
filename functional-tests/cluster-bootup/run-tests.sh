#!/bin/bash


SUCCEDEED_TESTS=0

check(){
     echo +++++++++++++++++strings+++++++++++++++++++++++++
     echo $2
     echo $3
     if [[ "$2" == "$3" ]]
     then
        echo "Test for $1 succedeed"
	SUCCEDEED_TESTS=$(( $SUCCEDEED_TESTS + 1 ))
	return 0
     fi

     echo "Test for $1 failed"
     return 1
}

export EXPECTED_RESULT=" master1 NAT-Master worker1"
cluster-bootup -m 1 -w 1
export RESULT=$( get-vm | sort | tr -d '\n')

check  "1 master 1 worker" "$EXPECTED_RESULT" "$RESULT"

clean-cluster -y

export EXPECTED_RESULT=" load-balancer1 master1 master2 NAT-Master worker1"
cluster-bootup -m 2 -w 1
export RESULT=$( get-vm | sort | tr -d '\n')

check  "2 master 1 worker" "$EXPECTED_RESULT" "$RESULT"

clean-cluster -y

export EXPECTED_RESULT=" load-balancer1 master1 master2 NAT-Backup NAT-Master worker1"
cluster-bootup -m 2 -w 1 -b
export RESULT=$( get-vm | sort | tr -d '\n')

check  "2 master 1 worker 1 NAT Backup" "$EXPECTED_RESULT" "$RESULT"

clean-cluster -y

echo "${SUCCEDEED_TESTS}/3 tests succeeded"
