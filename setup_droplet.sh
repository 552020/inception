#!/bin/bash

# Check if the OS is Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "This script is intended for Ubuntu. Exiting."
        exit 1
    fi
else
    echo "Cannot determine the OS. Exiting."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null
then
    echo "Git could not be found, installing..."
    sudo apt-get update
    sudo apt-get install -y git
else
    echo "Git is already installed."
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found, installing..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi

# Check if Docker Compose (integrated with Docker) is available
if ! docker compose version &> /dev/null
then
    echo "Docker Compose (part of Docker CLI) is not available, installing Docker."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
else
    echo "Docker Compose (part of Docker CLI) is available."
fi

# Check if Make is installed
if ! command -v make &> /dev/null
then
    echo "Make could not be found, installing..."
    sudo apt-get update
    sudo apt-get install -y make
else
    echo "Make is already installed."
fi

# Check if slombard.42.fr is already mapped to localhost in /etc/hosts
if ! grep -q "slombard.42.fr" /etc/hosts; then
    echo "Adding slombard.42.fr to /etc/hosts..."
    sudo sh -c 'echo "127.0.0.1 slombard.42.fr" >> /etc/hosts'
    echo "slombard.42.fr has been added to /etc/hosts."
else
    echo "slombard.42.fr is already in /etc/hosts."
fi

# Get the current username
current_user=$(whoami)
# Create the directory if it doesn't exist
export INCEPTION_DATA_PATH="/home/${current_user}/data"
mkdir -p "${INCEPTION_DATA_PATH}"
# Set the INCEPTION_DATA_PATH using the current user's home directory
# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
if ! grep -q "INCEPTION_DATA_PATH" .env; then
    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> ./.env
fi
echo "Droplet setup complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"


echo "Droplet environment setup complete."
