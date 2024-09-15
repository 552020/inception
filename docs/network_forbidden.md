### **Explanation of the Remark:**

> Of course, using network: host or --link or links: is forbidden. The network line must be present in your docker-compose.yml file. Your containers musn’t be started with a command running an infinite loop. Thus, this also applies to any command used as entrypoint, or used in entrypoint scripts. The following are a few prohibited hacky patches: tail -f, bash, sleep infinity, while true.

1. **Network Configuration:**

   - **Forbidden Options:**
     - Using `network: host`, `--link`, or `links:` in Docker Compose or Docker commands is prohibited.
     - These options are legacy features or insecure configurations. For example, `network: host` allows the container to share the host’s network stack, which can lead to security vulnerabilities, and `--link` or `links:` are considered outdated ways to connect containers.
   - **Required Configuration:**
     - You must explicitly declare a network in your `docker-compose.yml` file to connect your containers securely. By using the `networks:` section, Docker creates an isolated network for your services, allowing them to communicate without exposing unnecessary details to the host system.

2. **Avoid Infinite Loops:**
   - **No Infinite Loops in Entrypoints:**
     - The subject forbids starting containers with commands that run an infinite loop, such as `tail -f`, `bash`, `sleep infinity`, or `while true`. These loops are sometimes used as a hack to keep the container alive when there’s no real process to run.
     - **Why Is This a Problem?**
       - Containers should remain alive because the main process (such as a web server or database) is running in the foreground, not because a dummy command is keeping them alive. Using infinite loops wastes system resources, breaks Docker's design principles, and leads to poor maintainability.
3. **Proper Foreground Processes:**
   - **Best Practice:**
     - Docker is designed to monitor and manage containers based on their primary process (PID 1). This should be a service like NGINX, MySQL, or PHP-FPM running in the foreground.
     - When the primary process ends, Docker stops the container. If a process runs in the background or you use a hack like `tail -f` or `sleep infinity`, Docker won't know when the container should stop, which leads to inefficiency and complicates debugging.

---

### **Examples of Prohibited Hacky Patches:**

- **`tail -f /dev/null`:** Often used to keep a container running when there's no real service. This command continuously outputs nothing from `/dev/null`, which does nothing useful.
- **`bash`:** Starting a container with `bash` keeps it running, but doesn't serve any purpose unless you're debugging interactively. This is not how containers should be managed in production.

- **`sleep infinity`:** Similar to `tail -f`, it keeps the container alive indefinitely but serves no real purpose for the service you're supposed to run.

- **`while true; do ...; done`:** A simple infinite loop that executes commands indefinitely, which is another hack to keep a container running, but it’s not tied to the actual application or service.

---

### **Proper Solution:**

Instead of using these hacky patches, configure your container to run the correct foreground process that Docker can monitor. For example:

- **NGINX:** Use `daemon off;` to ensure NGINX runs in the foreground.
- **PHP-FPM:** Use the `-F` flag to run PHP-FPM in the foreground.

- **MariaDB:** Use `mysqld_safe`, which runs in the foreground by default.

By ensuring the main service runs properly in the foreground, your Docker containers will behave as expected without the need for these "infinite loop" hacks.

## Again about `host`, `--link`, and `links`

### 1. **`network: host`**

When you use the `host` network mode, Docker skips network isolation and uses the host machine’s network stack directly. This means that containers will share the same network interfaces and IP addresses as the host.

#### **Why It's Discouraged:**

- **Security Risks:** The container has access to the host's network interfaces, which can lead to security vulnerabilities since there is no isolation between the container and the host.
- **Port Conflicts:** Containers and services running on the host could conflict because they share the same ports (e.g., both the host and the container might want to bind to port 80).
- **Inconsistent Environments:** It’s not portable and can lead to issues when moving your setup to other environments (e.g., cloud or different machines).

#### **Example Usage (`network: host`):**

This is **discouraged** in modern Docker setups, but here’s an example of how it would look:

```yaml
version: "3.8"

services:
  web:
    image: nginx
    network_mode: "host" # Using the host's network stack directly
```

In this setup, the NGINX service would share the host’s network stack, so any port NGINX binds to (e.g., port 80) would be directly accessible on the host.

---

### 2. **`--link` and `links:`**

