#!/bin/bash

rm ./web-password/* > /dev/null 2>&1

read -p "Set your Web Admin console password now: " PSWD
touch ./web-password/password.txt
echo $PSWD > ./web-password/password.txt

echo -e "Starting Pi-hole DNS over HTTPS..."
docker compose up -d

rm ./web-password/*
