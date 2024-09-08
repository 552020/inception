.PHONY: hello nginx deploy dev

# Simple hello target for testing
hello:
	@echo "Hello from the Makefile"

# Build and run NGINX container in development mode
dev:
	@echo "Running NGINX in development mode..."
	docker-compose -f docker-compose.dev.yml up --build -d nginx

# Build and run the entire application in production mode
# deploy:
# 	@echo "Deploying the entire application..."
# 	docker-compose up --build -d
