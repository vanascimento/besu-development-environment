# 🗑️ Clean validator data directories
clear-data:
	@echo "🧹 Cleaning validator data directories..."
	rm -rf ./besu-qbft-docker/data/validator{1,2,3,4}/*
	rm -rf ./blockscout/services/blockscout-db-data/* 
	rm -rf ./blockscout/services/redis-db-data/* 
	rm -rf ./blockscout/services/logs/* 
	rm -rf ./blockscout/services/redis-data/* 
	rm -rf ./blockscout/services/stats-db-data/* 
	@echo "✅ Validator data directories cleaned successfully"

# 🚀 Start all services
start:
	@echo "🚀 Starting all services..."
	cd besu-qbft-docker && docker-compose up -d
	cd blockscout && docker-compose up -d
	@echo "✅ All services started successfully"

# 🛑 Stop all services
stop:
	@echo "🛑 Stopping all services..."
	cd blockscout && docker-compose down
	cd besu-qbft-docker && docker-compose down
	@echo "✅ All services stopped successfully"

# 🔄 Restart all services
restart:
	@echo "🔄 Restarting all services..."
	cd blockscout && docker-compose down
	cd besu-qbft-docker && docker-compose down
	cd besu-qbft-docker && docker-compose up -d
	cd blockscout && docker-compose up -d
	@echo "✅ All services restarted successfully"


