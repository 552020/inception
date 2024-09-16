# Inception (as a Real-World Project)

**Inception** is a school project for 42 Berlin about setting up a Dockerized self-hosted infrastructure for serving a WordPress website with NGINX, MariaDB, and optional additional services like Redis, FTP, and Adminer.

**Disclaimer:** As a school project that needs to be evaluated on a school machine (without a public IP and without sudo rights), the subject imposes some limitations:

1. The WordPress website needs to be served to localhost by redirecting the required website domain `<login>.42.fr` to localhost through tweaking the `/etc/hosts` file.
2. Since we don't have sudo rights on the Ubuntu machine where the evaluation will take place, development must occur on a virtual machine (VM).
3. Therefore, the SSL/TLS certificates will be self-signed.

The code in this repository is designed for three environments:

1. **Evaluation environment** – respecting the subject’s limitations, serving a WordPress website as `<login>.42.fr` (to localhost) with self-signed certificates.
2. **Cloud environment** – an Ubuntu virtual machine (DigitalOcean droplet) with a public IP address, serving a WordPress website on the real domain `slombard.xyz` with real SSL/TLS certificates.
3. **Local development environment** – a MacOS machine serving `slombard.xyz` with self-signed certificates.

The local and cloud environments are connected through a GitHub Actions pipeline, while the evaluation environment is independent. There are three scripts to set up the different environments and modify relevant variables in the .env file.

## Digital Ocean VM and Local Development

We are developing the project for two different environments: a cloud-based VM on Digital Ocean (Ubuntu) and a local development machine (macOS).

**Cloud Environment:**  
For the cloud-based VM, passwords are managed through GitHub secrets. During deployment, the GitHub Actions workflow creates temporary secret files on the VM in a `/secrets/` dir and removes them once the containers are up and running.

**Local Development Environment:**  
In the local environment, passwords are stored as text files in a `/secrets/` directory. The SSL certificates include self-signed certificates for the `login.42.fr` WordPress site and a real certificate for the 'bonus' website. There is also a minimal extra website for localhost with a self-signed certificate.

**Note:** The script that checks for the necessary applications for Docker and Docker Compose is OS-dependent. Ensure you use the correct script for each environment.

## Install Docker on the VM

To install Docker, use the following commands:

```bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
systemctl status docker
```

## Setup GitHub Actions

In order to deploy code from GitHub Actions to a remote droplet, we need to enable secure SSH access between GitHub and the droplet. This process involves creating a public-private key pair for authentication.

Here’s how it works:

1. **Creating SSH Keys on the Droplet:**

   - On the remote droplet, we generate an SSH key pair (public and private keys). The public key is added to the `authorized_keys` file on the droplet, allowing the droplet to recognize and accept connections from the corresponding private key.

2. **Configuring GitHub Actions:**

   - Since GitHub Actions operates in an ephemeral environment (a fresh environment created and destroyed with each workflow run), we cannot reliably configure and store keys on it in the same way we would on a long-lived VM.
   - Instead, we share the private key of the SSH key pair with GitHub Actions. This allows GitHub Actions to authenticate and securely access the droplet for deployment tasks.

3. **Why This Method?**
   - **Ephemeral Environments:** GitHub Actions workflows run in temporary environments that are created and destroyed for each run. Configuring SSH keys directly on these environments would be cumbersome and less reliable.
   - **Practicality:** Using this 'reversed' method—sharing the private key with GitHub Actions while adding the public key to the droplet—is a practical workaround. It simplifies the setup by avoiding the need to repeatedly configure SSH keys on an ephemeral environment and the remote droplet.

This approach ensures secure communication between GitHub Actions and your remote droplet without the complexities of managing SSH keys in an ephemeral environment.

## Notes

### **Avoid Using Root for SSH on the droplet**: It is not recommended to use root for SSH access. Instead, create a new user, grant them sudo privileges, and disable root SSH login:

```bash
adduser newuser
usermod -aG sudo newuser
```

Edit the SSH configuration to disable root login:

```bash
vim /etc/ssh/sshd_config
PermitRootLogin no
sudo systemctl restart ssh
```

### Unified Path for Docker Volumes Between macOS, Ubuntu, and a Virtual Machine

#### Problem Statement

In the subject, we are required to store the two volumes for WordPress and MariaDB in the directory `/home/login/data`, where `login` should be our own 42 login (in this case, `/home/slombard/data`). These volumes need to persist outside of Docker containers, ensuring data remains even when containers are removed or recreated.

The challenge is to ensure these volumes work across different environments:

- A **DigitalOcean droplet** with Ubuntu.
- A **MacBook Air** running macOS.
- A **school Ubuntu machine** where a virtual machine (VM) will be used.

