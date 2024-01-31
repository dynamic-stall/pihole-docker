#!/bin/bash

## BLUF: This script will create a custom Docker network for your container(s). You can use the preset values, or choose your favorite IP scheme.

## MACVLAN SETUP (OPTIONAL):      (example script at the end)
## If you would like to use an existing IP address on your home network for management purposes, you can go with a macvlan network setup:
## To do so, change the DRIVER variable below (line 21) from "bridge" to "macvlan".
## Next, ensure the SUBNET and GATEWAY variables match those of your home network settings (check the LAN settings of your router, if you aren't sure).
## Finally, un-comment the IP_RANGE lines below (22 and 29) and enter in an IP range on line 20 (this step requires a bit of CIDR knowledge).
## (choose an IP range that isn't too restrictive and won't cause IP conflicts with other network devices. I recommend using a chunk from the latter half of your IP pool; i.e., x.x.x.128/26)

## You'll need to modify the docker-compose.yml file next:
## If going with MACVLAN, comment out or delete line 43, referencing the Web Admin UI port; you no longer need it.
## Next (or "First," if sticking with bridge network), change line 80, referencing the Pi-hole container IP, to any available IP on your bridge/home network (within the set IP range, if going with MACVLAN).
## Lastly, follow the remaining instructions at the end of the docker-compose.yml file for any remaining configs not described here.

# Variables:
NETWORK_NAME=law-net
SUBNET=172.31.20.0/24
GATEWAY=172.31.20.1
DRIVER=bridge
#IP_RANGE=x.x.x.x/xx

docker network create \
--driver=$DRIVER \
--attachable \
--subnet=$SUBNET \
--gateway=$GATEWAY \
#--ip-range=$IP_RANGE \
$NETWORK_NAME

################################

## MACVLAN Example Script:

#docker network create \
#--driver=macvlan \
#--attachable \
#--subnet=192.168.0.0/24 \
#--gateway=192.168.0.1 \
#--ip-range=192.168.0.128/26 \
#trafalgar-net
