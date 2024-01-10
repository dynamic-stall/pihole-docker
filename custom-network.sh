#!/bin/bash
# Variables:
NETWORK_NAME=law-net
SUBNET=172.31.10.0/24
GATEWAY=172.31.10.1

docker network create \
--driver=bridge \
--attachable \
--subnet=$SUBNET \
--gateway=$GATEWAY \
$NETWORK_NAME
