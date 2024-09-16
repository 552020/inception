# Notes around the subject

## Notes On The Subject

### **Why do we need a Virtual Machine?**

### **Why do we need a Makefile besides the Docker compose file?**

### **Which are the unfamiliar concepts?**

Docker, TLS, Docker Networking, Daemon Processes, Makefile usage, and Docker security practices are likely areas that might require further learning.

1. **Docker and Containerization**: Dockerfiles, images, containers, volumes, networks, and `docker-compose`.

2. **TLS (Transport Layer Security)**: The project requires you to set up NGINX with TLSv1.2 or TLSv1.3, which involves understanding SSL/TLS protocols, certificates, and secure communication over the web.

3. **Docker Networking**: Configuring a Docker network that allows containers to communicate securely without using shortcuts like `network: host` or `--link` might be new to you. Understanding Docker's networking model, including bridge networks and how containers resolve each other via DNS, is crucial.

4. **Daemon Processes and PID 1**: The project specifically mentions avoiding hacky solutions like `tail -f` to keep containers running. This refers to the need to understand how Unix-like systems manage processes, especially in the context of Docker containers where a single process (usually PID 1) is responsible for the container's lifecycle.

5. **Security Best Practices in Docker**: The guidelines mention avoiding certain practices, like storing passwords directly in Dockerfiles and instead using environment variables and Docker secrets. This points to security best practices in Dockerized environments, which might be new to you.

### LEMP vs LAMP
