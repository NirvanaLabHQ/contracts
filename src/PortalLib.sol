// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";
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

    event ClaimRebornDrop(uint256 indexed tokenId, uint256 rebornAmount);
    event ClaimNativeDrop(uint256 indexed tokenId, uint256 nativeAmount);
    event NewDropConf(AirdropConf conf);

    function _claimPoolRebornDrop(
        uint256 tokenId,
        RewardVault vault,
        mapping(uint256 => Pool) storage pools,
        mapping(address => mapping(uint256 => Portfolio)) storage portfolios
    ) external {
        Pool storage pool = pools[tokenId];
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];

        uint256 pendingReborn = (portfolio.accumulativeAmount *
            pool.accRebornPerShare) /
            PERSHARE_BASE -
            portfolio.rebornRewardDebt;

        // set current amount as debt

        portfolio.rebornRewardDebt =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE;

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

        uint256 pendingNative = (portfolio.accumulativeAmount *
            pool.accNativePerShare) /
            PERSHARE_BASE -
            portfolio.nativeRewardDebt;

        // set current amount as debt
        portfolio.nativeRewardDebt =
            (portfolio.accumulativeAmount * pool.accNativePerShare) /
            PERSHARE_BASE;
        portfolio.rebornRewardDebt =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE;

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

        pendingNative =
            (portfolio.accumulativeAmount * pool.accNativePerShare) /
            PERSHARE_BASE -
            portfolio.nativeRewardDebt;

        pendingReborn =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE -
            portfolio.rebornRewardDebt;
    }

    function _dropNativeTokenIds(
        uint256[] memory tokenIds,
        AirdropConf storage _dropConf,
        mapping(uint256 => Pool) storage pools
    ) external {
        bool dropNative = block.timestamp >
            _dropConf._nativeDropLastUpdate + _dropConf._nativeDropInterval;
        if (dropNative) {
            for (uint256 i = 0; i < 100; i++) {
                // if tokenId is zero, continue
                if (tokenIds[i] == 0) {
                    return;
                }
                PortalLib.Pool storage pool = pools[tokenIds[i]];

                pool.accNativePerShare +=
                    (((_dropConf._nativeDropRatio * address(this).balance * 3) /
                        200) * PortalLib.PERSHARE_BASE) /
                    PERCENTAGE_BASE /
                    pool.totalAmount;
            }
            // set last drop timestamp to specific hour
            _dropConf._nativeDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );
        }
    }

    function _dropRebornTokenIds(
        uint256[] memory tokenIds,
        AirdropConf storage _dropConf,
        mapping(uint256 => Pool) storage pools
    ) external {
        bool dropReborn = block.timestamp >
            _dropConf._rebornDropLastUpdate + _dropConf._rebornDropInterval;
        if (dropReborn) {
            for (uint256 i = 0; i < 100; i++) {
                // if tokenId is zero, continue
                if (tokenIds[i] == 0) {
                    return;
                }
                PortalLib.Pool storage pool = pools[tokenIds[i]];

                pool.accRebornPerShare +=
                    (_dropConf._rebornDropEthAmount *
                        1 ether *
                        PortalLib.PERSHARE_BASE) /
                    pool.totalAmount;
            }
            // set last drop timestamp to specific hour
            _dropConf._rebornDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );
        }
    }

    function _toLastHour(uint256 timestamp) internal pure returns (uint256) {
        return timestamp - (timestamp % (1 hours));
    }
}
