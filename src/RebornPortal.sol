// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import {SafeOwnableUpgradeable} from "@p12/contracts-lib/contracts/access/SafeOwnableUpgradeable.sol";
import {IRebornPortal} from "src/interfaces/IRebornPortal.sol";
import {RebornPortalStorage} from "src/RebornPortalStorage.sol";
import {RBT} from "src/RBT.sol";
import {RewardVault} from "src/RewardVault.sol";
import {RankUpgradeable} from "src/RankUpgradeable.sol";
import {Renderer} from "src/lib/Renderder.sol";

contract RebornPortal is
    IRebornPortal,
    SafeOwnableUpgradeable,
    UUPSUpgradeable,
    RebornPortalStorage,
    ERC721Upgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AutomationCompatible,
    RankUpgradeable
{
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    function initialize(
        RBT rebornToken_,
        address owner_,
        string memory name_,
        string memory symbol_
    ) public initializer {
        if (address(rebornToken_) == address(0)) {
            revert ZeroAddressSet();
        }
        rebornToken = rebornToken_;
        __Ownable_init(owner_);
        __ERC721_init(name_, symbol_);
        __ReentrancyGuard_init();
        __Pausable_init();
    }

    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function incarnate(
        Innate memory innate,
        address referrer,
        uint256 _soupPrice
    ) external payable override whenNotPaused nonReentrant {
        _refer(referrer);
        _incarnate(innate, _soupPrice);
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function engrave(
        bytes32 seed,
        address user,
        uint256 reward,
        uint256 score,
        uint256 age,
        uint256 cost
    ) external override onlySigner whenNotPaused {
        if (_seeds.get(uint256(seed))) {
            revert SameSeed();
        }
        _seeds.set(uint256(seed));

        // tokenId auto increment
        uint256 tokenId = ++idx + (block.chainid * 1e18);

        details[tokenId] = LifeDetail(
            seed,
            user,
            uint16(age),
            ++rounds[user],
            0,
            uint128(cost),
            uint128(reward),
            score
        );
        // mint erc721
        _safeMint(user, tokenId);
        // send $REBORN reward
        vault.reward(user, reward);

        // mint to referrer
        _vaultRewardToRefs(user, reward);

        emit Engrave(seed, user, tokenId, score, reward);
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function baptise(
        address user,
        uint256 amount
    ) external override onlySigner whenNotPaused {
        vault.reward(user, amount);

        emit Baptise(user, amount);
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function infuse(
        uint256 tokenId,
        uint256 amount
    ) external override whenNotPaused {
        _claimPoolDrop(tokenId);
        _infuse(tokenId, amount);
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function infuse(
        uint256 tokenId,
        uint256 amount,
        uint256 permitAmount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external override whenNotPaused {
        _claimPoolDrop(tokenId);
        _permit(permitAmount, deadline, r, s, v);
        _infuse(tokenId, amount);
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function switchPool(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) external override whenNotPaused {
        _claimPoolDrop(fromTokenId);
        _claimPoolDrop(toTokenId);
        _decreaseFromPool(fromTokenId, amount);
        _increaseToPool(toTokenId, amount);
    }

    /**
     * @dev user claim many pools' airdrop
     * @param tokenIds pools' tokenId array to claim
     */
    function claimDrops(uint256[] memory tokenIds) external whenNotPaused {
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _claimPoolDrop(tokenIds[i]);
        }
    }

    /**
     * @dev user specific pool's airdrop
     * @param tokenId pool's tokenId to claim
     */
    function claimDrop(uint256 tokenId) external whenNotPaused {
        _claimPoolDrop(tokenId);
    }

    /**
     * @dev Upkeep perform of chainlink automation
     */
    function performUpkeep(
        bytes calldata performData
    ) external override whenNotPaused {
        uint256 t = abi.decode(performData, (uint256));
        if (t == 1) {
            _dropReborn();
        } else if (t == 2) {
            _dropReborn();
        }
    }

    /**
     * @inheritdoc IRebornPortal
     */
    function setDropConf(
        AirdropConf calldata conf
    ) external override onlyOwner {
        _dropConf = conf;
        emit NewDropConf(conf);
    }

    /**
     * @dev set vault
     * @param vault_ new vault address
     */
    function setVault(RewardVault vault_) external onlyOwner {
        vault = vault_;
        emit VaultSet(address(vault_));
    }

    /**
     * @dev withdraw token from vault
     * @param to the address which owner withdraw token to
     */
    function withdrawVault(address to) external onlyOwner {
        vault.withdrawEmergency(to);
    }

    /**
     * @dev update signers
     * @param toAdd list of to be added signer
     * @param toRemove list of to be removed signer
     */
    function updateSigners(
        address[] calldata toAdd,
        address[] calldata toRemove
    ) external onlyOwner {
        for (uint256 i = 0; i < toAdd.length; i++) {
            signers[toAdd[i]] = true;
            emit SignerUpdate(toAdd[i], true);
        }
        for (uint256 i = 0; i < toRemove.length; i++) {
            delete signers[toRemove[i]];
            emit SignerUpdate(toRemove[i], false);
        }
    }

    /**
     * @notice mul 100 when set. eg: 8% -> 800 18%-> 1800
     * @dev set percentage of referrer reward
     * @param rewardType 0: incarnate reward 1: engrave reward
     */
    function setReferrerRewardFee(
        uint16 refL1Fee,
        uint16 refL2Fee,
        RewardType rewardType
    ) external onlyOwner {
        if (rewardType == RewardType.NativeToken) {
            rewardFees.incarnateRef1Fee = refL1Fee;
            rewardFees.incarnateRef2Fee = refL2Fee;
        } else if (rewardType == RewardType.RebornToken) {
            rewardFees.vaultRef1Fee = refL1Fee;
            rewardFees.vaultRef2Fee = refL2Fee;
        }
    }

    /**
     * @dev withdraw native token for reward distribution
     * @dev amount how much to withdraw
     */
    function withdrawNativeToken(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev checkUpkeep for chainlink automation
     */
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        if (_dropConf._dropOn == 1) {
            if (
                block.timestamp >
                _dropConf._rebornDropLastUpdate + _dropConf._rebornDropInterval
            ) {
                upkeepNeeded = true;
                performData = abi.encode(1);
            } else if (
                block.timestamp >
                _dropConf._nativeDropLastUpdate + _dropConf._nativeDropInterval
            ) {
                upkeepNeeded = true;
                performData = abi.encode(2);
            }
        }
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return Renderer.renderByTokenId(details, tokenId);
    }

    /**
     * @dev check whether the seed is used on-chain
     * @param seed random seed in bytes32
     */
    function seedExists(bytes32 seed) external view returns (bool) {
        return _seeds.get(uint256(seed));
    }

    /**
     * @dev run erc20 permit to approve
     */
    function _permit(
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal {
        rebornToken.permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
    }

    function _infuse(uint256 tokenId, uint256 amount) internal {
        // if amount is zero, nothing happen
        if (amount == 0) {
            return;
        }
        // burn reborn token from msg.sender
        rebornToken.burnFrom(msg.sender, amount);

        _increasePool(tokenId, amount);

        emit Infuse(msg.sender, tokenId, amount);
    }

    /**
     * @dev implementation of incarnate
     */
    function _incarnate(Innate memory innate, uint256 _soupPrice) internal {
        uint256 totalFee = _soupPrice +
            innate.talentPrice +
            innate.propertyPrice;
        if (msg.value < totalFee) {
            revert InsufficientAmount();
        }
        // transfer redundant native token back
        payable(msg.sender).transfer(msg.value - totalFee);

        // reward referrers
        _sendRewardToRefs(msg.sender, totalFee);

        emit Incarnate(
            msg.sender,
            innate.talentPrice,
            innate.propertyPrice,
            _soupPrice
        );
    }

    /**
     * @dev record referrer relationship, only one layer
     */
    function _refer(address referrer) internal {
        if (
            referrals[msg.sender] == address(0) &&
            referrer != address(0) &&
            referrer != msg.sender
        ) {
            referrals[msg.sender] = referrer;
            emit Refer(msg.sender, referrer);
        }
    }

    /**
     * @dev airdrop to top 100 tvl pool
     */
    function _dropReborn() internal onlyDropOn {
        uint256[] memory tokenIds = _getTopNTokenId(100);
        bool dropReborn = block.timestamp >
            _dropConf._rebornDropLastUpdate + _dropConf._rebornDropInterval;
        if (dropReborn) {
            for (uint256 i = 0; i < 100; i++) {
                // if tokenId is zero, continue
                if (tokenIds[i] == 0) {
                    return;
                }
                Pool storage pool = pools[tokenIds[i]];

                // if no one tribute, continue
                // as it's loof from high tvl to low tvl
                if (pool.totalAmount == 0) {
                    return;
                }

                pool.accRebornPerShare +=
                    (_dropConf._rebornDropEthAmount * 1 ether * PERSHARE_BASE) /
                    pool.totalAmount;
            }
            // set last drop timestamp to specific hour
            _dropConf._rebornDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );
        }
    }

    /**
     * @dev airdrop to top 100 tvl pool
     */
    function _dropNative() internal onlyDropOn {
        uint256[] memory tokenIds = _getTopNTokenId(100);
        bool dropNative = block.timestamp >
            _dropConf._nativeDropLastUpdate + _dropConf._nativeDropInterval;
        if (dropNative) {
            for (uint256 i = 0; i < 100; i++) {
                // if tokenId is zero, continue
                if (tokenIds[i] == 0) {
                    return;
                }
                Pool storage pool = pools[tokenIds[i]];

                // if no one tribute, continue
                // as it's loof from high tvl to low tvl
                if (pool.totalAmount == 0) {
                    return;
                }

                pool.accNativePerShare +=
                    (((_dropConf._nativeDropRatio * address(this).balance * 3) /
                        200) * PERSHARE_BASE) /
                    PERCENTAGE_BASE /
                    pool.totalAmount;
            }
            // set last drop timestamp to specific hour
            _dropConf._nativeDropLastUpdate = uint40(
                _toLastHour(block.timestamp)
            );
        }
    }

    /**
     * @dev user claim a drop from a pool
     */
    function _claimPoolDrop(uint256 tokenId) internal nonReentrant {
        Pool storage pool = pools[tokenId];
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];

        uint256 pendingNative = (portfolio.accumulativeAmount *
            pool.accNativePerShare) /
            PERSHARE_BASE -
            portfolio.nativeRewardDebt;

        uint256 pendingReborn = (portfolio.accumulativeAmount *
            pool.accRebornPerShare) /
            PERSHARE_BASE -
            portfolio.rebornRewardDebt;

        // set current amount as debt
        portfolio.nativeRewardDebt =
            (portfolio.accumulativeAmount * pool.accNativePerShare) /
            PERSHARE_BASE;
        portfolio.rebornRewardDebt =
            (portfolio.accumulativeAmount * pool.accRebornPerShare) /
            PERSHARE_BASE;

        /// @dev send drop
        if (pendingNative != 0 || pendingReborn != 0) {
            if (pendingNative != 0) {
                payable(msg.sender).transfer(pendingNative);
            }
            if (pendingReborn != 0) {
                vault.reward(msg.sender, pendingReborn);
            }

            emit ClaimDrop(tokenId, pendingReborn, pendingNative);
        }
    }

    function _toLastHour(uint256 timestamp) internal pure returns (uint256) {
        return timestamp - (timestamp % (1 hours));
    }

    /**
     * @dev vault $REBORN token to referrers
     */
    function _vaultRewardToRefs(address account, uint256 amount) internal {
        (
            address ref1,
            uint256 ref1Reward,
            address ref2,
            uint256 ref2Reward
        ) = _calculateReferReward(account, amount, RewardType.RebornToken);

        if (ref1Reward > 0) {
            vault.reward(ref1, ref1Reward);
        }

        if (ref2Reward > 0) {
            vault.reward(ref2, ref2Reward);
        }

        emit ReferReward(
            account,
            ref1,
            ref1Reward,
            ref2,
            ref2Reward,
            RewardType.RebornToken
        );
    }

    /**
     * @dev send NativeToken to referrers
     */
    function _sendRewardToRefs(address account, uint256 amount) internal {
        (
            address ref1,
            uint256 ref1Reward,
            address ref2,
            uint256 ref2Reward
        ) = _calculateReferReward(account, amount, RewardType.NativeToken);

        if (ref1Reward > 0) {
            payable(ref1).transfer(ref1Reward);
        }

        if (ref2Reward > 0) {
            payable(ref2).transfer(ref2Reward);
        }

        emit ReferReward(
            account,
            ref1,
            ref1Reward,
            ref2,
            ref2Reward,
            RewardType.NativeToken
        );
    }

    /**
     * @dev decrease amount from pool of switch from
     */
    function _decreaseFromPool(uint256 tokenId, uint256 amount) internal {
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];
        Pool storage pool = pools[tokenId];

        if (portfolio.accumulativeAmount < amount) {
            revert SwitchAmountExceedBalance();
        }

        portfolio.accumulativeAmount -= amount;
        pool.totalAmount -= amount;

        _enter(tokenId, pool.totalAmount);

        emit DecreaseFromPool(msg.sender, tokenId, amount);
    }

    /**
     * @dev increase amount to pool of switch to
     */
    function _increaseToPool(uint256 tokenId, uint256 amount) internal {
        uint256 burnAmount = (amount * 5) / 100;
        uint256 restakeAmount = amount - burnAmount;

        _increasePool(tokenId, restakeAmount);

        emit IncreaseToPool(msg.sender, tokenId, restakeAmount);
    }

    function _increasePool(uint256 tokenId, uint256 amount) internal {
        Portfolio storage portfolio = portfolios[msg.sender][tokenId];
        portfolio.accumulativeAmount += amount;

        Pool storage pool = pools[tokenId];
        pool.totalAmount += amount;

        _enter(tokenId, pool.totalAmount);

        emit IncreaseToPool(msg.sender, tokenId, amount);
    }

    /**
     * @dev returns referrer and referer reward
     * @return ref1  level1 of referrer. direct referrer
     * @return ref1Reward  level 1 referrer reward
     * @return ref2  level2 of referrer. referrer's referrer
     * @return ref2Reward  level 2 referrer reward
     */
    function _calculateReferReward(
        address account,
        uint256 amount,
        RewardType rewardType
    )
        internal
        view
        returns (
            address ref1,
            uint256 ref1Reward,
            address ref2,
            uint256 ref2Reward
        )
    {
        ref1 = referrals[account];
        ref2 = referrals[ref1];

        if (rewardType == RewardType.NativeToken) {
            ref1Reward = ref1 == address(0)
                ? 0
                : (amount * rewardFees.incarnateRef1Fee) / PERCENTAGE_BASE;
            ref2Reward = ref2 == address(0)
                ? 0
                : (amount * rewardFees.incarnateRef2Fee) / PERCENTAGE_BASE;
        }

        if (rewardType == RewardType.RebornToken) {
            ref1Reward = ref1 == address(0)
                ? 0
                : (amount * rewardFees.vaultRef1Fee) / PERCENTAGE_BASE;
            ref2Reward = ref2 == address(0)
                ? 0
                : (amount * rewardFees.vaultRef2Fee) / PERCENTAGE_BASE;
        }
    }

    /**
     * @dev read pool attribute
     */
    function getPool(uint256 tokenId) public view returns (Pool memory) {
        return pools[tokenId];
    }

    /**
     * @dev read pool attribute
     */
    function getPortfolio(
        address user,
        uint256 tokenId
    ) public view returns (Portfolio memory) {
        return portfolios[user][tokenId];
    }

    /**
     * A -> B -> C: B: level1 A: level2
     * @dev referrer1: level1 of referrers referrer2: level2 of referrers
     */
    function getRerferrers(
        address account
    ) public view returns (address referrer1, address referrer2) {
        referrer1 = referrals[account];
        referrer2 = referrals[referrer1];
    }

    /**
     * @dev check signer implementation
     */
    function _checkSigner() internal view {
        if (!signers[msg.sender]) {
            revert NotSigner();
        }
    }

    /**
     * @dev only allowed signer address can do something
     */
    modifier onlySigner() {
        _checkSigner();
        _;
    }

    /**
     * @dev only allowed when drop is on
     */
    modifier onlyDropOn() {
        if (_dropConf._dropOn == 0) {
            revert DropOff();
        }
        _;
    }
}
