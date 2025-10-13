#!/bin/bash

echo "======= Booting vms ======="
#cluster-bootup -m 1 -w 2

echo "====== Uploadindg .yaml files ========"
upload_yaml master1 deployment.yaml
upload_yaml master1 pvc.yaml
upload_yaml master1 pv.yaml
upload_yaml master1 service.yaml
upload_yaml master1 writer-pod.yaml

echo "======= modyfing files ========"

while ! ssh-vm -r master1 -c "kubectl get pod/writer-pod" | grep  -q Running 
do
   sleep 1
done

echo "====== backing up for pvc ======="
ssh-vm -r master1 -c "kubectl exec writer-pod -- sh -c 'echo functional test for backup in a pvc $( date ) &> /data/dummy_file_pvc.txt'"
backup nginx-pvc


echo "====== backing up for pod ======="
ssh-vm -r master1 -c "kubectl exec writer-pod -- sh -c 'echo functional test for backup in a pod $( date ) &> /data/dummy_file_pod.txt'"
backup -p writer-pod:/data


echo "====== backing up for node ======="
ssh-vm -r master1 -c "mkdir ./dummy_dir; echo 'functional test for backup in a node folder $date' >2 ./dummy_dir/dummy_file_node.txt"
backup -f master1:./dummy_dir
