# Use penultimate stable version of Alpine as the base image
FROM alpine:3.19

# Install MariaDB and related packages
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Check if the 'mysql' user and group exist, and create them if they don't
# RUN if ! getent group mysql >/dev/null; then \
#         addgroup -S mysql; \
#     fi && \
#     if ! id -u mysql >/dev/null 2>&1; then \
#         adduser -S -G mysql mysql; \
#     fi

# Debug prints to ensure the mysql user and group exist
# RUN echo "Checking mysql user and group existence:" && \
#     id mysql && \
#     echo "mysql user exists" && \
#     getent group mysql && \
#     echo "mysql group exists"

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

# Initialize the MariaDB database
# RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db


# Expose the port for later use, optional based on your future steps
EXPOSE 3306

# Switch to 'mysql' user before running the service
# USER mysql

# Start the database
CMD ["bash", "./init_db.sh"]
# CMD ["bash"]
