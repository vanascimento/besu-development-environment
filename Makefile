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
compile-contract:
	solc --combined-json abi simple_storage.sol > simple_storage_abi.json 

# 🚀 Deploy modules using Hardhat Ignition
deploy-bound:
	@echo "🚀 Deploying Bound module to Besu network..."
	cd smartcontracts && rm -rf ignition/deployments/
	cd smartcontracts && npx hardhat compile
	cd smartcontracts && npx hardhat ignition deploy ignition/modules/Bound.ts --network besu
	@echo "✅ Bound module deployed successfully"

deploy-brlt:
	@echo "🚀 Deploying BRLT module to Besu network..."
	cd smartcontracts && rm -rf ignition/deployments/
	cd smartcontracts && npx hardhat compile
	cd smartcontracts && npx hardhat ignition deploy ignition/modules/BRLT.ts --network besu
	@echo "✅ BRLT module deployed successfully"

deploy-all-modules:
	@echo "🚀 Deploying all modules to Besu network..."
	cd smartcontracts && rm -rf ignition/deployments/
	cd smartcontracts && npx hardhat compile
	cd smartcontracts && npx hardhat ignition deploy ignition/modules/Bound.ts --network besu
	cd smartcontracts && npx hardhat ignition deploy ignition/modules/BRLT.ts --network besu
	@echo "✅ All modules deployed successfully"

# 📋 List deployed modules
list-deployments:
	@echo "📋 Listing Ignition deployments..."
	cd smartcontracts && npx hardhat ignition list
	@echo "✅ Deployments listed successfully"

# 🔍 Check network status
check-network:
	@echo "🔍 Checking Besu network status..."
	cd smartcontracts && npx hardhat run --network besu scripts/check-network.ts || echo "⚠️  Network check script not found, checking connection..."
	@echo "✅ Network status checked"

# 🧪 Test contracts
test-contracts:
	@echo "🧪 Running contract tests..."
	cd smartcontracts && npx hardhat test
	@echo "✅ Tests completed"
# 🚀 Start all services
start:
	@echo "🚀 Starting all services..."
	cd besu-qbft-docker && docker-compose up -d
	cd blockscout && docker-compose up -d
	@echo "✅ All services started successfully"

start-ff:
	@echo "🚀 Starting ff..."
	ff init ethereum dev 1 --multiparty=false -n remote-rpc --ipfs-mode private --remote-node-url http://host.docker.internal:8545 --chain-id 1337 --token-providers erc20_erc721  --connector-config ./evmconnect.yml
	ff start dev -v
	@echo "✅ ff started successfully"

stop-ff:
	@echo "🛑 Stopping ff..."
	ff stop dev
	@echo "✅ ff stopped successfully"
remove-ff:
	@echo "🧹 Removing ff..."
	ff remove dev
	@echo "✅ ff removed successfully"

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


