# Use the penultimate stable version of Alpine as the base image
FROM alpine:3.19

# Install NGINX, OpenSSL, and Certbot for managing SSL certificates
RUN apk add --no-cache nginx openssl certbot certbot-nginx \
    && adduser -D -H -s /bin/false -u 1000 -G www-data www-data

# Create SSL directory and generate a self-signed certificate for slombard.42.fr
RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
       -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/slombard.42.fr.key \
       -out /etc/nginx/ssl/slombard.42.fr.crt \
       -subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=42/CN=slombard.42.fr" \
    && openssl req -x509 -nodes -days 365 \
       -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/localhost.key \
       -out /etc/nginx/ssl/localhost.crt \
       -subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=42/CN=localhost"

# Copy custom NGINX configuration file into the container
COPY ./conf/default.conf /etc/nginx/nginx.conf

# Create the necessary directories for NGINX and WordPress
RUN mkdir -p /run/nginx /var/www/wordpress var/www/html

# Add an HTML file for localhost with "Hello from localhost" message
RUN echo "<h1>Hello from localhost!</h1>" > /var/www/html/index.html

# Ensure correct ownership of the web directories
RUN chown -R www-data:www-data /var/www/wordpress

# Expose port 443 for HTTPS
EXPOSE 443

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
