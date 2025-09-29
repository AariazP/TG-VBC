#!/bin/bash

cluster-bootup -m 1 -w 1

upload_yaml master1 test-deployment.yaml

ssh-vm -r master1 -c "kubectl get pods" | grep -q nginx-deployment && echo "Test succedeed" || "Test failed"
