.PHONY: hello nginx deploy dev

# Simple hello target for testing
hello:
	@echo "Hello from the Makefile"



# Build and run NGINX container in development mode
# Build and run NGINX container in development mode
dev:
	@echo "Setting up environment variables from secrets..."
	DB_PASSWORD=$$(cat ./secrets/db_password.txt) \
	WP_ADMIN_PASSWORD=$$(cat ./secrets/wp_admin_password.txt) \
	WP_USER_PASSWORD=$$(cat ./secrets/wp_user_password.txt) \
	docker compose -f ./srcs/docker-compose.dev.yml up --build -d


# Build and run the entire application in production mode
# deploy:
# 	@echo "Deploying the entire application..."
# 	docker-compose up --build -d
