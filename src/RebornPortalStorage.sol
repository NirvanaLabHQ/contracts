// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import {SingleRanking} from "src/lib/SingleRanking.sol";
import {PortalLib} from "src/PortalLib.sol";

contract RebornPortalStorage is IRebornDefination {
    /** Abandoned variable, for slot placeholder*/
    uint256 private abandonedSoupPrice;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint32) internal rounds;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => PortalLib.Pool) internal pools;

    /// @dev user address => pool tokenId => Portfolio
    mapping(address => mapping(uint256 => PortalLib.Portfolio))
        internal portfolios;

    mapping(address => address) public referrals;

    RewardVault public vault;

    BitMapsUpgradeable.BitMap internal _seeds;

    uint256 internal idx;

    // WARN: data residual exists
    // BitMapsUpgradeable.BitMap baptism;
    uint256 private _placeholder;

    ReferrerRewardFees public rewardFees;

    // airdrop config
    PortalLib.AirdropConf internal _dropConf;

    SingleRanking.Data internal _tributeRank;
    SingleRanking.Data internal _scoreRank;

    mapping(uint256 => uint256) internal _oldStakeAmounts;

    /// tokenId => bool
    BitMapsUpgradeable.BitMap internal _isTopHundredScore;

    /// @dev gap for potential vairable
    uint256[32] private _gap;
}
