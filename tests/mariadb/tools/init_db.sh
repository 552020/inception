#!/bin/bash

# Retrieve the passwords from Docker secrets
# MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
# MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)

## TEST MODE START // HARDCODING SECRETS FOR TESTING PURPOSE

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
## TEST MODE END


# Debug: Print current users
echo "Current users in the system:"
cat /etc/passwd || echo "/etc/passwd file not found"

# Ensure that the 'mysql' user exists
if id "mysql" >/dev/null 2>&1; then
    echo "User 'mysql' exists."
else
    echo "Error: User 'mysql' does not exist. Exiting."
    exit 1
fi

# Ensure that the 'mysql' group exists
if getent group mysql >/dev/null 2>&1; then
    echo "Group 'mysql' exists."
else
    echo "Error: Group 'mysql' does not exist. Exiting."
    exit 1
fi

# Retrieve the passwords from Docker secrets
if [[ -f /run/secrets/mysql_root_password ]]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
    echo "Successfully retrieved MySQL root password from secrets."
else
    echo "Error: MySQL root password secret file not found!"
    exit 1
fi

if [[ -f /run/secrets/mysql_user_password ]]; then
    MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)
    echo "Successfully retrieved MySQL user password from secrets."
else
    echo "Error: MySQL user password secret file not found!"
    exit 1
fi


# Check if necessary environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ]; then
    echo "Error: MYSQL_DATABASE or MYSQL_USER environment variables are not set."
    exit 1
else
    echo "MYSQL_DATABASE: $MYSQL_DATABASE"
    echo "MYSQL_USER: $MYSQL_USER"
fi


# Initialize the MariaDB database (always try to initialize to ensure system tables exist)
echo "Initializing MariaDB data directory..."
mysql_install_db --user=mysql --datadir=/var/lib/mysql || { echo "Error: Failed to initialize MariaDB data directory."; exit 1; }


# Start MySQL/MariaDB service
echo "Starting MariaDB service..."
mysqld_safe &
sleep 5  # Give MariaDB some time to start


# # Wait for MariaDB to be ready
# echo "Waiting for MariaDB to start and accept connections..."
# timeout=180
# waited=0
# while ! mariadb -u root -e "SELECT 1;" >/dev/null 2>&1; do
#     sleep 3
#     waited=$((waited+3))
#     echo "MariaDB is not ready yet... waited ${waited} seconds."
#     if [ "$waited" -ge "$timeout" ]; then
#         echo "Error: MariaDB took too long to start."
#         exit 1
#     fi
# done
# echo "MariaDB is up and running."

# Wait for MariaDB to be ready by checking both 'mysqladmin ping' and 'mariadb -u root -e "SELECT 1;"'
echo "Waiting for MariaDB to be fully ready..."
timeout=180  # Max wait time
waited=0     # Time already waited

while true; do
    # Check if MariaDB responds to ping
    mysqladmin ping || { echo "MariaDB ping failed, server might not be up yet."; }

    # Check if MariaDB can respond to a query
    mariadb -u root -e "SELECT 1;" && echo "MariaDB is responding to queries."

    # Exit loop if both checks succeed
    if mysqladmin ping && mariadb -u root -e "SELECT 1;"; then
        echo "MariaDB is ready and accepting connections."
        break
    fi

    # Wait and update waited time
    sleep 3
    waited=$((waited+3))
    echo "Waited ${waited} seconds for MariaDB."

    # Timeout after a certain period
    if [ "$waited" -ge "$timeout" ]; then
        echo "Error: MariaDB took too long to start."
        exit 1
    fi
done


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
echo "Creating setup script at $SQL_FILE..."
# Always recreate the SQL file from scratch to ensure idempotence
echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;" > "$SQL_FILE"
echo "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';" >> "$SQL_FILE"
echo "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';" >> "$SQL_FILE"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" >> "$SQL_FILE"
echo "FLUSH PRIVILEGES;" >> "$SQL_FILE"
echo "Setup script created."


# Run the setup SQL script
echo "Running SQL setup script..."
mariadb -u root < "$SQL_FILE" || { echo "Error: Failed to execute SQL setup script."; exit 1; }
echo "SQL setup script executed successfully."

# Shutdown the MariaDB server safely
echo "Shutting down MariaDB safely..."
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || { echo "Error: Failed to shut down MariaDB."; exit 1; }
echo "MariaDB shutdown complete."

# Restart MariaDB in safe mode
echo "Restarting MariaDB in safe mode..."
exec mysqld_safe