# # Use Alpine Linux as the base image

# FROM alpine:3.19


# # Install necessary packages: PHP, PHP-FPM, WP-CLI, Redis, MariaDB client, and other dependencies

# RUN apk update && apk add --no-cache \
#     php81 php81-fpm php81-mysqli php81-json php81-opcache \
#     php81-curl php81-dom php81-exif php81-fileinfo \
#     php81-mbstring php81-session php81-xml php81-zip \
#     php81-redis php81-phar \
#     mariadb-client \
#     curl bash

# # Create a symlink from php81 to php to ensure WP-CLI works
# RUN ln -s /usr/bin/php81 /usr/bin/php

# # Install WP-CLI for WordPress management
# RUN curl -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
#     && chmod +x wp-cli.phar \
#     && mv wp-cli.phar /usr/local/bin/wp

# # Create the www-data user and group only if they don't already exist
# RUN if ! getent group www-data > /dev/null; then addgroup -S www-data; fi \
#     && if ! id -u www-data > /dev/null 2>&1; then adduser -S -G www-data www-data; fi

# # Set up volumes for WordPress files (declared early for persistent data handling), in the actual setup this doesn't do anything cause we have the declaration in the docker-compose file
# VOLUME ["/var/www/wordpress"]

# # Copy custom PHP-FPM configuration
# COPY ./conf/www.conf /etc/php81/php-fpm.d/www.conf

# # Download and extract WordPress
# RUN mkdir -p /var/www/wordpress && \
#     curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
#     tar -xzf wordpress.tar.gz -C /var/www/wordpress --strip-components=1 && \
#     rm wordpress.tar.gz

# # Set ownership and appropriate permissions of the WordPress directory
# RUN chown -R www-data:www-data /var/www/wordpress \
#     && chmod -R 755 /var/www/wordpress

# # Copy the WordPress setup script into the container
# COPY ./tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
# RUN chmod +x /usr/local/bin/wordpress_setup.sh

# # Expose port 9000 for PHP-FPM
# EXPOSE 9000

# # Set the WordPress setup script as the ENTRYPOINT
# ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]

# Use Alpine Linux as the base image
FROM alpine:3.20

# Install necessary packages: PHP, PHP-FPM, WP-CLI, Redis, MariaDB client, and other dependencies
RUN echo "Installing required packages..." \
    && apk update \
    && apk add --no-cache \
    php81 php81-fpm php81-mysqli php81-json php81-opcache \
    php81-curl php81-dom php81-exif php81-fileinfo \
    php81-mbstring php81-session php81-xml php81-zip \
    php81-redis php81-phar \
    mariadb-client \
    curl bash \
    && echo "Package installation complete."

# Create a symlink from php81 to php to ensure WP-CLI works
RUN echo "Creating PHP symlink..." \
    && ln -s /usr/bin/php81 /usr/bin/php \
    && echo "Symlink created."

# Install WP-CLI for WordPress management
RUN echo "Downloading WP-CLI..." \
    && curl -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && echo "WP-CLI installed."

# Create the www-data user and group only if they don't already exist
RUN echo "Setting up www-data user and group..." \
    && if ! getent group www-data > /dev/null; then addgroup -S www-data; fi \
    && if ! id -u www-data > /dev/null 2>&1; then adduser -S -G www-data www-data; fi \
    && echo "www-data user and group setup complete."

# Set up volumes for WordPress files (declared early for persistent data handling)
VOLUME ["/var/www/wordpress"]

# Copy custom PHP-FPM configuration
COPY ./conf/www.conf /etc/php81/php-fpm.d/www.conf

# Download and extract WordPress
RUN echo "Downloading and extracting WordPress..." \
    && mkdir -p /var/www/wordpress \
    && curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf wordpress.tar.gz -C /var/www/wordpress --strip-components=1 \
    && rm wordpress.tar.gz \
    && echo "WordPress downloaded and extracted."

# Set ownership and appropriate permissions of the WordPress directory
RUN echo "Setting permissions for WordPress directory..." \
    && chown -R www-data:www-data /var/www/wordpress \
    && chmod -R 755 /var/www/wordpress \
    && echo "Permissions set for WordPress directory."

# Copy the WordPress setup script into the container
COPY ./tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
RUN echo "Setting up WordPress setup script permissions..." \
    && chmod +x /usr/local/bin/wordpress_setup.sh \
    && echo "WordPress setup script is ready."

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Set the WordPress setup script as the ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
