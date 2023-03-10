// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IDegenERC721Upgradeable is IERC721Upgradeable {
    enum Rarity {
        Legendary,
        Epic,
        Rare,
        Uncommon,
        Common
    }

    enum TokenType {
        Standard,
        Shard
    }

    struct Properties {
        string name;
        Rarity rarity;
        TokenType tokenType;
    }

    event SetProperties(Properties properties);
}
