# Inception as a Real-World Project

This repository is about making "Inception" a practical, real-world project.

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

- **Avoid Using Root for SSH on the droplet**: It is not recommended to use root for SSH access. Instead, create a new user, grant them sudo privileges, and disable root SSH login:

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
