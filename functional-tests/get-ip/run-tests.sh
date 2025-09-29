#!/bin/bash

cluster-bootup -w 1 -m 2 -b

sleep 2

SUCCESS_TEST_COUNT=0

get-ip master1 | grep 192 && echo "Test for master succedeed" && SUCCESS_TEST_COUNT=$(( $SUCCESS_TEST_COUNT + 1 ))
get-ip worker1 | grep 192 && echo "Test for worker succedeed" && SUCCESS_TEST_COUNT=$(( $SUCCESS_TEST_COUNT + 1 ))
get-ip load-balancer | grep 192 && echo "Test for load-balancer succedeed" && SUCCESS_TEST_COUNT=$(( $SUCCESS_TEST_COUNT + 1 ))
get-ip NAT-Master | grep 172 && echo "Test for NAT-Master succedeed" && SUCCESS_TEST_COUNT=$(( $SUCCESS_TEST_COUNT + 1 ))
get-ip NAT-Backup | grep 172 && echo "Test for NAT-Backup succedeed" && SUCCESS_TEST_COUNT=$(( $SUCCESS_TEST_COUNT + 1 ))

echo "$SUCCESS_TEST_COUNT/5 tests succedeed"
