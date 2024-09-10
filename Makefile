.PHONY: nginx local droplet check_files



# Check if Docker secrets exist (for both development and production)
check_secrets:
	@echo "Checking if Docker secrets are set..."
	@if ! docker secret ls | grep -q 'mysql_root_password'; then \
		echo "Error: Docker secret mysql_root_password not found."; \
		exit 1; \
	fi
	@if ! docker secret ls | grep -q 'mysql_user_password'; then \
		echo "Error: Docker secret mysql_user_password not found."; \
		exit 1; \
	fi
	@echo "Docker secrets are set."



# Build and run the docker compose dev file 
local: check_secrets
	@echo "Running in development mode..."
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d


droplet: check_secrets
	@echo "Deploying the entire application to the droplet..."
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d
