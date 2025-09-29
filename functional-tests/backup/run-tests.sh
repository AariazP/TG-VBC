#!/bin/bash

echo "======= Booting vms ======="
cluster-bootup -m 1 -w 2

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

ssh-vm -r master1 -c "kubectl exec writer-pod -- sh -c 'echo functional test for backup > /data/dummy_file.txt'"
echo "====== backing up for pvc ======="
backup nginx-pvc


echo "====== backing up for pod ======="

ssh-vm -r master1 -c "kubectl exec writer-pod -- sh -c 'echo functional test for backup in a pod > /data/dummy_file_pod.txt'"
backup -p writer-pod:/data
