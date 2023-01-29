// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {ERC20Capped, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {SafeOwnable} from "@p12/contracts-lib/contracts/access/SafeOwnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract RBT is ERC20Permit, ERC20Capped, SafeOwnable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 cap_,
        address owner_
    )
        ERC20(name_, symbol_)
        SafeOwnable(owner_)
        ERC20Capped(cap_)
        ERC20Permit(name_)
    {}

    /**
     * @dev in test, it can be mint infinitely
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20Capped, ERC20)
    {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        ERC20._mint(account, amount);
    }
}
