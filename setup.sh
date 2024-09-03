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

# Check if Docker Compose is available (Docker CLI integrated)
if ! docker compose version &> /dev/null
then
    echo "Docker Compose could not be found, installing..."
    sudo apt-get install -y docker-compose-plugin
else
    echo "Docker Compose is already installed."
fi

echo "Environment setup complete."
