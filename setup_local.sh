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

# Initialize Docker Swarm (local environment)
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
else
    echo "Docker Swarm is already initialized."
fi

# Check for MySQL password files and create Docker secrets
if [ -f ./secrets/mysql_root_password.txt ] && [ -f ./secrets/mysql_user_password.txt ]; then
    echo "Creating Docker secrets from local password files..."
    docker secret rm mysql_root_password || true
    docker secret rm mysql_user_password || true
    cat ./secrets/mysql_root_password.txt | docker secret create mysql_root_password -
    cat ./secrets/mysql_user_password.txt | docker secret create mysql_user_password -
else
    echo "Password files not found in ./secrets/. Exiting."
    exit 1
fi

echo "Local environment setup complete."
