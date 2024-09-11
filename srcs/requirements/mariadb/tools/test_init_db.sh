#!/bin/bash

# Ensure the secrets directory exists
mkdir -p /run/secrets

# Set the secrets in files (for testing purposes; in production, Docker handles secrets)
echo "root_password" > /run/secrets/mysql_root_password
echo "user_password" > /run/secrets/mysql_user_password

# Export environment variables
export MYSQL_DATABASE="wordpress"
export MYSQL_USER="user"

# Print environment variables to check
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "MYSQL_USER: $MYSQL_USER"

# Retrieve the passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)

# Check if necessary environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_USER_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Required environment variables or secrets are missing!"
    exit 1
fi

# Initialize the MariaDB database (creates system tables if they don't exist)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL/MariaDB service
mysqld_safe &

# Wait for MariaDB to be ready (simpler check)
until mariadb -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Waiting for MariaDB to start..."
    sleep 3
done
echo "MariaDB is up and running."

# # Create database if it doesn't exist
# mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

# # Create user if it doesn't exist
# mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';"

# # Grant all privileges to the user for the database
# mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

# # Change the root password for localhost
# mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# # Flush privileges to apply changes
# mysql -e "FLUSH PRIVILEGES;"

# Create a temporary SQL file for setup
SQL_FILE="/tmp/init.sql"
if [ ! -f "$SQL_FILE" ]; then
    echo "Creating setup script at $SQL_FILE..."
    
    echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" >> "$SQL_FILE"
    echo "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" >> "$SQL_FILE"
    echo "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';" >> "$SQL_FILE"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" >> "$SQL_FILE"
    echo "FLUSH PRIVILEGES;" >> "$SQL_FILE"
    
    echo "Setup script created."
fi

# Run the setup SQL
mariadb < "$SQL_FILE"

# Shutdown the MariaDB server safely
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Restart MariaDB in safe mode
exec mysqld_safe