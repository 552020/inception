.PHONY: local droplet 

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

# General up rule
up: check_files
	@echo "Starting the application..."
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d
# General down rule
down:
	@echo "Stopping and removing containers..."
	docker compose -f ./srcs/docker-compose.dev.yml down
