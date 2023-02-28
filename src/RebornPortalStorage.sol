// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract RebornPortalStorage is IRebornDefination {
    // percentage base of refer reward fees
    uint256 public constant PERCENTAGE_BASE = 10000;
    /** Abandoned variable, for slot placeholder*/
    uint256 private abandonedSoupPrice = 0.01 * 1 ether;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint32) public rounds;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => Pool) public pools;

    mapping(address => mapping(uint256 => Portfolio)) public portfolios;

    mapping(address => address) public referrals;

    RewardVault public vault;

    BitMapsUpgradeable.BitMap internal _seeds;

    uint256 public idx;

    // WARN: data residual exists
    // BitMapsUpgradeable.BitMap baptism;
    uint256 private _placeholder;

    ReferrerRewardFees public rewardFees;

    /// @dev gap for potential vairable
    uint256[37] private _gap;
}
