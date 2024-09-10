#!/bin/bash

# Check if the WordPress directory exists
if [ -d /var/www/wordpress ]; then
    cd /var/www/wordpress
else
    echo "WordPress directory not found!"
    exit 1
fi

# Wait for MariaDB to be ready
while ! mysqladmin ping --host=$DB_HOST --silent; do
    echo "Waiting for MariaDB connection..."
    sleep 5
done

# Check if wp-config.php already exists and environment variables are set
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PSWD" ]; then
    echo "Database credentials not set!"
    exit 1
fi

# Generate wp-config.php if it doesn't exist
if [ ! -e /var/www/wordpress/wp-config.php ]; then
    wp config create --allow-root \
                     --dbname=$SQL_DATABASE \
                     --dbuser=$SQL_USER \
                     --dbpass=$SQL_PSWD \
                     --dbhost=mariadb:3306
fi

# Perform WordPress core installation
wp core install --url="$DOMAIN_NAME" \
                --title="$SITE_TITLE" \
                --admin_user="$WP_ADMIN" \
                --admin_password="$WP_ADMIN_PSWD" \
                --admin_email="$WP_ADMIN_EMAIL" \
                --allow-root

# Create a new WordPress user
if [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ] || [ -z "$WP_USER_PSWD" ]; then
    echo "User details not set!"
    exit 1
fi

wp user create --allow-root $WP_USER $WP_USER_EMAIL \
               --role=editor \
               --user_pass=$WP_USER_PSWD

# Ensure PHP-FPM directory exists
if [ ! -d /run/php ]; then
    mkdir /run/php
fi

# Run PHP-FPM
php-fpm81 -F
