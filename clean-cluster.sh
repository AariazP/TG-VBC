#!/bin/bash

ASSUME_YES=false

while getopts "y" opt; do
  case $opt in
    y)
      ASSUME_YES=true
      ;;
    *)
      echo "Usage: $0 [-y]"
      exit 1
      ;;
  esac
done

if [ "$ASSUME_YES" = false ]; then
  read -p "Are you really sure you want to clean cluster. (y/N): " resp
  [[ ! $resp =~ (y|Y|yes|Yes|YES) ]] && exit 0
fi

vms=$(xe vm-list | grep name-label | grep -v "domain" | grep -oP "(?<=: ).+")

for vm in $vms; do
  UUID=$(xe vm-list name-label="$vm" --minimal | tr ',' ' ')
  xe vm-shutdown uuid=$UUID force=true &
  wait $!
  xe vm-destroy uuid=$UUID
done
