// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {RewardVault} from "src/RewardVault.sol";

library PortalLib {
    uint256 public constant PERSHARE_BASE = 10e18;
    // percentage base of refer reward fees
    uint256 public constant PERCENTAGE_BASE = 10000;

    struct Pool {
        uint256 totalAmount;
        uint256 accRebornPerShare;
        uint256 accNativePerShare;
        uint256 epoch;
        uint256 lastUpdated;
    }

    struct Portfolio {
        uint256 accumulativeAmount;
        uint256 rebornRewardDebt;
        uint256 nativeRewardDebt;
        //
        // We do some fancy math here. Basically, any point in time, the amount
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (Amount * pool.accPerShare) - user.rewardDebt
        //
        // Whenever a user infuse or switchPool. Here's what happens:
        //   1. The pool's `accPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.

        /// @dev reward for holding the NFT when the NFT is selected
        uint256 pendingOwnerRebornReward;
        uint256 pendingOwernNativeReward;
    }

    struct AirdropConf {
        uint8 _dropOn; //                  ---
        uint40 _rebornDropInterval; //        |
        uint40 _nativeDropInterval; //        |
        uint40 _rebornDropLastUpdate; //      |
        uint40 _nativeDropLastUpdate; //      |
        uint16 _nativeDropRatio; //           |
        uint72 _rebornDropEthAmount; //    ---
    }

    struct VrfConf {
        bytes32 keyHash;
        uint64 s_subscriptionId;
        uint32 callbackGasLimit;
        uint32 numWords;
        uint16 requestConfirmations;
    }

    event ClaimRebornDrop(uint256 indexed tokenId, uint256 rebornAmount);
    event ClaimNativeDrop(uint256 indexed tokenId, uint256 nativeAmount);
    event NewDropConf(AirdropConf conf);
    event NewVrfConf(VrfConf conf);


    function _claimPoolRebornDrop(
        uint256 tokenId,
        RewardVault vault,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external {
        Pool storage pool = pools[tokenId];
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];

        if (portfolio.accumulativeAmount == 0) {
            return;
        }

        uint256 pendingReborn = (portfolio.accumulativeAmount *
            pool.accRebornPerShare) /
            PERSHARE_BASE -
            portfolio.rebornRewardDebt +
            portfolio.pendingOwnerRebornReward;

        // set current amount as debt
        portfolio.rebornRewardDebt =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE;

        // clean up reward as owner
        portfolio.pendingOwnerRebornReward = 0;

        /// @dev send drop
        if (pendingReborn != 0) {
            vault.reward(msg.sender, pendingReborn);
        }

        emit ClaimRebornDrop(tokenId, pendingReborn);
    }

    function _claimPoolNativeDrop(
        uint256 tokenId,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external {
        Pool storage pool = pools[tokenId];
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];

        if (portfolio.accumulativeAmount == 0) {
            return;
        }

        uint256 pendingNative = (portfolio.accumulativeAmount *
            pool.accNativePerShare) /
            PERSHARE_BASE -
            portfolio.nativeRewardDebt +
            portfolio.pendingOwernNativeReward;

        // set current amount as debt
        portfolio.nativeRewardDebt =
            (portfolio.accumulativeAmount * pool.accNativePerShare) /
            PERSHARE_BASE;

        // clean up reward as owner
        portfolio.pendingOwernNativeReward = 0;

        /// @dev send drop
        if (pendingNative != 0) {
            payable(msg.sender).transfer(pendingNative);

            emit ClaimNativeDrop(tokenId, pendingNative);
        }
    }

    /**
     * @dev calculate drop from a pool
     */
    function _calculatePoolDrop(
        uint256 tokenId,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external view returns (uint256 pendingNative, uint256 pendingReborn) {
        Pool storage pool = pools[tokenId];
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];

        // if no portfolio, no pending reward
        if (portfolio.accumulativeAmount == 0) {
            return (pendingNative, pendingReborn);
        }

        pendingNative =
            (portfolio.accumulativeAmount * pool.accNativePerShare) /
            PERSHARE_BASE -
            portfolio.nativeRewardDebt +
            portfolio.pendingOwernNativeReward;

        pendingReborn =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE -
            portfolio.rebornRewardDebt +
            portfolio.pendingOwnerRebornReward;
    }

    function _dropNativeTokenIds(
        uint256[] memory tokenIds,
        AirdropConf storage _dropConf,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external {
        bool dropNative = block.timestamp >
            _dropConf._nativeDropLastUpdate + _dropConf._nativeDropInterval;
        if (dropNative) {
            // set last drop timestamp to specific hour
            _dropConf._nativeDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );

            for (uint256 i = 0; i < 100; i++) {
                uint256 tokenId = tokenIds[i];
                // if tokenId is zero , return
                if (tokenId == 0) {
                    return;
                }

                Pool storage pool = pools[tokenId];

                // if no one tribute, return
                // as it's loof from high tvl to low tvl
                if (pool.totalAmount == 0) {
                    return;
                }

                uint256 dropAmount = (_dropConf._nativeDropRatio *
                    address(this).balance) / PortalLib.PERCENTAGE_BASE;

                // 85% to pool
                pool.accNativePerShare +=
                    (((dropAmount * 85) / 100) * PortalLib.PERSHARE_BASE) /
                    PERCENTAGE_BASE /
                    pool.totalAmount;

                // 15% to owner
                address owner = IERC721(address(this)).ownerOf(tokenId);
                Portfolio storage portfolio = portfolios[owner][tokenId];
                portfolio.pendingOwernNativeReward += (dropAmount * 15) / 100;
            }
        }
    }

    function _dropRebornTokenIds(
        uint256[] memory tokenIds,
        AirdropConf storage _dropConf,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external {
        bool dropReborn = block.timestamp >
            _dropConf._rebornDropLastUpdate + _dropConf._rebornDropInterval;
        if (dropReborn) {
            // set last drop timestamp to specific hour
            _dropConf._rebornDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );

            for (uint256 i = 0; i < 100; i++) {
                uint256 tokenId = tokenIds[i];
                // if tokenId is zero, continue
                if (tokenId == 0) {
                    return;
                }
                Pool storage pool = pools[tokenId];

                // if no one tribute, continue
                // as it's loof from high tvl to low tvl
                if (pool.totalAmount == 0) {
                    return;
                }

                uint256 dropAmount = _dropConf._rebornDropEthAmount * 1 ether;

                // 85% to pool
                pool.accRebornPerShare +=
                    (((dropAmount * 85) / 100) * PortalLib.PERSHARE_BASE) /
                    pool.totalAmount;

                // 15% to owner
                address owner = IERC721(address(this)).ownerOf(tokenId);
                Portfolio storage portfolio = portfolios[owner][tokenId];
                portfolio.pendingOwnerRebornReward += (dropAmount * 15) / 100;
            }
        }
    }

    function _toLastHour(uint256 timestamp) internal pure returns (uint256) {
        return timestamp - (timestamp % (1 hours));
    }
}
