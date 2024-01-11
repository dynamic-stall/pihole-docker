#!/bin/bash

## Pi-hole container name
PH=pihole
## Cloudflared container name
CF=cloudflared

CHK=$(docker container ls | grep $PH\|$CF)

if [[ $CHK == "" ]]
then
	echo -e "setting WiFi DNS to Pi-hole..."
	sudo networksetup -setdnsservers Wi-Fi empty
	sudo networksetup -setdnsservers Wi-Fi 127.0.0.1
	sudo killall -HUP mDNSResponder
	sleep 1s
	echo -e "Starting Pi-hole DNS over HTTPS..."
	docker compose up -d
else
	echo -e "Stopping Pi-hole and Cloudflared containers..."
	docker stop -f $PH $CF
	sleep 5s
	echo -e "setting WiFi DNS to Pi-hole..."
        sudo networksetup -setdnsservers Wi-Fi empty
        sudo networksetup -setdnsservers Wi-Fi 127.0.0.1
        sudo killall -HUP mDNSResponder
	sleep 1s
	echo -e "Starting Pi-hole DNS over HTTPS..."
	docker compose up -d
fi

