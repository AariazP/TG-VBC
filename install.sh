#!/bin/bash

set -e

cat ./config/bashrc-config >> ~/.bashrc
source ~/.bashrc
source ./config/config.sh

cp ./ssh-keys/id_* ~/.ssh
cat ./ssh-keys/config >> ~/.ssh/config

sudo cp  ./man_pages_VBC/* /usr/share/man/man1

echo ============= Instalacion completada ===================
