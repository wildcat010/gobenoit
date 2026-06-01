# GoBenoit

GoBenoit is a blockchain mining simulation stack built with:

Upgradeable Solidity smart contracts (Foundry + OpenZeppelin UUPS proxies)
ERC20 + ERC1155 hybrid token economy
NestJS backend API (viem integration)
JWT authentication + MongoDB user system

It simulates a token-powered mining game economy where users:

Buy ERC20 tokens (GBN)
Use tokens to buy ERC1155 miners
Earn rewards over time based on mining power
Claim emissions + fees dynamically

---

# ⚙️ Current Deployment (Sepolia)

const GBN_TOKEN_ADDRESS = "0x...";
const MINER_1155_ADDRESS = "0x...";
const MINER_MANAGER_ADDRESS = "0x...";

⚠️ These addresses must always match the latest deployment script output.

---

# 📁 Project Architecture

Smart Contracts (src/)

🪙 GBNToken.sol (ERC20)

Upgradeable ERC20 token:

Name: GoBenoit (GBN)
Used as in-game currency
Mint/burn restricted to MinerManager
Pause/unpause support

---

⛏ Miner1155.sol (ERC1155)

Upgradeable ERC1155 contract representing mining hardware NFTs

Key Features:
ERC1155 multi-token standard
Each token ID = different miner type
Supports batch minting and scalable mining assets
Fully controlled by MinerManager
Stores miner metadata such as power per type

Miner Types Example:
Miner ID Power Description
1 Low Starter miner
2 Medium Balanced miner
3 High Advanced miner

Core Logic:
Users do NOT mint directly
Only MinerManager can mint/burn miners
Each miner increases user mining power in reward system

---

🧠 MinerManager.sol (Core Game Engine)

Upgradeable controller contract that manages:

Token Economy
ERC20 (GBN) interactions
Token purchase via ETH (buyTokens)
Burning tokens for miner purchases

Mining System
Tracks user mining power
Index-based reward calculation
Time-dependent emission system

Reward System
Rewards accrue per miner over time
Users call claim() to mint rewards

Fee System
Fees are generated alongside rewards
Split:
50% treasury
50% burned (deflationary mechanic)

---

# 🔗 Contract Interaction Model

System Flow

User
↓ buys ETH
MinerManager.buyTokens()
↓ mints ERC20 (GBN)

User
↓ spends GBN
MinerManager.buyMiner()
↓ burns ERC20
Miner1155.mintMiner()

User
↓ time passes
MinerManager.claim()
↓ mints rewards (ERC20)

---

# 🪙 Token Model (ERC20 + ERC1155 Hybrid)

ERC20 (GBN)

Used for:
Purchasing miners
Reward payouts
Fee accounting

ERC1155 (Miner NFTs)

Used for:
Representing mining hardware
Defining mining power per asset
Scaling multiple miner types efficiently

---

# 📊 Reward Formula

s = totalSupply / 1000 GBN

R = (2 \* 1000) / (1000 + s)

F = 1 + s / 10

---

# 🧪 Testing

forge build
forge test
forge fmt

---

# 🚀 Local Deployment

anvil

forge script script/Deploy.s.sol:Deploy \
 --rpc-url http://127.0.0.1:8545 \
 --broadcast \
 --private-key <ANVIL_KEY>

---

# 🌐 Sepolia Deployment

SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/KEY
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_KEY

forge script script/Deploy.s.sol:Deploy \
 --rpc-url $SEPOLIA_RPC_URL \
 --private-key $PRIVATE_KEY \
 --broadcast \
 --verify -vvv

---

# 🔍 Contract Verification

GBNToken
forge verify-contract <TOKEN_PROXY> src/GBNToken.sol:GBNToken \
 --chain-id 11155111 \
 --etherscan-api-key $ETHERSCAN_API_KEY

Miner1155
forge verify-contract <MINER_1155_PROXY> src/Miner1155.sol:Miner1155 \
 --chain-id 11155111 \
 --etherscan-api-key $ETHERSCAN_API_KEY

MinerManager
forge verify-contract <MANAGER_PROXY> src/MinerManager.sol:MinerManager \
 --chain-id 11155111 \
 --etherscan-api-key $ETHERSCAN_API_KEY

---

# 🧠 API (NestJS)

Backend uses viem to interact with contracts.

Modules:
users: auth + registration
miner: buy miners, claim rewards, pending rewards
token: balance, total supply, pause
blockchain: RPC + wallet config

---

# 🔐 API Security Note

⚠️ Current demo design:

Private keys can be passed to backend
Backend signs transactions

❌ Not production safe

✔ Recommended production upgrade:

Wallet signing (MetaMask / WalletConnect)
Or secure signer service (HSM / backend vault)

---

# 🔄 Upgrade System (UUPS)

All contracts are upgradeable:

GBNToken → ERC20 logic upgrades
Miner1155 → miner logic upgrades
MinerManager → game logic upgrades

Upgrade flow:

Proxy → Implementation → upgradeToAndCall()

---

# ⚠️ Important Notes

Always use proxy addresses, not implementation addresses
ERC1155 miners = gameplay assets
ERC20 = economy layer
MinerManager = single source of truth

---

# 🧩 Summary

GoBenoit is a hybrid system combining:

ERC20 (currency layer)
ERC1155 (asset/miner layer)
Upgradeable architecture (UUPS)
Time-based reward emission system
Game-like mining economy
