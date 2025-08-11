# Clean validator data directories
clear-data:
	@echo "Cleaning validator data directories..."
	rm -rf ./besu-qbft-docker/data/validator{1,2,3,4}/*
	rm -rf ./blockscout/services/blockscout-db-data/* 
	rm -rf ./blockscout/services/redis-db-data/* 
	rm -rf ./blockscout/services/logs/* 
	rm -rf ./blockscout/services/redis-data/* 
	rm -rf ./blockscout/services/stats-db-data/* 
	@echo "Validator data directories cleaned successfully"

# Hello world
hello-world:
	@echo "Hello, World!"

# Start all services
start:
	cd besu-qbft-docker && docker-compose up -d
	cd blockscout && docker-compose up -d

# Stop all services
stop:
	cd blockscout && docker-compose down
	cd besu-qbft-docker && docker-compose down

# Execute all tasks
all: hello-world clean-data
	@echo "All tasks completed!"
