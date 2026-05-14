# GoBenoit

GoBenoit is a demo mining, stack with:

- Upgradeable Solidity contracts (Foundry + OpenZeppelin UUPS proxies)
- A NestJS API that interacts with those contracts through viem
- JWT auth and MongoDB-backed users

## Project Structure

- `src/`
  - `GBNToken.sol`: upgradeable ERC20 token (`GoBenoit`, `GBN`) with pause and restricted mint/burn
  - `MinerManager.sol`: miner purchase, reward accrual, fee handling, claim logic, token sale (`buyTokens`)
- `script/Deploy.s.sol`: deploys `GBNToken` and `MinerManager` behind `ERC1967Proxy` and links them
- `test/`: Foundry tests for token and miner behavior
- `gobenoit-api/`: NestJS backend
  - `users`: register/login and user lookup
  - `miner`: buy tokens, buy miner, claim, pending reward, pause/unpause
  - `token`: total supply and pause/unpause
  - `blockchain`: viem public/wallet clients targeting local Anvil RPC

## How It Works

### Token (`GBNToken`)

- Standard ERC20 (upgradeable)
- Only `minerContract` can call `mint` and `burnFrom`
- Transfers/mint/burn are blocked while paused

### Miner Manager (`MinerManager`)

- Miner cost: `100 GBN` each
- `buyTokens()` mints GBN based on `rate` (default 1000 GBN per 1 ETH)
- `buyMiner(quantity)` burns user GBN and increases miner count
- Rewards and fees are index-based and time-dependent
- `claim()` mints rewards to user, splits fees into:
  - 50% to treasury
  - 50% minted then burned

## Reward and Fee Model

Given normalized supply:

$$s = \frac{\text{totalSupply}}{1000\ \text{GBN}}$$

Reward/day per miner:

$$R = \frac{2\ \text{GBN} \cdot 1000}{1000 + s}$$

Fee/day per miner:

$$F = 1\ \text{GBN} + \frac{s}{10}\ \text{GBN}$$

As supply rises, reward decreases and fee increases.

## Prerequisites

- Foundry installed
- Node.js 18+
- MongoDB running

## Run Contracts Locally

1. Start Anvil:

```bash
anvil
```

2. Build contracts:

```bash
forge build
```

3. Run tests:

```bash
forge test
```

4. Deploy proxies with script:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --private-key <ANVIL_PRIVATE_KEY>
```

The deploy script logs proxy addresses for `GBNToken` and `MinerManager`.

## Deploy to Sepolia

1. Add environment variables in root `.env`:

```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=0xYOUR_WALLET_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_KEY
```

2. Make sure deployer wallet has Sepolia ETH (from a faucet).

3. Deploy to Sepolia:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url sepolia \
  --broadcast
```

4. Verify contracts (optional but recommended):

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url sepolia \
  --broadcast \
  --verify
```

5. Copy deployed proxy addresses from script logs.

6. Update hardcoded addresses in API to the Sepolia proxies:

- `gobenoit-api/src/miner/miner.controller.ts` (`MINER_MANAGER_ADDRESS`)
- `gobenoit-api/src/miner/miner.service.ts` (`MINER_MANAGER_ADDRESS`, `GBN_TOKEN_ADDRESS`)
- `gobenoit-api/src/token/token.controller.ts` (`GBN_TOKEN_ADDRESS`)
- `gobenoit-api/src/token/token.service.ts` (`GBN_TOKEN_ADDRESS`)

7. If you also want the API to read/write Sepolia instead of local Anvil, switch chain and RPC in `gobenoit-api/src/blockchain/blockchain.service.ts`.

## Run NestJS API

Inside `gobenoit-api/`:

1. Install dependencies:

```bash
npm install
```

2. Create `.env` (example):

```env
PORT=3000
MONGO_URI=mongodb://127.0.0.1:27017/gobenoit
JWT_SECRET=replace_with_a_strong_secret
```

3. Start API:

```bash
npm run start:dev
```

## API Overview

Base URL: `http://localhost:3000`

Public routes:

- `POST /users/register`
- `POST /users/login`

JWT-protected routes (send `Authorization: Bearer <token>`):

- `GET /users/getUserByEmail?email=...`
- `GET /users/getAll`
- `POST /miner/buy-tokens`
- `GET /miner/getBalanceof?address=0x...`
- `POST /miner/buy-miner`
- `POST /miner/claim-reward`
- `POST /miner/pending-reward`
- `POST /miner/pause`
- `GET /token/total-supply`
- `POST /token/pause`

## Important Notes

- This project is for demo/testing purposes.
- Some API endpoints accept a raw private key in the request body so the backend can sign on behalf of a wallet.
- This pattern is not production-safe and should not be used in real systems.
- For production, move signing to the client wallet (MetaMask, WalletConnect, hardware wallets) or a dedicated secure signer service/HSM.

## Address Configuration

`gobenoit-api` currently uses hardcoded contract addresses in services/controllers.

After redeploying contracts, update these addresses to match your latest deployment.

## Useful Commands

Root (Foundry):

```bash
forge build
forge test
forge fmt
```

API (`gobenoit-api/`):

```bash
npm run start:dev
npm run build
npm run test
```
