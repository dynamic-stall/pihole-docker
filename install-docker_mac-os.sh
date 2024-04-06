#!/bin/bash

######################################
# Docker Install - Mac OS
######################################

# IMPORTANT NOTE: I don't use Docker Desktop, but it is (apparently) the reccomended way to run and manage Docker services for Mac OS. Installing Docker Desktop  will install both Docker Engine and Docker Compose (both required).

# Reference the below link to do so:

### (DO NOT run this script if you are following the below link!) ###

# https://docs.docker.com/desktop/install/mac-install/


###### TL;DR ######

# If needed, use this script to install Docker on your Mac OS. See the "Requirements" section for which versions of Mac OS should support this install.

# This will delete any previous installs you may or may not have on your system.

# I recommend you install Homebrew package manager on your Mac OS for this and other packages; this script will check if you already have it installed and, if needed, install it for you.

### Script finishes with a "Hello World" test run. If this is unsuccessful, you can try re-running this script.
### If the test run still fails, maybe I f***ed up; try running some other Docker command on your own.
### Still failing? Look at your firewall or IP-tables configs. Therein (likely) lies your problem...

##### Still STILL failing? Hm... try a custom Docker network and define it as an external network in the compose.yml file. Check the "custom-network.sh" file for more details...
##### (ref: https://docs.docker.com/engine/reference/commandline/network_create/)
##### (ref: https://docs.docker.com/compose/networking/)

###################


## Check for Homebrew and Install, if Needed:
check_install_homebrew() {
    # Function to install Homebrew
    install_homebrew() {
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed."
        
        # Attempt first installation
        if ! install_homebrew; then
            echo "Failed to install Homebrew. Retrying..."
            # Attempt second installation
            if ! install_homebrew; then
                echo "Failed to install Homebrew after retry. Please install it manually."
                exit 1
            fi
        fi

        # Check if installation was successful
        if ! command -v brew &> /dev/null; then
            echo "Failed to install Homebrew. Please install it manually."
            exit 1
        else
            echo "Homebrew has been successfully installed."
        fi
    else
        echo "Homebrew is already installed."
    fi
}

# Call the function to check and install Homebrew, if needed:
check_install_homebrew

# Fresh start:
brew uninstall docker docker-compose &> /dev/null

# Install Docker Engine and Docker Compose:
brew install docker && brew install docker-compose

# Enable/start Docker and verify install:
brew services enable docker && brew services start docker
docker --version || sudo docker --version

## cron job for periodically updating Homebrew packages:

# Define the cron schedule (every Sunday at 3:45 am)
cron_schedule="45 3 * * 0"

# Define the command to update and upgrade Homebrew packages with the -y option
brew_update_command="brew update && brew upgrade -y"

# Add the cron job
(crontab -l ; echo "$cron_schedule $brew_update_command") | crontab -

# Test run:
docker run --rm hello-world
