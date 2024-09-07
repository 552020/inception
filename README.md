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

### Writing and accessing secrets

https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions
