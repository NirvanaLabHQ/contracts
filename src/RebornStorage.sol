// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IRebornPortal} from "src/interfaces/IRebornPortal.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeOwnableUpgradeable} from "@p12/contracts-lib/contracts/access/SafeOwnableUpgradeable.sol";

import {IRebornToken} from "src/interfaces/IRebornToken.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";

import {RBT} from "src/RBT.sol";

contract RebornStorage is IRebornDefination {
    /** you need buy a soup before reborn */
    uint256 public soupPrice = 0.01 * 1 ether;

    /**
     * @dev talent and property price in compact mode
     * @dev |   bytes8  |   bytes8  |   bytes8    |   bytes8    |
     * @dev |talentPrice|talentPoint|PropertyPrice|PropertyPoint|
     * @dev  4 2 0 for talent price   6  4  2  1  0  for property price
     * @dev  5 4 3 for talent point   35 30 25 20 15 for property point
     */
    uint256 internal _priceAndPoint =
        0x00000000004020000000000000504030000000604020100000000231e19140f;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint16) public rounds;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => Pool) public pools;

    mapping(address => mapping(uint256 => Portfolio)) public portfolios;

    /// @dev gap for potential vairable
    uint256[42] private _gap;
}
