// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/RankUpgradeable.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract RankMock is RankUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    function enterTvlRank(uint256 tokenId, uint256 value) public {
        _enterTvlRank(tokenId, value);
    }

    function getTopNTokenId(
        uint256 n
    ) public view returns (uint256[] memory values) {
        return _getTopNTokenId(n);
    }

    function setTokenIdToTvlRank(uint256 tokenId) public {
        _isTopHundredScore.set(tokenId);
    }

    function setTokenIdsToTvlRank(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _enterScoreRank(tokenIds[i], 20);
        }
    }
}