#### The Challenge: Home Directory Differences in Ubuntu and macOS

The key issue is that each environment uses a different path for the user's home directory. Ubuntu uses `/home/username/`, while macOS uses `/Users/username/`. The `~` shortcut works for user directories in terminal commands, but it doesn't work in Docker Compose volume definitions, which means we need to reference paths explicitly.

#### Solution: Dynamic Environment Variable for Volume Paths

To unify the volume paths across environments, we can use an environment variable (e.g., `INCEPTION_DATA_PATH`) that stores the correct path dynamically based on the current user. By using the `whoami` command, we can retrieve the username and automatically configure the volume paths accordingly.

- **Ubuntu (DigitalOcean droplet & school VM):** The home directory is `/home/username/`.
- **macOS:** The home directory is `/Users/username/`.

The environment variable `INCEPTION_DATA_PATH` will be set in a setup script that checks the operating system and retrieves the current user's name with `whoami`. The script will create the necessary directories if they don’t exist, ensuring consistency across environments.

#### How the Setup Works

1. **Dynamic User Detection:** The script uses `whoami` to detect the current user and constructs the correct home directory path, whether on macOS or Ubuntu.
2. **Environment Variable for Docker Compose:** The path is stored in `INCEPTION_DATA_PATH`, which is then used in the `docker-compose.yml` file for volume definitions. This ensures that the same Compose file works on all environments.
3. **Directory Creation:** The script ensures the volume directories exist on each machine by creating them if necessary.

#### Conclusion

By dynamically setting the volume path using environment variables and detecting the current user with `whoami`, we create a unified setup that works seamlessly across Ubuntu and macOS environments without modifying Docker Compose files manually. This approach ensures flexibility and persistence of data across all systems.

## FAQ

### Why Don’t We Run `update` and `upgrade` in Alpine Like in Debian and Ubuntu?

In Alpine Linux, the typical command sequence is:

```bash
apk update
```

This updates the package index and ensures you get the latest available packages. In contrast, **Debian/Ubuntu** uses:

```bash
apt update && apt upgrade
```

- `apt update`: Refreshes the package list.
- `apt upgrade`: Upgrades installed packages to their latest versions.

**Why the Difference?**

1. **Minimalism**: Alpine is designed to be minimal and lightweight, with fewer dependencies compared to Debian-based systems.
2. **Immutable Containers**: In Docker environments, containers are often rebuilt rather than updated, making `apk upgrade` less necessary.
3. **Package Management Philosophy**: Alpine’s `apk` combines installation and updating, making a separate `upgrade` command redundant in many cases.

Thus, running `apk update` before installing packages is usually sufficient in container environments.

### Writing and Accessing Secrets

For managing secrets in GitHub Actions, refer to [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).

### Observation: Docker Compose Build vs. Container Failures

**Observation**: Docker Compose can build all services correctly, but individual containers may still fail without explicit warnings.

**Question**: How can we ensure that containers started by Docker Compose are running correctly and avoid silent failures?

**Answer**: To address this, use the following debugging strategies:

- **Check Container Status**: Use `docker ps -a` to list all containers and their statuses. This helps identify containers that are not running as expected.
- **View Logs**: Use `docker logs <container_id>` to view the logs of a specific container. This can provide insights into why a container may have failed or is not functioning correctly.

- **Inspect Containers**: Use `docker inspect <container_id>` to get detailed information about a container's configuration and state.

- **Interactive Shell**: Run an interactive shell inside a container using `docker exec -it <container_id> /bin/bash` (or `/bin/sh` if Bash is not available) to troubleshoot issues directly.

By incorporating these strategies, you can better manage and debug your Docker Compose setup.

## Commands

### `docker ps`

`docker ps` shows a list of all running Docker containers. By adding the `-a` flag (`docker ps -a`), you can see all containers, including those that are stopped or exited.

**Common Flags for `docker ps`:**

- `-a` or `--all`: Show all containers (default shows just running containers).
- `-q` or `--quiet`: Show only container IDs.
- `--filter` or `-f`: Filter output based on conditions provided.
- `--format`: Format the output using a Go template.
- `--no-trunc`: Do not truncate output (show full container IDs).

#### 2. Removing Old Containers and Images

To clean up old and unused Docker containers and images, follow these steps:

**Removing Specific Containers:**

You can remove containers by their ID or name. Based on your output:

- Alpine MariaDB container: `mariadb-instance`
- Midnight Network container: `frosty_faraday`
- Test containers: `mariadb_test_container` and `maria-test-container`

To remove these containers:

