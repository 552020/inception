# Use penultimate stable version of Alpine as the base image
FROM alpine:3.19

# Install MariaDB and related packages
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Create necessary directories
RUN mkdir -p /run/mysqld && \
    mkdir -p /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql


# Copy the configuration file
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Copy the script to initialize the database
COPY ./tools/init_db.sh /init_db.sh
COPY ./tools/run_alone.sh /run_alone.sh
COPY ./tools/test_init_db.sh /test_init_db.sh

# Make the script executable
RUN chmod +x /init_db.sh && chmod +x /run_alone.sh && chmod +x /test_init_db.sh

# Expose the port for later use, optional based on your future steps
EXPOSE 3306

# Start the database
CMD ["bash", "./init_db.sh"]
# CMD ["bash"]
