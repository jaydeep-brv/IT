#!/bin/bash
# Install Docker & Docker Compose Plugin on Ubuntu 24.04
echo "Uninstall Old Docker Versions (Optional but Recommended)..."
sudo apt remove docker docker-engine docker.io containerd runc

echo "Updating system..."
sudo apt update

echo "Upgrading your system, it may take long time..."
echo "starting in 5 sec..."
sleep 4
sudo apt upgrade -y

echo "=============== starting docker installation ==============="
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

echo "adding user in docker group... to avoid sudo."
sudo usermod -aG docker $USER

echo "Reloading docker group to reflect the changes... Rebooting your system is recommended"
newgrp docker

echo "Done, Happy Development :) "

echo "\e[31mRebooting your system is recommended to reflect the changes...\e[0m"