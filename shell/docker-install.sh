#!/bin/bash
# Install Docker & Docker Compose Plugin on Ubuntu 24.04
echo "Uninstall Old Docker Versions (Optional but Recommended)..."
sudo apt remove docker docker-engine docker.io containerd runc

echo "Updating system..."
sudo apt update
sudo apt upgrade -y

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

echo "adding user in docker group... to avoid sudo."
sudo usermod -aG docker $USER

echo "reloading docker group to reflect the changes..."
newgrp docker

echo "Script end Happy Development :) "

read -p "Rebooting your system is recommended, would you like to reboot? (Y/N): " choice

case "$choice" in
  [Yy]* )
    echo "Rebooting now..."
    sudo reboot
    ;;
  [Nn]* )
    echo "Reboot canceled. Please reboot manually later."
    ;;
  * )
    echo "Invalid input. Please enter Y or N."
    ;;
esac