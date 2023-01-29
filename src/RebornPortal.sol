// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {IRebornPortal} from "src/interfaces/IRebornPortal.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeOwnableUpgradeable} from "@p12/contracts-lib/contracts/access/SafeOwnableUpgradeable.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IRebornToken} from "src/interfaces/IRebornToken.sol";

contract RebornPortal is
    IRebornPortal,
    SafeOwnableUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20 for IRebornToken;
    error InsufficientAmount();

    /** you need buy a soup before reborn */
    uint256 public soupPrice = 0.1 * 1 ether;

    /**
     * @dev talent and property price in compact mode
     * @dev talant price first 8 bytes then property 8 bytes
     * @dev  4 2 0 for talent   6 4 2 1 0 for property
     */
    uint256 private _price = 0x00000000000004200000000000064210;

    IRebornToken public rebornToken;

    function initialize(
        IRebornToken rebornToken_,
        uint256 soupPrice_,
        uint256 price_,
        address owner_
    ) public initializer {
        rebornToken = rebornToken_;
        soupPrice = soupPrice_;
        _price = price_;
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
            propertiesPrice(innate.properties);

        rebornToken.transferFrom(msg.sender, address(this), rbtAmount);

        emit Incarnate(innate.talent, innate.properties);
    }

    /**
     * @dev calculate talent price in $REBORN for each talent
     */
    function talentPrice(TALANT talent) public view returns (uint256) {
        return (((_price >> 64) >> (uint256(talent) * 4)) & 0xf) * 1 ether;
    }

    /**
     * @dev calculate properties price in $REBORN for each properties
     */
    function propertiesPrice(PROPERTIES properties)
        public
        view
        returns (uint256)
    {
        return ((_price >> (uint256(properties) * 4)) & 0xf) * 1 ether;
    }
}