**`--link`** is a deprecated Docker CLI option that was used to connect one container to another by creating an alias for the target container. Docker automatically injected environment variables and DNS entries for the linked containers.

**`links:`** was the equivalent configuration option in Docker Compose, which also allowed you to link containers. This has been superseded by Docker’s modern networking features.

#### **Why It's Discouraged:**

- **Deprecated:** Docker has moved away from using `--link` and `links:` because it introduced tight coupling between containers and made it harder to scale and manage services.
- **Limited Functionality:** It only provided environment variables and a simple alias, whereas Docker's network driver offers better service discovery and container communication.
- **No Isolation:** `--link` didn't respect modern container networking principles, as it bypassed networks and required containers to be on the same host.

#### **Example Usage (`links:`):**

Here’s how you would use `links:` in a Docker Compose file, though this is **deprecated**:

```yaml
version: "3.8"

services:
  db:
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: example

  web:
    image: wordpress
    links:
      - db # Links the web container to the db container
```

In this setup, the `web` container would automatically have access to the `db` container through an alias (by default, `db`), and environment variables would be injected to define the linked container's IP address.

---

### **Modern Docker Networking: Preferred Approach**

Instead of using `network: host` or `links:`, Docker Compose now recommends using the `networks` feature to define isolated networks and allow services to communicate with each other securely and efficiently. Docker automatically manages DNS-based service discovery, so you can refer to other containers by their service name.

---

### **Example 1: Modern Docker Compose Configuration (Simple Network)**

In this example, we’ll create a simple network where a WordPress container can communicate with a MariaDB container over an isolated bridge network. Each service can be reached using its service name (e.g., `db` for MariaDB).

```yaml
version: "3.8"

services:
  db:
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: example
    networks:
      - my_network

  web:
    image: wordpress
    environment:
      WORDPRESS_DB_HOST: db # Using the service name 'db' to connect
      WORDPRESS_DB_PASSWORD: example
    networks:
      - my_network
    ports:
      - "8080:80" # Expose WordPress on port 8080 of the host

networks:
  my_network: # Defining a custom network
    driver: bridge # Using the default bridge driver
```

#### **How It Works:**

- **Custom Network:** The `my_network` network is defined, which isolates the containers from the host’s network and allows them to communicate securely.
- **Service Discovery:** The `web` service can connect to the `db` service using the service name `db` as the hostname.
- **Port Exposure:** Only the `web` container exposes port 8080 on the host, while the `db` container remains isolated.

---

### **Example 2: Docker Compose with Multiple Networks**

In more complex setups, you may want to divide services across multiple networks to enforce different levels of isolation. For example, a backend database might be on a separate network, isolated from the frontend service.

```yaml
version: "3.8"

services:
  db:
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: example
    networks:
      - backend

  web:
    image: wordpress
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_PASSWORD: example
    networks:
      - frontend
      - backend # Web also needs access to the backend network to reach the database
    ports:
      - "8080:80"

  redis:
    image: redis
    networks:
      - frontend # Redis is accessible by the frontend (web) only

networks:
  frontend: # Network for public-facing services
    driver: bridge

  backend: # Private network for internal services (like the DB)
    driver: bridge
```

#### **How It Works:**

- **Two Networks:** `frontend` is for services like `web` and `redis` that handle requests, while `backend` is for private services like the database.
- **Isolation:** The `db` service is isolated on the `backend` network, and only the `web` service has access to it. `redis` is only accessible by services on the `frontend` network.
- **Service Discovery:** The `web` service can access the `db` service using the hostname `db`, even though they are on different networks.

---

### **Conclusion:**

- **`network: host`:** This allows the container to use the host’s network, which can lead to security risks and port conflicts, so it's generally discouraged.
- **`--link` and `links:`:** These are deprecated features that were used to create a direct connection between containers, but modern Docker Compose uses networks instead, providing better isolation, flexibility, and scalability.
- **Modern Networking Approach:** Define isolated networks in your Docker Compose file using `networks:`, which allows containers to communicate securely and with service discovery via DNS. This method is much more flexible, secure, and scalable compared to `host` networking or `links:`.

By adopting Docker's modern networking model, you can ensure that your services are better isolated and more resilient, while also adhering to best practices for containerized applications.
