// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import {SingleRanking} from "src/lib/SingleRanking.sol";
import {PortalLib} from "src/PortalLib.sol";

contract RebornPortalStorage is IRebornDefination {
    uint256 internal _season;

    RBT public rebornToken;

    mapping(address => bool) public signers;

    mapping(address => uint32) internal rounds;

    uint256 internal idx;

    mapping(uint256 => LifeDetail) public details;

    mapping(uint256 => SeasonData) internal _seasonData;

    mapping(address => address) public referrals;
    ReferrerRewardFees public rewardFees;

    RewardVault public vault;

    BitMapsUpgradeable.BitMap internal _seeds;

    // airdrop config
    PortalLib.AirdropConf internal _dropConf;

    address public burnPool;

    /// @dev gap for potential vairable
    uint256[37] private _gap;
}
