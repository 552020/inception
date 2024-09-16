# NGNIX Dockerfile

Normally you would have used the official image for ngnix, but we are not allowed to do so.

Basically we need an OS to run NGNIX. Then we need to install NGNIX, for that we will use the package manager of the OS of our choice. And we need also OpenSSl to generate the certificates for SSL.

1. We choose the image from which we will create the container. For that we use the keyword FROM

```docker
# Use the penultimate stable version of Alpine
FROM alpine:3.19
```

2. Install NGINX and OpenSSL.

3. Generate the certificate

### Command Overview:

```bash
generate_ssl_cert="openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/key.pem -out /etc/nginx/ssl/cert.pem \
                   -sha256 -days 3650 -nodes -subj \"/C=DE/ST=Berlin/O=42Berlin/CN=slombard.42.fr\""; \
```

This command is designed to create a self-signed SSL certificate using OpenSSL, and it assigns this command to the variable `generate_ssl_cert`. Let's examine each part:

### Detailed Breakdown:

1. **`openssl req`**:

   - This invokes the OpenSSL tool and specifies that we are creating a new certificate request (`req` stands for "request").

2. **`-x509`**:

   - This option tells OpenSSL to generate a self-signed certificate instead of just a certificate signing request (CSR). The `-x509` option is used to create the certificate directly.

3. **`-newkey rsa:4096`**:

   - This option creates a new private key and a certificate request simultaneously. The `rsa:4096` specifies that the key should be an RSA key with a length of 4096 bits.

4. **`-keyout /etc/nginx/ssl/key.pem`**:

   - This specifies the file path where the generated private key will be saved. In this case, it will be saved as `key.pem` in the `/etc/nginx/ssl/` directory.

5. **`-out /etc/nginx/ssl/cert.pem`**:

   - This specifies the file path where the generated certificate will be saved. In this case, it will be saved as `cert.pem` in the `/etc/nginx/ssl/` directory.

6. **`-sha256`**:

   - This option specifies the hashing algorithm to use for the certificate's signature. SHA-256 is a secure and widely used hash function.

7. **`-days 3650`**:

   - This specifies the validity period of the certificate. In this case, the certificate will be valid for 3650 days, which is equivalent to 10 years.

8. **`-nodes`**:

   - This option tells OpenSSL not to encrypt the private key with a passphrase. "nodes" stands for "no DES," where DES is a type of encryption. This makes the private key easier to use programmatically but less secure since it is not protected by a password.

9. **`-subj "/C=DE/ST=Berlin/O=42Berlin/CN=slombard.42.fr"`**:

   - This option allows you to provide the subject information for the certificate directly on the command line, avoiding the interactive prompts. The subject string consists of:
     - `/C=DE`: Country (C) is Germany (DE).
     - `/ST=Berlin`: State (ST) is Berlin.
     - `/O=42Berlin`: Organization (O) is 42Berlin.
     - `/CN=slombard.42.fr`: Common Name (CN) is `slombard.42.fr`, which is typically the domain name for which the certificate is issued.

10. **`"; \`**:
    - The command ends with `"; \`, which means the command is stored as a string in the `generate_ssl_cert` variable. The `\` allows the command to continue on the next line without breaking the syntax.

### Summary:

The command creates a self-signed SSL certificate with a 4096-bit RSA key, valid for 10 years, and stores the private key and certificate in `/etc/nginx/ssl/key.pem` and `/etc/nginx/ssl/cert.pem` respectively. The certificate is not password-protected and contains subject information for an entity located in Berlin, Germany, with the common name `slombard.42.fr`.

This command is useful for generating SSL certificates for development or internal use, where a self-signed certificate is sufficient.

3. Start the container after we wrote it in interactive mode.

```bash
docker build -t inception . >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Inception part is built ✅"
else
    echo "ERROR:"
    echo "---"
    echo " "
    docker build -t inception .
    echo " "
    echo "---"
    echo "Solve this problem, Inception is not built ❌"
    exit 1
fi

echo "Launch with -it ? (y/n)"
read answer
if [ "$answer" = "y" ]; then
    echo "Use 'exit' to stop container"
    docker run -it inception
else
    docker run inception
fi
```

## NGNIX configuration

The configuration of jcruzet

```ngnix
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {
	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}
```

Let's break down and analyze the lines of the **default NGINX config file** as requested. I'll also provide commentary in the context of the **Inception project**, ensuring that the config is minimal and satisfies the requirements.

---

### 1. **User Directive**:

```nginx
user www-data;
```

- **What is this?**: The `user` directive specifies the **system user** under which NGINX worker processes will run.
- **Why is it set to `www-data`?**:

  - **`www-data`** is a standard user for web services on many Linux distributions (especially Debian-based systems like Ubuntu).
  - This user is **non-privileged** and only has access to web server resources, improving security. By running NGINX under a non-root user, we minimize the risk of attacks that could compromise the whole system.

- **Do we need this?**: Yes, to ensure NGINX runs under a secure user. You could leave it as `www-data`, or change it depending on the user you’ve set up for your web server.

### 2. **Worker Processes**:

```nginx
worker_processes auto;
```

- **What is this?**: The `worker_processes` directive controls the number of worker processes NGINX uses to handle client requests.
- **Why is it set to `auto`?**:
  - The `auto` value tells NGINX to automatically set the number of worker processes based on the number of CPU cores. This is a good practice for performance, as it optimizes resource utilization.
  - **Is this the default?**: No, the default value is `1`. Setting it to `auto` helps improve performance on multi-core systems.
