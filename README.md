# <h1 align="center"> Degen Reborn Contract </h1>

<!-- **Template repository for getting started quickly with Hardhat and Foundry in one project** -->

![Github Actions](https://github.com/devanonon/hardhat-foundry-template/workflows/test/badge.svg)

### Getting Started

This repo use Foundry to develop and test, use hardhat to deploy and manage.

Install dependencies

```bash
forge install
pnpm install
```

Build and show contract size
```bash
forge build --size
```

Run all test
```bash
forge test
```

Deploy contract
```bash
pnpm run deploy --network <Network>
```

## Intro to contract

### `src/RBT.sol:RBT`
The $REBORN erc20 token, it supports ERC20-permit, Capable, Burnable.

### `src/RebornPortal.sol:RebornPortal`

The portal of the game, entry for user to interact with. An example progress is as following:

1. User call `incarnate` to start the game, user select talent, property and pay ticket in this function. It also record referral and reward to referrer.
2. After a game ends, the signer call `engrave` to record the result on chain, it distribute reward to user, reward to referrer and mint an NFT.
3. User can share the game and get reward by signer calling `baptise` function.
4. User call `infuse` to stake his $REBORN to a certain incarnation and or call `switchPool` to switch stake from one incarnation to another. User would like to stake for hourly airdrop and season jackpot. 
5. User call `claimDrops` to claim hourly airdrop. Each time he/she call `infuse` or `switchPool`, airdrop of the specific incarnation will be auto claimed.

### `src/RewardVault:RewardVault`

A vault contract for reward.

### `src/RewardDistributor:RewardDistributor`

Use merkle tree to distribute season jackpot.

## mechanism

### Hourly airdrop

Hourly airdrop needs on-chain rank and chainlink automation. The incarnation with top 100 TVL will be airdropped with a certain amount of $REBORN and a ratio of jackpot native token. We maintain a dynamic red black tree to keep the on-chain rank up-to-date. And chainlink automation is responsible for add reward to specific incarnation on time.

### Season Jackpot

Season Jackpot is distributed to 10 of top 100 score incarnation. The rank is currently off-chain and winner will be public and use a merkle tree(RewardDistributor) to distribute.

## Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
