// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/RankUpgradeable.sol";

contract RankMock is RankUpgradeable {
    function enter(uint256 tokenId, uint256 value) public {
        _enter(tokenId, value);
    }

    function exit(uint256 tokenId) public {
        _exit(tokenId);
    }

    function getTopNTokenId(
        uint256 n
    ) public view returns (uint256[] memory values) {
        return _getTopNTokenId(n);
    }
}
