# Block Launcher - Blockchain Development Environment

A complete blockchain development environment featuring **Hyperledger Besu** with QBFT consensus and **Blockscout** blockchain explorer. This project provides everything you need to get started with blockchain development in a local environment.

## 🚀 What's Included

- **Hyperledger Besu**: Enterprise-grade Ethereum client with QBFT consensus
- **4 Validator Nodes**: Complete validator network for testing and development
- **Blockscout**: Full-featured blockchain explorer and analytics platform
- **Docker Compose**: Easy setup and management of all services
- **Makefile**: Simple commands for common operations

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker**: [Install Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Docker Compose**: Usually included with Docker Desktop
- **Make**: Available on macOS/Linux by default, [install on Windows](https://chocolatey.org/packages/make)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Validator 1   │    │   Validator 2   │    │   Validator 3   │
│   Port: 8545    │    │   Port: 8546    │    │   Port: 8547    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Validator 4   │
                    │   Port: 8548    │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Blockscout    │
                    │   Port: 80      │
                    └─────────────────┘
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/vanascimento/besu-development-environment
cd besu-development-environment
```

### 2. Start All Services

```bash
make start
```

This command will:

- Start 4 Besu validator nodes
- Launch Blockscout blockchain explorer
- Create the `besu_local_network` Docker network

### 3. Access Your Blockchain

- **Validator 1**: http://localhost:8545
- **Validator 2**: http://localhost:8546
- **Validator 3**: http://localhost:8547
- **Validator 4**: http://localhost:8548
- **Blockscout**: http://localhost:80

## 🛠️ Available Commands

### Service Management

```bash
# Start all services
make start

# Stop all services
make stop

# Restart all services
make stop && make start
```

### Data Management

```bash
# Clear all blockchain and database data
make clear-data

# This removes:
# - Besu validator data
# - Blockscout database data
# - Redis data
# - Log files
# - Stats database data
```

### Utility Commands

```bash
# Execute all tasks (clear data)
make all
```

## 🔧 Configuration Details

### Besu Validators

Each validator runs with:

- **Consensus**: QBFT (Quorum Byzantine Fault Tolerance)
- **Network**: Custom subnet `10.42.0.0/16`
- **Ports**: Unique ports for each validator (8545-8548)
- **Data**: Persistent storage in `./besu-qbft-docker/data/`

### Blockscout

- **Database**: PostgreSQL with persistent storage
- **Redis**: For caching and session management
- **Frontend**: React-based web interface
- **Backend**: Elixir/Phoenix API server

### Network Configuration

- **Network Name**: `besu_local_network`
- **Subnet**: `10.42.0.0/16`
- **Gateway**: `10.42.0.1`
- **Validator IPs**: `10.42.0.2` to `10.42.0.5`

## 📊 Monitoring and Debugging

### Check Service Status

```bash
# View running containers
docker ps

# Check network configuration
docker network ls | grep besu

# View logs for specific services
cd besu-qbft-docker && docker-compose logs validator1
cd blockscout && docker-compose logs backend
```

### Common Issues and Solutions

#### Port Already in Use

If you encounter port conflicts:

```bash
# Check what's using a port
lsof -i :8545

# Stop conflicting services or modify ports in docker-compose.yml
```

#### Network Issues

```bash
# Recreate the network
make stop
docker network rm besu_local_network
make start
```

#### Data Corruption

```bash
# Clear all data and restart
make clear-data
make start
```

## 🧪 Development Workflow

### 1. Start Development Environment

```bash
make start
```

### 2. Deploy Smart Contracts

Connect to any validator (e.g., localhost:8545) and deploy your contracts.

### 3. Monitor with Blockscout

Visit http://localhost:80 to explore transactions, blocks, and contracts.

### 4. Stop When Done

```bash
make stop
```

### 5. Clean Up (Optional)

```bash
make clear-data
# or
make all
```

## 📁 Project Structure

```
block-launcher/
├── README.md                    # This file
├── Makefile                     # Build and management commands
├── besu-qbft-docker/           # Besu validator network
│   ├── docker-compose.yml      # Besu services configuration
│   ├── genesis.json            # Blockchain genesis configuration
│   ├── common-config.toml      # Besu node configuration
│   └── data/                   # Validator data directories
├── blockscout/                  # Blockchain explorer
│   ├── docker-compose.yml      # Blockscout services
│   ├── services/               # Individual service configs
│   └── envs/                   # Environment configurations
└── firefly/                     # Firefly framework (if used)
```

## 🔒 Security Notes

- This is a **development environment** only
- Validator keys are stored in plain text for development purposes
- Never use these configurations in production
- The network is isolated and not connected to public networks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make start` and `make stop`
5. Submit a pull request

## 📚 Additional Resources

- [Hyperledger Besu Documentation](https://besu.hyperledger.org/)
- [Blockscout Documentation](https://docs.blockscout.com/)
- [QBFT Consensus](https://besu.hyperledger.org/en/stable/HowTo/Configure/Consensus-Protocols/QBFT/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify Docker is running
3. Ensure ports are available
4. Check service logs with `docker-compose logs`
5. Open an issue with detailed error information

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

## 🦊 MetaMask Integration

To connect MetaMask to your local Besu network, follow these steps:

### 1. Open MetaMask

- Install [MetaMask](https://metamask.io/) if you haven't already
- Unlock your wallet

### 2. Add Custom Network

- Click on the network dropdown (usually shows "Ethereum Mainnet")
- Select "Add network" → "Add network manually"

### 3. Network Configuration

Fill in the following details:

**Network Name**: `Besu Local Network`
**New RPC URL**: `http://localhost:8545`
**Chain ID**: `1337`
**Currency Symbol**: `ETH`
**Block Explorer URL**: `http://localhost:80`

### 4. Save and Connect

- Click "Save" to add the network
- Your MetaMask will automatically switch to the new network

### 5. Import Test Accounts (Optional)

You can import the pre-funded validator accounts for testing:

**Validator 1 Account**:

- Private Key: Check `./besu-qbft-docker/keys/validator1/key`
- Address: Check `./besu-qbft-docker/keys/validator1/key.pub`

**Note**: These are development keys only. Never use them in production!

### 6. Verify Connection

- Check that MetaMask shows "Besu Local Network"
- Your account should show 0 ETH initially (unless you import a validator account)
- You can now deploy smart contracts and interact with your local blockchain

---

**Happy Blockchain Development! 🚀**
