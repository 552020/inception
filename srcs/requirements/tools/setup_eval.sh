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


# Create the directory if it doesn't exist
mkdir -p "${INCEPTION_DATA_PATH}"

# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
if ! grep -q "INCEPTION_DATA_PATH" "${ENV_FILE}"; then
    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> "${ENV_FILE}"
fi

# Set DOMAIN_NAME to slombard.42.fr in the .env file
if grep -q "DOMAIN_NAME" "${ENV_FILE}"; then
    sed -i 's/DOMAIN_NAME=.*/DOMAIN_NAME=slombard.42.fr/' "${ENV_FILE}"
else
    echo "DOMAIN_NAME=slombard.42.fr" >> "${ENV_FILE}"
fi


echo "Droplet setup complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"
