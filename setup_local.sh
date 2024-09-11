#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker for Mac from https://docs.docker.com/docker-for-mac/install/"
    exit 1
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null
then
    echo "Docker Compose (part of Docker CLI) is not available. Please update Docker or install Docker Compose."
    exit 1
else
    echo "Docker Compose is available."
fi

# Check if the password files exist in the local secrets folder
if [ ! -f ./secrets/mysql_root_password.txt ] || [ ! -f ./secrets/mysql_user_password.txt ] || \
   [ ! -f ./secrets/wp_admin_password.txt ] || [ ! -f ./secrets/wp_user_password.txt ]; then
    echo "Password files not found in ./secrets/. Exiting."
    exit 1
else
    echo "Password files found in ./secrets/. Continuing setup..."
fi

# Check if slombard.42.fr is already mapped to localhost in /etc/hosts
if ! grep -q "slombard.42.fr" /etc/hosts; then
    echo "Adding slombard.42.fr to /etc/hosts..."
    sudo sh -c 'echo "127.0.0.1 slombard.42.fr" >> /etc/hosts'
    echo "slombard.42.fr has been added to /etc/hosts."
else
    echo "slombard.42.fr is already in /etc/hosts."
fi

echo "Local environment setup complete."
