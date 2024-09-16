#!/bin/bash

# Define the root of the project as three directories up from the current directory
# ROOT=../../..
# Determine the absolute path of the project root (three directories up from the script's location)
ROOT=$(cd "$(dirname "$0")/../../.." && pwd)

# Define the path to the .env file
ENV_FILE="${ROOT}/.env"

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

# Get the current username
current_user=$(whoami)
# Create the directory if it doesn't exist
export INCEPTION_DATA_PATH="/home/${current_user}/data"

# Create the directory if it doesn't exist
mkdir -p "${INCEPTION_DATA_PATH}"

# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
if ! grep -q "INCEPTION_DATA_PATH" "${ENV_FILE}"; then
    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> "${ENV_FILE}"
fi

# Safely update NGINX_CONF_FILE to 'droplet.conf' in the .env file
sed -i 's/^NGINX_CONF_FILE=.*/NGINX_CONF_FILE=droplet.conf/' "${ENV_FILE}"

# Display the contents of .env to confirm the changes
echo "Updated .env file content:"
cat "${ENV_FILE}"


echo "Droplet setup complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"