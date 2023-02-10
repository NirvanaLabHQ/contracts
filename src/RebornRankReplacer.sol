// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "src/lib/RankUpgradeable.sol";

contract RebornRankReplacer is RankUpgradeable {
    // rank from small to larger locate start from 1
    function _enter(uint256 tokenId, uint256 value)
        internal
        virtual
        override
        returns (uint256)
    {
        scores[tokenId] = value;

        return idx;
    }
}
