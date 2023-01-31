// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {IRebornPortal} from "src/interfaces/IRebornPortal.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeOwnableUpgradeable} from "@p12/contracts-lib/contracts/access/SafeOwnableUpgradeable.sol";

import {IRebornToken} from "src/interfaces/IRebornToken.sol";

contract RebornPortal is
    IRebornPortal,
    SafeOwnableUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IRebornToken;
    error InsufficientAmount();

    /** you need buy a soup before reborn */
    uint256 public soupPrice = 0.1 * 1 ether;

    /**
     * @dev talent and property price in compact mode
     * @dev |   bytes8  |   bytes8  |   bytes8    |   bytes8    |
     * @dev |talentPrice|talentPoint|PropertyPrice|PropertyPoint|
     * @dev  4 2 0 for talent price   6  4  2  1  0  for property price
     * @dev  5 4 3 for talent point   35 30 25 20 15 for property point
     */
    uint256 private _priceAndPoint =
        0x00000000004020000000000000504030000000604020100000000231e19140f;

    IRebornToken public rebornToken;

    function initialize(
        IRebornToken rebornToken_,
        uint256 soupPrice_,
        uint256 priceAndPoint_,
        address owner_
    ) public initializer {
        rebornToken = rebornToken_;
        soupPrice = soupPrice_;
        _priceAndPoint = priceAndPoint_;
        __Ownable_init(owner_);
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
     */
    function engrave() external override {}

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
            talentPoint(innate.talent),
            propertyPoint(innate.properties),
            innate.talent,
            innate.properties
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
}
