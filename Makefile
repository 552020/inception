
COMPOSE_FILE=./srcs/docker-compose.dev.yml

# Default value for detached mode. "false" is just a string, not a boolean. The ?= operator is used to set the value only if it is not already set. This makes possible to assign detached=true when calling make, like this: make detached=true
detached ?= false

# Conditionally set COMPOSE_OPTIONS based on the value of 'detached'
ifeq ($(detached), true)
  COMPOSE_OPTIONS = -d
else
  COMPOSE_OPTIONS =
endif


all: check_files build up

# Check if password files exist and are not empty (for local development)
check_files:
	@echo "Checking if secret files exist..."
	@if [ ! -f ./secrets/mysql_root_password.txt ] || [ ! -s ./secrets/mysql_root_password.txt ]; then \
		echo "MySQL root password file not found or empty. Exiting..."; \
		exit 1; \
	fi
	@if [ ! -f ./secrets/mysql_user_password.txt ] || [ ! -s ./secrets/mysql_user_password.txt ]; then \
		echo "MySQL user password file not found or empty. Exiting..."; \
		exit 1; \
	fi
	@echo "Secret files are set."

build: check_files
	@echo "Building the application..."
	docker compose -f $(COMPOSE_FILE) --env-file .env build

up: check_files
	@echo "Starting the application..."
	docker compose -f $(COMPOSE_FILE) --env-file .env up  $(COMPOSE_OPTIONS) 

# Stop the containers without removing them
stop: 
	@echo "Stopping the application..."
	docker compose -f ./srcs/docker-compose.dev.yml  --env-file .env stop


# Stop the containers and remove them
down:
	@echo "Stopping and removing containers..."
	docker compose -f ./srcs/docker-compose.dev.yml --env-file .env down

fclean:
	@echo "Stopping and removing containers, networks, volumes, and images..."
	docker compose -f $(COMPOSE_FILE) --env-file .env down --rmi all

re: fclean all



.PHONY: all build up down check_files stop fclean re 