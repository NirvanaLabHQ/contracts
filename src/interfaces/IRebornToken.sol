// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {IERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

interface IRebornTokenDef {
    /// @dev caller not minter
    error NotMinter();
    /// @dev minter update event
    event MinterUpdate(address minter, bool valid);
}

interface IRebornToken is
    IERC20Upgradeable,
    IERC20PermitUpgradeable,
    IRebornTokenDef
{
    function mint(address to, uint256 amount) external;
}
