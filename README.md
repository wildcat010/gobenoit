## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# GBN Mining System (Minimal GoMining-style)

## 🧠 Overview

GBN is an ERC-20 token used as the internal currency of a mining simulation system.

Users burn GBN to acquire "miners", which generate rewards over time.

The system uses dynamic rewards and fees to maintain economic balance.

---

## ⚙️ Core Mechanics

### 1. Buying Miners

- Cost: 100 GBN
- Tokens are burned
- User gains 1 miner

---

### 2. Rewards

Each miner generates rewards continuously:

- Base reward: 2 GBN/day
- Reward decreases as total supply increases

Formula:
reward = baseReward / (1 + supplyFactor)

---

### 3. Maintenance Fees

Each miner pays a daily fee:

- Base fee: 1 GBN/day
- Fee increases as total supply increases

Formula:
fee = baseFee + growthFactor

---

### 4. Claiming

When claiming rewards:

- Net = reward - fee
- Net tokens are minted to user
- Fee is burned

---

## 🔁 Token Flow

- BUY → burn GBN
- CLAIM → mint GBN
- FEES → burn GBN

---

## ⚖️ Economic Model

The system self-regulates:

- Early stage:
  - high rewards
  - low fees
  - rapid growth

- Mid stage:
  - rewards decrease
  - fees increase

- Late stage:
  - mint ≈ burn
  - supply stabilizes

---

## 🚫 No Hard Cap

The system does not use a fixed supply.

Instead, supply is dynamically controlled via:

- minting (rewards)
- burning (usage + fees)

---

## 🔐 Security

- Only Miner contract can mint/burn
- Users cannot mint tokens arbitrarily

---

## 🚀 Future Improvements

- Add staking
- Add NFT miners
- Add real yield (ETH / BTC)
- Integrate DEX liquidity

---
