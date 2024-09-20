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
MYRICAE_CERT_DIR="${ROOT}/srcs/certbot-etc/live/myricae.xyz"

#Define the parh for SSL certicates for slombad.xyz
SLOMBARDXYZ_CERT_DIR="${ROOT}/srcs/certbot-etc/live/slombard.xyz"

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

# Check if slombard.xyz is already mapped to localhost in /etc/hosts
if ! grep -q "slombard.xyz" /etc/hosts; then
    echo "Adding slombard.xyz to /etc/hosts..."
    sudo sh -c 'echo "127.0.0.1 slombard.xyz" >> /etc/hosts'
    echo "slombard.xyz has been added to /etc/hosts."
else
    echo "slombard.xyz is already in /etc/hosts."
fi

# Get the current username
current_user=$(whoami)
# Set the INCEPTION_DATA_PATH using the current user's home directory
export INCEPTION_DATA_PATH="/Users/${current_user}/data"
# Create the directory if it doesn't exist
mkdir -p "${INCEPTION_DATA_PATH}"
# Optionally write to .env file for Docker Compose
# Ensure only one instance of INCEPTION_DATA_PATH is written to .env
if ! grep -q "INCEPTION_DATA_PATH" "${ENV_FILE}"; then
    echo "" >> "${ENV_FILE}"
    echo "INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}" >> "${ENV_FILE}"

fi

# Safely update NGINX_CONF_FILE to 'droplet.conf' in the .env file (macOS syntax)
sed -i '' 's/^NGINX_CONF_FILE=.*/NGINX_CONF_FILE=droplet.conf/' "${ENV_FILE}"

# Display the contents of .env to confirm the changes
echo "Updated .env file content:"
cat "${ENV_FILE}"

echo "Local setup complete with INCEPTION_DATA_PATH=${INCEPTION_DATA_PATH}"