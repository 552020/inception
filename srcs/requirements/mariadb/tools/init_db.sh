#!/bin/bash

# Retrieve the passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)

# Check if necessary environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_USER_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Required environment variables or secrets are missing!"
    exit 1
fi

# Start MySQL/MariaDB service
mysqld_safe &

# Wait for MySQL to start
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 3
done

# Create database if it doesn't exist
mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# Create user if it doesn't exist
mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"

# Grant all privileges to the user for the database
mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

# Change the root password for localhost
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# Flush privileges to apply changes
mysql -e "FLUSH PRIVILEGES;"

# Shutdown the MariaDB server safely
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Restart MariaDB in safe mode
exec mysqld_safe
