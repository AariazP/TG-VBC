#!/bin/bash

upload_yaml master1 deployment.yaml
upload_yaml master1 pvc.yaml
upload_yaml master1 pv.yaml
upload_yaml master1 service.yaml
upload_yaml master1 writer-pod.yaml
