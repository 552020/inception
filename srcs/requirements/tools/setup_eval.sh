#!/bin/bash

# Define the root of the project as three directories up from the current directory
# ROOT=../../..
# Determine the absolute path of the project root (three directories up from the script's location)
ROOT=$(cd "$(dirname "$0")/../../.." && pwd)

# Define the secrets directory relative to the project root
SECRETS_DIR="${ROOT}/secrets"
echo $SECRETS_DIR
ls $SECRETS_DIR

# Define the path to the .env file
ENV_FILE="${ROOT}/.env"

# Define the path for SSL certificates for myricae.xyz
MYRICAE_CERT_DIR="${ROOT}/srcs/ssl/myricae.xyz"

# Define the path for SSL certificates for slombard.xyz
SLOMBARDXYZ_CERT_DIR="${ROOT}/srcs/ssl/slombard.xyz"

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


# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker."
    exit 1
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null
then
    echo "Docker Compose is not available. Please install Docker Compose."
    exit 1
else
    echo "Docker Compose is available."
fi



# Check if the current user is part of the docker group
current_user=$(whoami)
if groups "$current_user" | grep -q "\bdocker\b"; then
    echo "User '$current_user' is part of the docker group."
else
    echo "User '$current_user' is NOT part of the docker group. Please add the user to the docker group and log out/log in again:"
    echo "sudo usermod -aG docker $current_user"
    exit 1
fi

# Check if the password files exist in the local secrets folder
if [ ! -f "${SECRETS_DIR}/mysql_root_password.txt" ] || \
   [ ! -f "${SECRETS_DIR}/mysql_user_password.txt" ] || \
   [ ! -f "${SECRETS_DIR}/wp_admin_password.txt" ] || \
   [ ! -f "${SECRETS_DIR}/wp_user_password.txt" ]; then
    echo "Password files not found in ${SECRETS_DIR}. Exiting."
    exit 1
else
    echo "Password files found in ${SECRETS_DIR}. Continuing setup..."
fi

# Generate self-signed SSL certificates for myricae.xyz if they do not already exist
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


# Generate self-signed SSL certificates for slombard.xyz if they do not already exist
if [ ! -f "$SLOMBARDXYZ_CERT_DIR/fullchain.pem" ] || [ ! -f "$SLOMBARDXYZ_CERT_DIR/privkey.pem" ]; then
    echo "Self-signed certificates for slombard.xyz not found. Generating..."

    mkdir -p $SLOMBARDXYZ_CERT_DIR

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SLOMBARDXYZ_CERT_DIR/privkey.pem" \
        -out "$SLOMBARDXYZ_CERT_DIR/fullchain.pem" \
        -subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=42/CN=slombard.xyz"

    echo "Self-signed certificates for slombard.xyz generated successfully."
else
    echo "Self-signed certificates for slombard.xyz already exist."
fi

# Check if slombard.42.fr is already mapped to localhost in /etc/hosts
if ! grep -q "slombard.42.fr" /etc/hosts; then
    echo "Adding slombard.42.fr to /etc/hosts..."
    sudo sh -c 'echo "127.0.0.1 slombard.42.fr" >> /etc/hosts'
    echo "slombard.42.fr has been added to /etc/hosts."
else
    echo "slombard.42.fr is already in /etc/hosts."
fi

# Create the directory if it doesn't exist
#export INCEPTION_DATA_PATH="/home/${current_user}/data"


# Create the directory if it doesn't exist
#mkdir -p "${INCEPTION_DATA_PATH}"

# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
#if ! grep -q "INCEPTION_DATA_PATH" "${ENV_FILE}"; then
#    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> "${ENV_FILE}"
#fi

# Set DOMAIN_NAME to slombard.42.fr in the .env file
if grep -q "DOMAIN_NAME" "${ENV_FILE}"; then
    sed -i 's/DOMAIN_NAME=.*/DOMAIN_NAME=slombard.42.fr/' "${ENV_FILE}"
else
    echo "DOMAIN_NAME=slombard.42.fr" >> "${ENV_FILE}"
fi
# Safely update NGINX_CONF_FILE to 'eval.conf' in the .env file
sed -i 's/^NGINX_CONF_FILE=.*/NGINX_CONF_FILE=eval.conf/' "${ENV_FILE}"

# Display the contents of .env to confirm the changes
echo "Updated .env file content:"
cat "${ENV_FILE}"

echo "Evaluation evironment complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"
