#!/bin/bash

# Start MySQL/MariaDB service
mysqld_safe &

# Wait for MySQL to start
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 3
done

# Create database if it doesn't exist
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

# Create user if it doesn't exist
mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

# Grant all privileges to the user for the database
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

# Change the root password for localhost
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

# Flush privileges to apply changes
mysql -e "FLUSH PRIVILEGES;"

# Shutdown the MariaDB server safely
mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

# Restart MariaDB in safe mode
exec mysqld_safe
