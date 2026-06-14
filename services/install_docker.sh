#!/bin/bash
# This script installs Docker on Ubuntu. It is based on the official Docker installation instructions for Ubuntu, which can be found here: https://docs.docker.com/engine/install/ubuntu/
# Ask user to confirm before proceeding, as this script will make changes to the system and may require a restart. The user can choose to skip the installation if they do not want to proceed.

# Call messages.sh to define font colours for outputting errors (red), warnings(yellow), information (cyan) or confirmation (green)
source ./lib/messages.sh
define_font_colours

EXIT_CODE=0
read -p $'This script will make changes to the system to install \033[1;32mDocker\033[0m. Do you want to continue? (\033[1;32my\033[0m/\033[1;31mn\033[0m): ' -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ && -n $REPLY ]]; then
  echo "Docker installation skipped. You can run this script again later to install it."
  exit 0
fi

# Check if docker is already installed
if command -v docker &> /dev/null; then
  echo "Docker is already installed. Skipping installation."
  exit 0
fi

# Add Docker's official GPG key and set up the repository
sudo apt update
(( EXIT_CODE+=$? ))
sudo apt install ca-certificates curl
(( EXIT_CODE+=$? ))
sudo install -m 0755 -d /etc/apt/keyrings
(( EXIT_CODE+=$? ))
if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m preparing the system for Docker installation. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to continue\n'
  exit 1
fi

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
(( EXIT_CODE+=$? ))
sudo chmod a+r /etc/apt/keyrings/docker.asc
(( EXIT_CODE+=$? ))
if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m adding Docker's GPG key. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to continue\n'
  exit 1
fi

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
(( EXIT_CODE+=$? ))
if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m adding the Docker repository. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to continue\n'
  exit 1
fi

# Install Docker Engine
sudo apt update
(( EXIT_CODE+=$? ))
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
(( EXIT_CODE+=$? ))
if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m installing Docker. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to continue\n'
  exit 1
fi
sudo systemctl status docker

echo "If docker is not running, start it with 'sudo systemctl start docker'"
echo "To check if docker is working, run 'sudo docker run hello-world'"
echo "To avoid using 'sudo' with docker commands, you can add your user to the 'docker' group with 'sudo usermod -aG docker $USER'. You will need to log out and log back in for this change to take effect."

read -n 1 -s -r -p $'Press any key to continue\n'
exit 0