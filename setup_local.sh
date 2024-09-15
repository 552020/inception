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

# Generate self-signed SSL certificates for myricae.xyz if they do not already exist
MYRICAE_CERT_DIR="./srcs/certbot-etc/live/myricae.xyz"
if [ ! -f "$MYRICAE_CERT_DIR/fullchain.pem" ] || [ ! -f "$MYRICAE_CERT_DIR/privkey.pem" ]; then
    echo "Self-signed certificates for myricae.xyz not found. Generating..."

    mkdir -p $MYRICAE_CERT_DIR

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$MYRICAE_CERT_DIR/privkey.pem" \
        -out "$MYRICAE_CERT_DIR/fullchain.pem" \
        -subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=42/CN=myricae.xyz"

    echo "Self-signed certificates for myricae.xyz generated successfully."
else
    echo "Self-signed certificates for myricae.xyz already exist."
fi

# Get the current username
current_user=$(whoami)
# Set the INCEPTION_DATA_PATH using the current user's home directory
export INCEPTION_DATA_PATH="/Users/${current_user}/data"
# Create the directory if it doesn't exist
mkdir -p "${INCEPTION_DATA_PATH}"
# Optionally write to .env file for Docker Compose
# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
if ! grep -q "INCEPTION_DATA_PATH" .env; then
    echo "" >> ./.env
    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> ./.env
fi
echo "Local setup complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"


echo "Local environment setup complete."
