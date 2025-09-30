#!/bin/bash

sudo ip route add 192.168.100.0/24 via 172.30.29.2 dev xenbr0
#sudo ip route add 192.168.100.0/24 via 172.30.29.3 dev xenbr0
