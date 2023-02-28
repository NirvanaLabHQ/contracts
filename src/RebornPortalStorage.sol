// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract RebornPortalStorage is IRebornDefination {
    // percentage base of refer reward fees
    uint256 internal constant PERCENTAGE_BASE = 10000;
    uint256 internal constant PERSHARE_BASE = 10e18;
    /** Abandoned variable, for slot placeholder*/
    uint256 internal _jackPot;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint32) internal rounds;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => Pool) internal pools;

    /// @dev user address => pool tokenId => Portfolio
    mapping(address => mapping(uint256 => Portfolio)) internal portfolios;

    mapping(address => address) public referrals;

    RewardVault public vault;

    BitMapsUpgradeable.BitMap internal _seeds;

    uint256 internal idx;

    // WARN: data residual exists
    // BitMapsUpgradeable.BitMap baptism;
    uint256 private _placeholder;

    ReferrerRewardFees public rewardFees;

    // airdrop config
    AirdropConf internal _dropConf;

    /// @dev gap for potential vairable
    uint256[36] private _gap;
}
