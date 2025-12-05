PWD_DIR := $(shell pwd)
ARCH := $(shell uname -m)


# 构建eth2-val-tools
eth2_val_tools:
	@echo "Init git submodule"
	@git submodule update --init --recursive
	@echo "Build eth2-val-tools, target path: tools/bin/eth2-val-tools"
	@cd tools/eth2-val-tools && go build -o ../bin/eth2-val-tools

# 定义目标：生成新的密钥
reset_validator_keys:
	@echo "Removing old validator-keys directory"
	@rm -rf genesis_data/validator-keys

	@echo "Generating new validator keys"
	@cd genesis_data && ./reset_validator_keys.sh

# 生成genesis_data
generate_genesis_data:
	@echo "Generate genesis-data"
	@cd genesis_data && ./generate_genesis_data.sh

# 初始化geth的创世信息
init_geth_genesis:
	@echo "Init geth gensis"
	@docker run --rm -it \
	-v $(PWD_DIR)/data/execution-data:/execution-data \
	-v $(PWD_DIR)/genesis_data/el-cl-genesis-data:/el-cl-genesis-data \
	ethereum/client-go:v1.13.14 \
	--datadir=/execution-data \
	init /el-cl-genesis-data/network-configs/genesis.json

# 停止并删除容器和数据
down_and_clean:
	@echo "Down container and clean data"
	@echo "Composer down"
	@docker compose down
	@echo ""

	@echo "Delete el-cl-genesis data..."
	sudo rm -rf genesis_data/el-cl-genesis-data

	@echo "Delete validator data..."
	sudo rm -rf genesis_data/validator-keys/keys/logs
	sudo rm -rf genesis_data/validator-keys/keys/.secp-sk
	sudo rm -rf genesis_data/validator-keys/keys/api-token.txt
	sudo rm -rf genesis_data/validator-keys/keys/slashing_protection.sqlite
	sudo rm -rf genesis_data/validator-keys/keys/slashing_protection.sqlite-journal
	sudo rm -rf genesis_data/validator-keys/keys/validator_definitions.yml
	sudo rm -rf genesis_data/validator-keys/keys/validator_key_cache.json
	@echo ""

	@echo "Delete geth data..."
	sudo rm -rf data/consensus-data
	@echo ""

	@echo "Delete lighthouse data..."
	sudo rm -rf data/execution-data

	@echo "Delete blocksout data"
	rm -rf data/blockscout-data

	@echo "Delete el-cl-genesis-data"
	sudo rm -rf genesis_data/el-cl-genesis-data
	@echo ""

	rm -rf data

first_start_with_explorer:
	@docker compose -f docker-compose-explorer.yaml up -d

stop_with_explorer:
	@docker compose -f docker-compose-explorer.yaml stop

restart_with_explorer:
	@docker compose -f docker-compose-explorer.yaml start

down_and_clean_with_explorer:
	@echo "Down container and clean data"
	@echo "Composer down"
	@docker compose -f docker-compose-explorer.yaml down
	@echo ""

	@echo "Delete validator data..."
	rm -rf genesis_data/validator-keys/keys/logs
	rm -rf genesis_data/validator-keys/keys/.secp-sk
	rm -rf genesis_data/validator-keys/keys/api-token.txt
	rm -rf genesis_data/validator-keys/keys/slashing_protection.sqlite
	rm -rf genesis_data/validator-keys/keys/slashing_protection.sqlite-journal
	rm -rf genesis_data/validator-keys/keys/validator_definitions.yml
	rm -rf genesis_data/validator-keys/keys/validator_key_cache.json
	@echo ""

	@echo "Delete geth data..."
	sudo rm -rf data/consensus-data
	@echo ""

	@echo "Delete lighthouse data..."
	sudo rm -rf data/execution-data

	@echo "Delete blocksout data"
	rm -rf data/blockscout-data

	echo "Delete blobscan data"
	rm -rf ./data/blobscan-data

	@echo "Delete el-cl-genesis-data"
	sudo rm -rf genesis_data/el-cl-genesis-data
	@echo ""

	rm -rf data