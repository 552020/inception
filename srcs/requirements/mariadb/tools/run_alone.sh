#!/bin/bash

# Ensure the secrets directory exists
mkdir -p /run/secrets

# Set the secrets in files (for testing purposes; in production, Docker handles secrets)
echo "root_password" > /run/secrets/mysql_root_password
echo "user_password" > /run/secrets/mysql_user_password

# Export environment variables
export MYSQL_DATABASE="wordpress"
export MYSQL_USER="user"

# Print environment variables for debugging
echo "MYSQL_DATABASE is set to: $MYSQL_DATABASE"
echo "MYSQL_USER is set to: $MYSQL_USER"