# Use penultimate stable version of Alpine as the base image
FROM alpine:3.19

# Environment variables for database
ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Install MariaDB and related packages
RUN apk update && apk add --no-cache mariadb mariadb-client

# Create necessary directories
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && \
    mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copy the configuration file
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Copy the script to initialize the database
COPY ./scripts/init_db.sh /init_db.sh

# Make the script executable
RUN chmod +x /init_db.sh

# Expose the port for later use, optional based on your future steps
EXPOSE 3306

# Start the database
CMD ["/init_db.sh"]
