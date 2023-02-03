// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "src/lib/RankUpgradeable.sol";

contract RebornRank is RankUpgradeable {
    // rank from small to larger locate start from 1
    function _enter(uint256 value, uint256 locate)
        internal
        virtual
        override
        returns (uint256)
    {
        scores[++idx] = value;

        return idx;
    }
}
