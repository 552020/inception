# TODOs

## Subject

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
- [x] Your NGINX container must be the only entrypoint into your infrastructure via the port 443 only, using the TLSv1.2 or TLSv1.3 protocol.

## Eval sheet

## Mandatory Part

**Preliminary tests**

- [x] Any credentials, API keys, environment variables must be set inside a `.env` file during the evaluation. In case any credentials, API keys are available in the Git repository and outside of the `.env` file created during the evaluation, the evaluation stops and the mark is 0.
- [x] Defense can only happen if the evaluated student or group is present. This way everybody learns by sharing knowledge with each other.
- [x] If no work has been submitted (or wrong files, wrong directory, or wrong filenames), the grade is 0, and the evaluation process ends.
- [x] For this project, you have to clone their Git repository on their station.

Here’s the formatted content as Markdown with checkboxes:

**General instructions**

- [x] For the entire evaluation process, if you don't know how to check a requirement or verify anything, the evaluated student has to help you.

- [ ] Ensure that all the files required to configure the application are located inside a `srcs` folder. The `srcs` folder must be located at the root of the repository.

- [x] Ensure that a `Makefile` is located at the root of the repository.

- [ ] Before starting the evaluation, run this command in the terminal:

  ```bash
  docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
  ```

- [x] Read the `docker-compose.yml` file. There mustn't be `'network: host'` in it or `'links:'`. Otherwise, the evaluation ends now.

- [x] Read the `docker-compose.yml` file. There must be `'network(s)'` in it. Otherwise, the evaluation ends now.

- [x] Examine the `Makefile` and all the scripts in which Docker is used. There mustn't be `'--link'` in any of them. Otherwise, the evaluation ends now.

- [x] Examine the Dockerfiles. If you see `'tail -f'` or any command run in background in any of them in the `ENTRYPOINT` section, the evaluation ends now. Same thing if `'bash'` or `'sh'` are used but not for running a script (e.g., `'nginx & bash'` or `'bash'`).

- [x] Examine the Dockerfiles. The containers must be built either from the penultimate stable version of Alpine or Debian.

- [x] If the entrypoint is a script (e.g., `ENTRYPOINT ["sh", "my_entrypoint.sh"]`, `ENTRYPOINT ["bash", "my_entrypoint.sh"]`), ensure it runs no program in the background (e.g., `'nginx & bash'`).

- [x] Examine all the scripts in the repository. Ensure none of them runs an infinite loop. The following are a few examples of prohibited commands: `'sleep infinity'`, `'tail -f /dev/null'`, `'tail -f /dev/random'`.

- [x] Run the `Makefile`.

**Project overview**

This project consists in setting up a small infrastructure composed of different services using Docker Compose. Ensure that all the following points are correct.