- **Do we need this?**:
  - While you could leave it at the default (`1`), using `auto` makes NGINX more efficient in multi-core environments, especially in production. It's not strictly required for your project but recommended for better performance.

### 3. **PID Directive**:

```nginx
pid /run/nginx.pid;
```

- **What is this?**: The `pid` directive specifies the file where NGINX will store its **process ID** (PID).
- **Why do we need this?**:

  - This PID file is important for managing NGINX processes (e.g., restarting, stopping, or signaling NGINX).
  - By knowing the PID, system tools can send signals (like `kill` or `reload`) to the correct NGINX process.

- **Do we need this?**: It is helpful for system management, but **not strictly required** in a minimal setup unless you plan to control NGINX directly. You can leave it in for easier process management.

### 4. **Include Directive**:

```nginx
include /etc/nginx/modules-enabled/*.conf;
```

- **What is this?**: The `include` directive tells NGINX to include additional configuration files.
- **Why do we need this?**:

  - This line includes any NGINX modules that might be enabled on your system (e.g., specific SSL modules, performance modules).
  - If you're using default modules provided by your Linux distribution, this is important to ensure all functionality (like SSL, Gzip compression, etc.) works properly.

- **Do we need this?**: For a **minimal configuration**, you could remove this if you're not using extra NGINX modules. However, it’s a safe default to leave in unless you know exactly which modules are unnecessary.

### 5. **Events Section**:

```nginx
events {
	worker_connections 768;
	# multi_accept on;
}
```

- **What is this section?**: The `events` block defines how NGINX handles connections and events.
- **Why do we need this?**:
  - **`worker_connections`**: This directive sets the maximum number of simultaneous connections per worker process. The value `768` is reasonable for moderate traffic, but for minimal configurations, you could reduce this if needed (the default is usually `1024`).
  - **`multi_accept`**: This allows each worker process to accept multiple new connections at once. It’s commented out by default, and you can leave it that way unless you need to optimize for high traffic (which is likely unnecessary for a minimal setup).
- **Do we need `worker_connections`?**: Yes, this is needed to control the number of connections per worker. You could set it to `1024` (the default), or leave it at `768`.
- **Do we need `multi_accept`?**: This can remain commented out in a minimal configuration. It’s not required unless you’re dealing with high loads.

#### What are these sections called in NGINX?

- These are called **blocks** in NGINX configuration. Blocks group directives that configure specific areas (like `events`, `http`, `server`, etc.).

### 6. **HTTP Section**:

```nginx
http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip Settings
    gzip on;

    # Virtual Host Configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

- **HTTP Block**: This block contains the main configuration for NGINX’s HTTP and HTTPS operations.

#### Basic Settings:

- **`sendfile on;`**: This enables efficient file transfer. It's almost always turned on for performance.
- **`tcp_nopush on;`**: Improves performance when sending large files over the network.
- **`tcp_nodelay on;`**: Reduces delays in network communications.
- **`keepalive_timeout 65;`**: Sets the duration to keep connections alive for reuse. `65` is reasonable but can be adjusted based on performance needs.
- **`types_hash_max_size 2048;`**: Optimizes how NGINX handles file types.

- **Do we need these?**: These directives are all **best practices** for performance. You could leave them in for a more efficient setup, but they’re not strictly necessary for basic functionality.

#### SSL Settings:

- **`ssl_protocols TLSv1.2 TLSv1.3;`**: Specifies the allowed SSL/TLS protocols. This satisfies the project requirement to use only TLSv1.2 and TLSv1.3.
- **`ssl_prefer_server_ciphers on;`**: Ensures the server’s choice of SSL/TLS ciphers is preferred over the client’s choice for better security.

- **Do we need these?**: Yes, these are critical for your project as TLSv1.2 or TLSv1.3 must be used for secure communication.

#### Logging:

- **`access_log` and `error_log`**: These directives specify where to store logs for access and errors.
- **Do we need these?**: Yes, logs are useful for debugging, but you could minimize logging by reducing verbosity or commenting these lines out.

#### Gzip Compression:

- **`gzip on;`**: Enables gzip compression to reduce the size of HTTP responses.
- **Do we need this?**: Gzip is useful for performance but **not required** for a minimal setup. You can remove it if you want the simplest configuration possible.

#### Virtual Hosts:

- **`include /etc/nginx/conf.d/*.conf;`**: Includes additional configuration files from the `conf.d` directory.
- **`include /etc/nginx/sites-enabled/*;`**: Includes additional site configurations from the `sites-enabled` directory.

- **Do we need these?**: If your setup requires multiple virtual hosts or custom site configurations, leave these in. If not, they can be removed for simplicity.

---

### **Final Minimal NGINX Configuration for Inception Project**:

Here's a **minimal configuration** that satisfies the project requirements for TLSv1.2/TLSv1.3 and NGINX setup:

```nginx
user www-data;
worker_processes auto;

events {
    worker_connections 768;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Virtual Host Configs
    # include /etc/nginx/conf.d/*.conf; # Not needed if we use Alpine
    include /etc/nginx/sites-enabled/*;
}

```

### Summary:

- **Keep only the essential settings** that optimize performance and security (e.g., `sendfile`, `tcp_nopush`, TLS settings).
- **Simplify the configuration** by removing optional settings like Gzip or multi_accept unless you specifically need them.
- **Focus on meeting the requirements**, especially for TLS settings and minimal configuration, without over-complicating the file.

This version ensures that NGINX runs with
