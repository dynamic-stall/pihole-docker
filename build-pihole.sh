#!/bin/bash

set -e

export BLUE="\033[34m"
export GREEN="\033[32m"
export GREY="\033[38;5;235m"
export GREEN_BOLD="\033[1;32m"
export YELLOW_BOLD="\033[1;33m"
export RED_BOLD="\033[1;31m"
export CYAN_BOLD="\033[1;36m"
export NC="\033[0m"

ENV=".env"

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
    sleep 0.5s
}

prompt() {
    echo -e "${CYAN_BOLD}$1${NC}"
    sleep 0.5s
}

success() {
    echo -e "${GREEN_BOLD}[SUCCESS] $1${NC}"
    sleep 1s
}

error() {
    echo -e "${RED_BOLD}[ERROR] $1${NC}"
    return 1
}

warning() {
    echo -e "${YELLOW_BOLD}[WARNING]${NC} $1"
    sleep 1.5s
}

check_prerequisites() {
    log "Checking prerequisites..."
	
    # Check for .env file
    if [ ! -f $ENV ]; then
        error "$ENV file not found. Please create one from $ENV.example"
    fi

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi

    # Check if docker group exists
    if ! getent group docker > /dev/null; then
        log "Creating docker group..."
        sudo groupadd docker
    else
        log "Docker group already exists."
    fi

    # Check if $USER is in docker group
    if groups "$USER" | grep -q "\bdocker\b"; then
        log "$USER is already in the docker group."
    else
        log "Adding $USER to the docker group..."
        sudo usermod -aG docker "$USER"
	newgrp docker
    fi

    # Check if /usr/bin/docker has correct group ownership
    current_group=$(stat -c '%G' /usr/bin/docker)
    if [ "$current_group" != "docker" ]; then
        log "Changing group ownership of /usr/bin/docker to docker..."
        sudo chown root:docker /usr/bin/docker
    else
        log "Group ownership of /usr/bin/docker is already set to docker."
    fi

    # Check if permissions on /usr/bin/docker are correct
    current_permissions=$(stat -c '%A' /usr/bin/docker)
    if [ "$current_permissions" != "rwxr-x---" ]; then
        log "Setting correct permissions for /usr/bin/docker..."
        sudo chmod 750 /usr/bin/docker
    else
        log "Permissions on /usr/bin/docker are already correct."
    fi
}

set_volume_directory() {
    source "$ENV"

    # Set permissions for volume directories
    for volume in "$PIHOLE_VOLUME_DIR" "$PIHOLE_VOLUME_DIR/dnsmasq.d"; do
        if [ ! -d "$volume" ]; then
            sudo mkdir -p "$volume"
            log Volume directory created: "${GREEN}$volume${NC}"
        else
            log Volume directory already exists: "${GREY}$volume${NC}"
        fi

        sudo chown -R root:docker "$volume"
        sudo chmod -R 770 "$volume"
        log "Permissions set for $volume"
    done
}

configure_pihole() {
    source "$ENV"

    log "Composing Docker containers..."
    docker compose up -d || error "Failed to start containers"
    prompt "Almost done! Please set your password for the Pi-hole web interface."
    docker exec -it $PIHOLE_NAME pihole setpassword || warning "Failed to set password. Please run the command manually."
}

main() {
    log "Starting Pi-hole DNS over HTTPS setup..."
    check_prerequisites
    set_volume_directory
    configure_pihole
    success "Pi-hole DNS over HTTPS setup completed successfully!"
    prompt "Please check the README for post-installation steps and networking considerations."
}

main "$@"
