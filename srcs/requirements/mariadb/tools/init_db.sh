#!/bin/bash

# Retrieve the passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)

# Debug: Print current users
echo "Current users in the system:"
cat /etc/passwd || echo "/etc/passwd file not found"



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


# Set the path to the MariaDB data directory
DATA_DIR="/var/lib/mysql"

# Check if the MariaDB data directory is already initialized
if [ -d "$DATA_DIR/mysql" ]; then
    echo "MariaDB data directory already exists. Skipping initialization."
else
    echo "MariaDB data directory not found. Initializing..."
    
    # Initialize the MariaDB database
    mysql_install_db --user=mysql --datadir="$DATA_DIR" || { echo "Error: Failed to initialize MariaDB data directory."; exit 1; }
fi



# Start MySQL/MariaDB service
echo "Starting MariaDB service..."
mysqld_safe &
sleep 5  # Give MariaDB some time to start


echo "Waiting for MariaDB to be fully ready..."
timeout=180  # Max wait time
waited=0     # Time already waited

while true; do
    # Check if MariaDB responds to ping
    mysqladmin ping || { echo "MariaDB ping failed, server might not be up yet."; }

    # Check if MariaDB can respond to a query with password
    mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" && echo "MariaDB is responding to queries."

    # Exit loop if both checks succeed
    if mysqladmin ping && mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;"; then
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

# Run the setup SQL script with the root password
echo "Running SQL setup script..."
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" < "$SQL_FILE" || { echo "Error: Failed to execute SQL setup script."; exit 1; }
echo "SQL setup script executed successfully."

# Shutdown the MariaDB server safely
echo "Shutting down MariaDB safely..."
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || { echo "Error: Failed to shut down MariaDB."; exit 1; }
echo "MariaDB shutdown complete."

# Restart MariaDB in safe mode
echo "Restarting MariaDB in safe mode..."
exec mysqld_safe