import { ethers } from "hardhat";
const { Wallet } = ethers;

export enum Rarity {
  Legendary,
  Epic,
  Rare,
  Uncommon,
  Common,
}

export enum TokenType {
  Standard,
  Shard,
}

export const metadataList = [
  {
    name: "CZ",
    rarity: Rarity.Legendary,
    tokenType: TokenType.Shard,
  },
  {
    name: "CZ",
    rarity: Rarity.Legendary,
    tokenType: TokenType.Shard,
  },
  {
    name: "SBF",
    rarity: Rarity.Epic,
    tokenType: TokenType.Shard,
  },
  {
    name: "SBF",
    rarity: Rarity.Epic,
    tokenType: TokenType.Shard,
  },
  {
    name: "CZ",
    rarity: Rarity.Legendary,
    tokenType: TokenType.Standard,
  },
  {
    name: "CZ",
    rarity: Rarity.Legendary,
    tokenType: TokenType.Standard,
  },
];

export function generageTestAccount(n: number) {
  const accountList: string[] = [];
  for (let i = 0; i < n; i++) {
    const { address } = Wallet.createRandom();
    accountList.push(address);
  }

  return accountList;
}
