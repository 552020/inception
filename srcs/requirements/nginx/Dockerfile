# Use Alpine as the base image
FROM alpine:latest

# Install NGINX, OpenSSL, and any necessary packages, and create a new user to run NGINX
RUN apk add --no-cache nginx openssl certbot certbot-nginx \
	&& adduser -D -H -s /bin/false -u 1000 -G www-data www-data

# Create SSL directory and generate a self-signed certificate
RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
       -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/inception.key \
       -out /etc/nginx/ssl/inception.crt \
       -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr"

# Copy custom NGINX configuration file into the container
COPY ./conf/default.conf /etc/nginx/nginx.conf

# Create the necessary directories
RUN mkdir -p /run/nginx /var/www/wordpress /var/www/html

# Add an HTML file to serve as a test page
# Add an HTML file to serve as a test page
RUN echo "<h1>Hello from NGINX in Docker</h1>" > /var/www/html/index.html

# Ensure correct ownership of the web directories
RUN chown -R www-data:www-data /var/www/html /var/www/wordpress


# Expose port 443 for HTTPS
EXPOSE 443

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]

