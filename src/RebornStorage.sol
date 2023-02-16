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
     * @dev talent price in compact mode
     */
    uint256 internal _talentPrice =
        0x00000000000000000000000000000000000000000000004b02bc21c12c0a0000;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint16) public rounds;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => Pool) public pools;

    mapping(address => mapping(uint256 => Portfolio)) public portfolios;

    mapping(address => address) public referrals;

    /// @dev gap for potential vairable
    uint256[41] private _gap;
}
