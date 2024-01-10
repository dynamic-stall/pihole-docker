#!/bin/bash

docker network create \
--driver=bridge \
--attachable \
--subnet=172.31.10.0/24 \
--gateway=172.31.10.1 \
law-net
