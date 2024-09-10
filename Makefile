.PHONY: nginx local droplet check_files


# Set environment variables from secrets
MYSQL_ROOT_PASSWORD := ./secrets/mysql_root_password.txt
MYSQL_USER_PASSWORD := ./secrets/mysql_user_password.txt


# Check if password files exist and are not empty (for development)
check_files:
	@if [ ! -f $(MYSQL_ROOT_PASSWORD) ] || [ ! -s $(MYSQL_ROOT_PASSWORD) ]; then \
		echo "MySQL root password file not found or empty. Exiting..."; \
		exit 1; \
	fi
	@if [ ! -f $(MYSQL_USER_PASSWORD) ] || [ ! -s $(MYSQL_USER_PASSWORD) ]; then \
		echo "MySQL user password file not found or empty. Exiting..."; \
		exit 1; \
	fi
	@echo "Using local files for development."

# Build and run the docker compose dev file 
local: check_files
	@echo "Running in development mode..."
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d


droplet:
	@echo "Deploying the entire application to the droplet..."
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d
