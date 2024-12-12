# Use Alpine Linux as the base image
FROM alpine:3.20

# Install necessary packages: PHP, PHP-FPM, WP-CLI, Redis, MariaDB client, and other dependencies
RUN echo "Installing required packages..." \
    && apk update \
    && apk add --no-cache \
    php83 php83-fpm php83-mysqli php83-json php83-opcache \
    php83-curl php83-dom php83-exif php83-fileinfo \
    php83-mbstring php83-session php83-xml php83-zip \
    php83-redis php83-phar \
    mariadb-client \
    curl bash \
    && echo "Package installation complete."

# Create a symlink from php81 to php to ensure WP-CLI works
#RUN echo "Creating PHP symlink..." \
#&& ln -s /usr/bin/php81 /usr/bin/php \
#&& echo "Symlink created."

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
COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

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
