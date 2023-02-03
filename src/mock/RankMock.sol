// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {RankUpgradeable} from "src/lib/RankUpgradeable.sol";

contract RankMock is RankUpgradeable {
    function initialize() public initializer {
        __Rank_init();
    }

    /**
     * @dev expose enter function
     */
    function enter(uint256 value, uint256 locate) public returns (uint256) {
        return _enter(value, locate);
    }
}
