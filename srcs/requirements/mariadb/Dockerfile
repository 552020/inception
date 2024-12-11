# Use penultimate stable version of Alpine as the base image
FROM alpine:3.20

# Install MariaDB and related packages
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Create necessary directories
RUN mkdir -p /run/mysqld && \
    mkdir -p /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql && \
    chmod 755 /run/mysqld /var/lib/mysql /var/log/mysql

# Copy the configuration file
COPY ./conf/my.cnf /etc/my.cnf

# Copy the script to initialize the database
COPY ./tools/init_db.sh /init_db.sh

# Make the script executable
RUN chmod +x /init_db.sh

# Expose the port for later use, optional based on your future steps
EXPOSE 3306

# Start the database
CMD ["bash", "./init_db.sh"]
