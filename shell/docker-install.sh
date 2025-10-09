#!/bin/bash

# Define the installation/upgrade function
install_docker_and_components() {
    # Install Docker & Docker Compose Plugin on Ubuntu 24.04 (This is your original script logic)
    echo "Uninstalling Old Docker Versions..."
    # Note: Using -y to automatically confirm removal
    sudo apt remove docker docker-engine docker.io containerd runc -y

    echo "Updating system..."
    sudo apt update

    echo "Upgrading your system, it may take long time..."
    echo "Starting in 5 sec..."
    sleep 4
    sudo apt upgrade -y

    echo "=============== Starting Docker Installation ==============="
    sleep 2
    echo "Installing ca-certificates ..."
    sudo apt install ca-certificates curl gnupg -y

    echo "Adding Docker’s Official GPG Key ..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo "Adding Docker Repository... "
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Installing Docker Engine + CLI + Compose Plugin"
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    echo "Verify Installation..."
    docker --version
    docker compose version   # (NOTE: It's "docker compose", not "docker-compose")

    echo "Adding user in docker group... to avoid sudo."
    sudo usermod -aG docker "$USER"

    echo "Reloading docker group to reflect the changes... Rebooting your system is recommended"
    newgrp docker

    echo "Done, Happy Development :) "

    echo -e "\n\e[31mRebooting your system is recommended to reflect the changes.\e[0m"
}

# --- Main Script Execution ---

# Check if Docker is installed and get the version
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')

    echo "✅ Docker is present with version: \e[33m$DOCKER_VERSION\e[0m"
    echo -n "Do you want to install a newer version (which includes removing the current one)? (y/N): "

    # Read user input
    read -r response

    # Convert response to lowercase and check if it's 'y'
    if [[ "$response" =~ ^[yY]$ ]]; then
        echo "➡️ Starting the installation and upgrade process..."
        install_docker_and_components
    else
        echo "❌ Keeping the current Docker version \e[33m$DOCKER_VERSION\e[0m. Exiting script."
    fi
else
    # Docker is not installed
    echo "❌ Docker is not found on this system."
    echo -n "Do you want to install Docker and its components? (Y/n): "

    # Read user input
    read -r response

    # Check if the user agrees or just presses Enter (default is Yes)
    if [[ "$response" =~ ^[yY]$ || -z "$response" ]]; then
        echo "➡️ Starting the installation process..."
        install_docker_and_components
    else
        echo "🛑 Installation canceled. Exiting script."
    fi
fi