#!/bin/bash

###################################################
# Docker Install - CentOS Stream 8-9 / RHEL 8-9
###################################################

# Reference: https://tecadmin.net/how-to-install-docker-on-centos-stream-9/


###### TL;DR ######

# If needed, use this script to install Docker on your RHEL(-esque) OS.
# This will delete any previous installs you may or may not have on your system.

### Script finishes with a "Hello World" test run. If this is unsuccessful, you can try re-running this script.
### If the test run still fails, maybe I f***ed up; try running some other Docker command on your own.
### Still failing? Look at your firewall or IP-tables configs. Therein (likely) lies your problem...

##### Still STILL failing? Hm... try a custom Docker network and define it as an external network in the compose.yml file. Check the "custom-network.sh" file for more details...
##### (ref: https://docs.docker.com/engine/reference/commandline/network_create/)
##### (ref: https://docs.docker.com/compose/networking/)

###################


# Fresh start:
sudo dnf erase -y docker > /dev/null 2>&1
sudo dnf update -y

# Install necessary dependencies for Docker:
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2

# Add Docker repository:
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Community Edition (CE) (--nobest installs highest version that satisfies package dependencies):
sudo dnf install -y docker-ce --nobest

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