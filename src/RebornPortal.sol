// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {IRebornPortal} from "src/interfaces/IRebornPortal.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeOwnableUpgradeable} from "@p12/contracts-lib/contracts/access/SafeOwnableUpgradeable.sol";

import {RankUpgradeable} from "src/RankUpgradeable.sol";
import {RebornStorage} from "src/RebornStorage.sol";
import {IRebornToken} from "src/interfaces/IRebornToken.sol";

contract RebornPortal is
    IRebornPortal,
    SafeOwnableUpgradeable,
    UUPSUpgradeable,
    RebornStorage,
    ERC721Upgradeable,
    ReentrancyGuardUpgradeable,
    RankUpgradeable
{
    using SafeERC20Upgradeable for IRebornToken;

    function initialize(
        IRebornToken rebornToken_,
        uint256 soupPrice_,
        uint256 priceAndPoint_,
        address owner_,
        string memory name_,
        string memory symbol_
    ) public initializer {
        rebornToken = rebornToken_;
        soupPrice = soupPrice_;
        _priceAndPoint = priceAndPoint_;
        __Ownable_init(owner_);
        __ERC721_init(name_, symbol_);
        __ReentrancyGuard_init();
        __Rank_init();
    }

    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function incarnate(Innate memory innate) external payable override {
        _incarnate(innate);
    }

    function incarnate(
        Innate memory innate,
        uint256 amount,
        uint256 deadline,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external payable override {
        _permit(amount, deadline, r, s, v);
        _incarnate(innate);
    }

    /**
     * @dev engrave the result on chain and reward
     * @param seed uuid seed string without "-"  in bytes32
     */
    function engrave(
        bytes32 seed,
        address user,
        uint256 reward,
        uint256 score,
        uint256 age,
        uint256 locate
    ) external override onlySigner {
        // enter the rank list
        uint256 tokenId = _enter(score, locate);

        details[tokenId] = LifeDetail(seed, user, ++rounds[user], uint16(age));
        //
        _safeMint(user, tokenId);

        rebornToken.transfer(user, reward);

        emit Engrave(seed, user, score, reward);
    }

    /**
     * @dev set soup price
     */
    function setSoupPrice(uint256 price) external override onlyOwner {
        soupPrice = price;
        emit NewSoupPrice(price);
    }

    /**
     * @dev set other price
     */
    function setPriceAndPoint(uint256 pricePoint) external override onlyOwner {
        _priceAndPoint = pricePoint;
        emit NewPricePoint(_priceAndPoint);
    }

    /**
     * @dev warning: only called onece during test
     * @dev abandoned in production
     */
    function initAfterUpgrade(string memory name_, string memory symbol_)
        external
        onlyOwner
    {
        __ERC721_init(name_, symbol_);
        __ReentrancyGuard_init();
        __Rank_init();
    }

    /**
     * @dev update signer
     */
    function updateSigners(
        address[] calldata toAdd,
        address[] calldata toRemove
    ) public onlyOwner {
        for (uint256 i = 0; i < toAdd.length; i++) {
            signers[toAdd[i]] = true;
            emit SignerUpdate(toAdd[i], false);
        }
        for (uint256 i = 0; i < toRemove.length; i++) {
            delete signers[toRemove[i]];
            emit SignerUpdate(toRemove[i], true);
        }
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

    /**
     * @dev implementation of incarnate
     */
    function _incarnate(Innate memory innate) internal {
        if (msg.value < soupPrice) {
            revert InsufficientAmount();
        }
        // transfer redundant native token back
        payable(msg.sender).transfer(msg.value - soupPrice);

        // reborn token needed
        uint256 rbtAmount = talentPrice(innate.talent) +
            propertyPrice(innate.properties);

        rebornToken.transferFrom(msg.sender, address(this), rbtAmount);

        emit Incarnate(
            msg.sender,
            talentPoint(innate.talent),
            propertyPoint(innate.properties),
            innate.talent,
            innate.properties,
            rbtAmount
        );
    }

    /**
     * @dev calculate talent price in $REBORN for each talent
     */
    function talentPrice(TALANT talent) public view returns (uint256) {
        return
            (((_priceAndPoint >> 192) >> (uint8(talent) * 8)) & 0xff) * 1 ether;
    }

    /**
     * @dev calculate talent point for each talent
     */
    function talentPoint(TALANT talent) public view returns (uint256) {
        return ((_priceAndPoint >> 128) >> (uint8(talent) * 8)) & 0xff;
    }

    /**
     * @dev calculate properties price in $REBORN for each properties
     */
    function propertyPrice(PROPERTIES properties)
        public
        view
        returns (uint256)
    {
        return
            (((_priceAndPoint >> 64) >> (uint8(properties) * 8)) & 0xff) *
            1 ether;
    }

    /**
     * @dev calculate properties point for each property
     */
    function propertyPoint(PROPERTIES properties)
        public
        view
        returns (uint256)
    {
        return (_priceAndPoint >> (uint8(properties) * 8)) & 0xff;
    }

    /**
     * @dev calculate properties born in $REBORN for each properties
     */

    /**
     * @dev only allow signer address can do something
     */
    modifier onlySigner() {
        if (!signers[msg.sender]) {
            revert NotSigner();
        }
        _;
    }
}
