# Use Alpine as the base image
FROM alpine:latest

# Install NGINX, OpenSSL, and any necessary packages
RUN apk add --no-cache nginx openssl

# Create SSL directory and generate a self-signed certificate
RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
       -newkey rsa:2048 \
       -keyout /etc/nginx/ssl/inception.key \
       -out /etc/nginx/ssl/inception.crt \
       -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr"

# Copy custom NGINX configuration file into the container
COPY ./nginx.conf /etc/nginx/nginx.conf

# Create the necessary directories
RUN mkdir -p /run/nginx /var/www/wordpress

# Expose port 443 for HTTPS
EXPOSE 443

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