- [ ] The evaluated person has to explain to you in simple terms:
- [ ] How Docker and Docker Compose work.
- [ ] The difference between a Docker image used with Docker Compose and without Docker Compose.
- [ ] The benefit of Docker compared to VMs.
- [ ] The pertinence of the directory structure required for this project (an example is provided in the subject's PDF file).

**Simple setup**

- [ ] Ensure that **NGINX** can be accessed by port **443 only**. Once done, open the page.
- [ ] Ensure that an **SSL/TLS certificate** is used.
- [ ] Ensure that the **WordPress website** is properly installed and configured (you shouldn't see the WordPress Installation page). To access it, open `https://login.42.fr` in your browser, where `login` is the login of the evaluated student. You shouldn't be able to access the site via `http://login.42.fr`. If something doesn't work as expected, the evaluation process ends now.

**Docker Basics**

- [x] Start by checking the Dockerfiles. There must be **one Dockerfile per service**. Ensure that the Dockerfiles are not empty files. If it's not the case or if a Dockerfile is missing, the evaluation process ends now.

- [x] Make sure the evaluated student has **written their own Dockerfiles** and built their own Docker images. It is forbidden to use ready-made ones or services such as DockerHub.

- [x] Ensure that every container is built from the **penultimate stable version of Alpine/Debian**. If a Dockerfile does not start with `'FROM alpine:X.X.X'` or `'FROM debian:XXXXX'`, or any other local image, the evaluation process ends now.

- [x] The Docker images must have the **same name as their corresponding service**. Otherwise, the evaluation process ends now.

- [x] Ensure that the **Makefile has set up all the services via Docker Compose**. This means that the containers must have been built using Docker Compose and that no crash happened. Otherwise, the evaluation process ends.

**Docker Network**

- [x] Ensure that **docker-network** is used by checking the `docker-compose.yml` file.
- [ ] Run the command `docker network ls` to verify that a network is visible.
- [ ] The evaluated student has to give you a **simple explanation of docker-network**.

**NGINX with SSL/TLS**

- [x] Ensure that there is a **Dockerfile** for the NGINX service.
- [ ] Using the `docker compose ps` command, ensure that the container was created (using the `-p` flag is authorized if necessary).
- [ ] Try to access the service via **http (port 80)** and verify that you cannot connect.
- [ ] Open `https://login.42.fr/` in your browser, where `login` is the login of the evaluated student. The displayed page must be the configured **WordPress website** (you shouldn't see the WordPress Installation page).
- [ ] The use of a **TLS v1.2/v1.3 certificate** is mandatory and must be demonstrated. The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear.

**WordPress with php-fpm and its Volume**

- [x] Ensure that there is a **Dockerfile** for the WordPress service.
- [x] Ensure that there is **no NGINX** in the Dockerfile.
- [ ] Using the `docker compose ps` command, ensure that the container was created (using the `-p` flag is authorized if necessary).
- [ ] Ensure that there is a **Volume**. To do so, run the command `docker volume ls`, then `docker volume inspect <volume name>`. Verify that the result in the standard output contains the path `/home/login/data/`, where `login` is the login of the evaluated student.
- [ ] Ensure that you can **add a comment** using the available WordPress user.
- [ ] **Sign in** with the administrator account to access the Administration dashboard. The Admin username must not include "admin" or "Admin" (e.g., admin, administrator, Admin-login, admin-123, and so forth).
- [ ] From the Administration dashboard, **edit a page**. Verify on the website that the page has been updated.

**MariaDB and its Volume**

- [x] Ensure that there is a **Dockerfile** for the MariaDB service.
- [x] Ensure that there is **no NGINX** in the Dockerfile.
- [ ] Using the `docker compose ps` command, ensure that the container was created (using the `-p` flag is authorized if necessary).
- [ ] Ensure that there is a **Volume**. To do so, run the command `docker volume ls`, then `docker volume inspect <volume name>`. Verify that the result in the standard output contains the path `/home/login/data/`, where `login` is the login of the evaluated student.
- [ ] The evaluated student must be able to explain how to **login into the database**.
- [ ] **Verify that the database is not empty**.

**Persistence!**

- [ ] This part is pretty straightforward. You have to reboot the virtual machine. Once it has restarted, launch docker compose again. Then, verify that everything is functional, and that both WordPress and MariaDB are configured. The changes you made previously to the WordPress website should still be here. If any of the above points is not correct, the evaluation process ends now.

**Bonus**

- [ ] Evaluate the bonus part if, and only if, the mandatory part has been entirely and perfectly done, and the error management handles unexpected or bad usage. In case all the mandatory points were not passed during the defense, bonus points must be totally ignored. Add 1 point per bonus authorized in the subject. Verify and test the proper functioning and implementation of each extra service. For the free choice service, the evaluated student has to give you a simple explanation about how it works and why they think it is useful.

## Extra

- [ ] Solve problem of having the wordpress website served as slombard.42.fr on localhost with self-signed certicates and as slombard.xyz with SSL/TLS certificates. The main problem was the fact that Wordpress needs a specific URL in the configuration. With two server blocks, one serving slombard.42.fr with self-signed certificates and another server block for slombard.xyz with SSL/TLS certificates, images were not properly delivered. There are different possible solutions to the problem: a. duplicate the websites (double wordpress container and double mariadb container), b. allow multi-site wordpress, c. allow multi-url website, d. have slombard.42.fr only in the eval environment. We'll go for the last one.

- [ ] Design custom build for the eval environment.

- [ ] Custom _NGINX config_. We need to have an ad hoc eval.conf NGINX config file and a config file for the droplet (which will be used also for local development). We will have the file as env variables and change it depending the environment on the environemnt (eval or droplet). The local environemnt will use the same config of the droplet, the certificates will be self-signed, but located at the same place where the TLS/SSL certificates are. - [ ] We need to specify conditionally, depending on the environemnt (eval vs drplet/local) the URL of the website, which is already an env variable.

- [ ] Change Wordpress Theme. https://wordpress.org/themes/

- [] Move setup scripts to srcs/tools

- [] Understand the debate about the `.env` file: https://42born2code.slack.com/archives/C04C5N7EWS2/p1709318094589039

- [ ] Add rsync to sync the development and the droplet environemnt https://en.wikipedia.org/wiki/Rsync

- [ ] Ask Dilshod again about his trick regarding secrets

- [ ] Understand difference between ARG, ENV and the .env file in Docker and Docker compose

  - https://vsupalov.com/docker-arg-env-variable-guide/
  - https://stackoverflow.com/questions/41916386/arg-or-env-which-one-to-use-in-this-case
  - https://docs.docker.com/reference/dockerfile/

- [ ] Go fast through the Udmey course: https://www.udemy.com/course/docker-mastery/?couponCode=ST11MT91624B

- [ ] Go fast through the docs
