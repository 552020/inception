# TODOs

- [x] Each Docker image must have the same name as its corresponding service.

This is something we need to set in docker compose. The default name of the image of a service is <project*name>*<service_name>. The name of the project, if a name is not specifiied, is the name of the folder where the docker compose file resides. We can specify a custom image name, with the keyword image.

- [x] Each service has to run in a dedicated container.

- [x] For performance matters, the containers must be built either from the penultimate stable version of Alpine or Debian. The choice is yours.

- [x] You also have to write your own Dockerfiles, one per service. The Dockerfiles must be called in your docker-compose.yml by your Makefile.

You then have to set up:

- [x] A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only.

- [x] To make things simpler, you have to configure your domain name so it points to your local IP address. This domain name must be login.42.fr. Again, you have to use your own login. For example, if your login is wil, wil.42.fr will redirect to the IP address pointing to wil’s website.

We have 3 environments:

- local: It's not a problem to change
