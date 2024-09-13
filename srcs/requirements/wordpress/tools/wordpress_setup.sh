#!/bin/bash

# Retrieve the passwords from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_USER_PASSWORD=$(cat /run/secrets/mysql_user_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)


# Check if the WordPress directory exists
if [ -d /var/www/wordpress ]; then
    cd /var/www/wordpress
else
    echo "WordPress directory not found!"
    exit 1
fi

# Download WordPress core if it's not already installed
if [ ! -d /var/www/wordpress/wp-admin ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root || { echo "Failed to download WordPress core!"; exit 1; }
fi

# Check if wp-config.php already exists and environment variables are set
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_USER_PASSWORD" ] || [ -z "$DB_HOST" ]; then

    echo "Database credentials not set!"
    exit 1
fi

# Print out database connection details for debugging
echo "Attempting to connect to MariaDB:"
echo "DB_HOST: $DB_HOST"
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "MYSQL_USER: $MYSQL_USER"
echo "MYSQL_USER_PASSWORD: $MYSQL_USER_PASSWORD"

# Test the connection to MariaDB before proceeding
timeout=180
waited=0
until mysqladmin ping --host=$DB_HOST --user=$MYSQL_USER --password=$MYSQL_USER_PASSWORD --silent; do
    echo "Waiting for MariaDB connection... waited ${waited} seconds."
    sleep 5
    waited=$((waited+5))
    if [ "$waited" -ge "$timeout" ]; then
        echo "MariaDB connection timed out after ${waited} seconds!"
        exit 1
    fi
done
echo "MariaDB connection established."

# Generate wp-config.php if it doesn't exist
if [ ! -e /var/www/wordpress/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create --allow-root \
                     --dbname=$MYSQL_DATABASE \
                     --dbuser=$MYSQL_USER \
                     --dbpass=$MYSQL_USER_PASSWORD \
                     --dbhost=$DB_HOST \
                     || { echo "wp-config.php creation failed!"; exit 1; }
fi

# Perform WordPress core installation
if ! wp core is-installed --allow-root; then
	echo "WordPress core not installed!"
	exit 1
fi

wp core install --url="$DOMAIN_NAME" \
				--title="$SITE_TITLE" \
				--admin_user="$WP_ADMIN" \
				--admin_password="$WP_ADMIN_PASSWORD" \
				--admin_email="$WP_ADMIN_EMAIL" \
				--allow-root

# Create a new WordPress user
if [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "User details not set!"
    exit 1
fi

if ! wp user get $WP_USER --allow-root > /dev/null 2>&1; then
    wp user create --allow-root $WP_USER $WP_USER_EMAIL --role=editor --user_pass=$WP_USER_PASSWORD
else
    echo "User $WP_USER already exists."
fi

# Ensure PHP-FPM directory exists
if [ ! -d /run/php ]; then
    mkdir /run/php
fi

# Run PHP-FPM
php-fpm81 -F
