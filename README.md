# Inception as a real world project

This repo is about making inception a real world project.

## Digital Ocean VM

We picked up a Digital Ocean droplet to have a VM in the cloud, but you could use any other service.

Is it possible to do it also locally? The problem is that you normally don't have a public IP address on your local machine.

It's not necessary but recommanded to have SSH access to your droplet, so that you can control it from your local machine. The alternative would be to work on the console of the web interface of the provider (digial Ocean)

## Install docker in the VM

Install docker

```
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
systemctl status docker
```

## Setup GitHub Actions

Explain why you are creating private and public key on the remote and sharing the private key with the GitHub Actions server. Normally you never share the private key.

https://chatgpt.com/c/4b6528ac-466b-4788-86e1-ceedf8061488

We need to manually clone the repository in the remote, for that since it could be a private repository GitHub needs to know the public key of the droplet. We need to copy the SSH publich key in GitHub and then clone the repo.

## Notes

- Remember that acting as a root from SSH is not reccomende, and you should disable it. You should ass a new user, give to them sudo powers and disable root ssh login

```
adduser newuser
suermod -aG sudo newuser
```

```
vim vim /etc/ssh/sshd_config
PermitRootLogin no
sudo systemctl restart ssh


```

## FAQ

### Why We Don’t Run `update` and `upgrade` in Alpine like in Debian and Ubuntu

In Alpine, the typical command sequence is:

```bash
apk update
```

This refreshes the package index, ensuring Alpine knows about the latest versions of available packages.

In contrast, in **Debian/Ubuntu**, you run both:

```bash
apt update && apt upgrade
```

- `apt update`: Refreshes the package list.
- `apt upgrade`: Upgrades all installed packages to the latest versions.

**Why the Difference?**

1. **Minimalism**: Alpine is designed to be minimal and lightweight, with packages that have fewer dependencies. It doesn’t have the heavy package management overhead of Debian-based systems.
2. **Immutable Containers**: In Docker environments (like Alpine), containers are often rebuilt from scratch rather than being upgraded. This makes `apk upgrade` unnecessary in most cases.

3. **Package Management Philosophy**: Alpine uses `apk` to handle installation and updates in one go. In most use cases, once you install a package using `apk add`, it is assumed you’re running the latest version, negating the need for a separate `upgrade` command.

Thus, running `apk update` before installing packages is sufficient to ensure you have the latest versions, making `upgrade` redundant in container environments.

### Writing and accessing secrets

https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions
