#!/bin/bash

ROOT=0

while getopts "r" opt; do
  case "$opt" in
    r) ROOT=1 ;;
    *) echo "Usage: $0 [-r] <vm-name>" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
  echo "Usage: $0 [-r] <vm-name>" >&2
  exit 1
fi

IP=$(bash get-ip.sh "$1")

if [ "$ROOT" -eq 1 ]; then
  ssh -i ~/.ssh/id_internal_vm root@"$IP"
else
  ssh "$IP"
fi
