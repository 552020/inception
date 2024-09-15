# TODOs

- [x] Each Docker image must have the same name as its corresponding service.

This is something we need to set in docker compose. The default name of the image of a service is <project*name>*<service_name>. The name of the project, if a name is not specifiied, is the name of the folder where the docker compose file resides. We can specify a custom image name, with the keyword image.

- [x] Each service has to run in a dedicated container.

- [x] For performance matters, the containers must be built either from the penultimate stable version of Alpine or Debian. The choice is yours.

- [x] You also have to write your own Dockerfiles, one per service. The Dockerfiles must be called in your docker-compose.yml by your Makefile.

You then have to set up:

- [x] A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only.
- [x] A Docker container that contains WordPress + php-fpm (it must be installed and configured) only without nginx.
- [x] A Docker container that contains MariaDB only without nginx.
- [x] A volume that contains your WordPress database.
- [x] A second volume that contains your WordPress website files.
- [x] A docker-network that establishes the connection between your containers.

- [x] Your containers have to restart in case of a crash.

- [x] Read and understand I: A Docker container is not a virtual machine. Thus, it is not recommended to use any hacky patch based on ’tail -f’ and so forth when trying to run it. Read about how daemons work and whether it’s a good idea to use them or not: see the doc `docker_container_vs_VM.md` for a better explanation).

- [x] Read and understand II: Of course, using network: host or --link or links: is forbidden. The network line must be present in your docker-compose.yml file. Your containers musn’t be started with a command running an infinite loop. Thus, this also applies to any command used as entrypoint, or used in entrypoint scripts. The following are a few prohibited hacky patches: tail -f, bash, sleep infinity, while true.

- [x] Read and understand III: Read about PID 1 and the best practices for writing Dockerfiles.

- [x] In your WordPress database, there must be two users, one of them being the administrator. The administrator’s username can’t contain admin/Admin or administrator/Administrator (e.g., admin, administrator, Administrator, admin-123, and so forth).

- [x] Your volumes will be available in the /home/login/data folder of the host machine using Docker. Of course, you have to replace the login with yours.

- [x] To make things simpler, you have to configure your domain name so it points to your local IP address. This domain name must be login.42.fr. Again, you have to use your own login. For example, if your login is wil, wil.42.fr will redirect to the IP address pointing to wil’s website.

- [x] The latest tag is prohibited.
- [x] No password must be present in your Dockerfiles.
- [x] It is mandatory to use environment variables.
- [x] Also, it is strongly recommended to use a .env file to store environment variables and strongly recommended that you use the Docker secrets to store any confidential information.
- [ ] Your NGINX container must be the only entrypoint into your infrastructure via the port 443 only, using the TLSv1.2 or TLSv1.3 protocol.