```bash
docker rm alpine-mariadb
docker rm midnightnetwork/proof-server
docker rm mariadb_test_container
docker rm maria-test-container
```

**Removing Unused Images:**

To remove unused images, you can use the following command:

```bash
docker image prune -a
```

This command removes all unused images. If you want to remove a specific image, use:

```bash
docker rmi <image-id>
```

## Docker Overview

### What is a Docker Container?

A Docker container is a lightweight, portable, and isolated environment that allows applications to run consistently across different computing environments.

**Expanded definition**:  
A Docker container is a complete, isolated package that encapsulates an application along with its dependencies, libraries, and configuration files. It leverages the host system's kernel, making it efficient and portable across various environments. Containers ensure that applications run consistently regardless of the underlying infrastructure, reducing the overhead associated with full virtual machines while providing robust isolation and ease of deployment.

## History of Docker

Docker was introduced to the public in March 2013 by a company called dotCloud, which later rebranded as Docker, Inc. The idea behind Docker was to solve the common problem of "it works on my machine," providing developers with a consistent environment in which to run their applications. Docker leverages containerization technology, which had been around in various forms in the Linux ecosystem, but Docker made it more accessible and usable by simplifying container management.

The launch of Docker marked a significant shift in the way developers and IT operations approached software deployment. The open-source project quickly gained popularity, becoming a cornerstone of modern DevOps practices, and leading to the creation of a vast ecosystem around it. Docker's approach to containerization has revolutionized software development, enabling the rise of microservices architectures, cloud-native applications, and continuous integration/continuous deployment (CI/CD) pipelines.

Docker, Inc. has since continued to develop and expand its platform, contributing to the broader container ecosystem, which includes orchestration tools like Kubernetes, integration with cloud providers, and development of enterprise-grade container management solutions.

### Docker images vs. Docker containers

### Alpine vs Debian

## Choosing Between Alpine and Debian for Docker

In this project, we need to build Docker images for various services like NGINX, WordPress, and MariaDB. A critical decision is choosing the base operating system for these images. The two most common options are Alpine and Debian.

### Alpine

Alpine is a minimalistic Linux distribution designed specifically for environments where size, speed, and security are paramount. It is commonly used in Docker containers due to its small footprint and simplicity.

#### Advantages in This Project

- **Small Image Size**: Alpine is significantly smaller than Debian, which leads to faster download times and reduced storage usage. This is particularly advantageous in a Docker environment where efficiency is crucial.
- **Security**: The minimal nature of Alpine reduces the attack surface, making it inherently more secure. Fewer installed packages mean fewer potential vulnerabilities.
- **Efficiency**: For services like NGINX, Alpine provides all the necessary components without the overhead of unnecessary packages, resulting in faster builds and leaner containers.

#### Considerations

- **Compatibility**: Alpine uses `musl` instead of the more common `glibc`, which can sometimes lead to compatibility issues with certain software. However, for standard services like NGINX and MariaDB, this is rarely a problem.
- **Learning Curve**: Alpine’s minimalism can be a double-edged sword; it requires more manual setup and configuration compared to Debian, which might introduce a slight learning curve.

### Debian

Debian is one of the most widely used and stable Linux distributions. It is known for its robustness, extensive package repositories, and broad software compatibility.

#### Advantages in This Project

- **Stability and Compatibility**: Debian is known for its stability and uses `glibc`, ensuring broad compatibility with a wide range of software. This can make it easier to set up and manage services without worrying about compatibility issues.
- **Ease of Use**: Debian’s comprehensive package manager and the inclusion of many utilities by default make it more straightforward to set up and maintain services. This can be beneficial if your project requires additional tools or packages.

#### Considerations

- **Larger Image Size**: Debian images are larger than Alpine, which can lead to longer download times and increased storage usage. In a Docker environment, this can be less efficient.
- **Overhead**: The additional packages and utilities included in Debian, while sometimes useful, can also introduce unnecessary overhead in a containerized environment where minimalism is often preferred.

### Conclusion

We pick up Alpine. We pick up the 3.19 version which is the penultimate stable version on 1.st of September 2024

## Docker commands

To start a container we need first to build it and then to run it.

### build

`docker build <path/to/Dockerfile>`

flags:

- `-t <name>` to name a container

### run

`docker run <image_name>`

### ps

To know the containers currently launched

# TLS v1.2 vs TLS v1.3

- What is the difference betweeen a self issued certificate and a certificate issued by a CA.
- What is the certificate attesting?
- How to generate a self issued certificate?
- How to get a certificate issued by a CA?

## Resources

https://tuto.grademe.fr/inception/

https://letsencrypt.org/
