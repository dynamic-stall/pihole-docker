#!/bin/bash

######################################
# Docker Install - Raspberry Pi OS
######################################

# Reference: https://docs.docker.com/engine/install/raspberry-pi-os/


###### TL;DR ######

# If needed, use this script to install Docker on your Raspberry Pi OS.
# This will delete any previous installs you may or may not have on your system.

### Script finishes with a "Hello World" test run. If this is unsuccessful, you can try re-running this script.
### If the test run still fails, maybe I f***ed up; try running some other Docker command on your own.
### Still failing? Look at your firewall or IP-tables configs. Therein (likely) lies your problem...

##### Still STILL failing? Hm... try a custom Docker network and define it as an external network in the compose.yml file. Check the "custom-network.sh" file for more details...
##### (ref: https://docs.docker.com/engine/reference/commandline/network_create/)
##### (ref: https://docs.docker.com/compose/networking/)

###################


# Fresh start:
docker container rm -f pihole cloudflared > /dev/null 2>&1

for i in docker docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $i > /dev/null 2>&1; done

sudo apt update && sudo apt upgrade -y
 
# Add Docker's official GPG key:
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker's APT repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/raspbian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install the latest Docker packages:
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start/enable Docker service:
sudo systemctl enable docker

# Verify Docker status and version
if [[ $(systemctl status docker | grep "active (running)") == "" ]]
then
        sudo systemctl start docker > /dev/null 2>&1
        systemctl status docker
else
        systemctl status docker
fi

sudo docker --version

# Configure Docker to run without sudo:
sudo usermod -aG docker $USER

# Test run:
docker run --rm hello-world