// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {RankingRedBlackTree} from "src/lib/RankingRedBlackTree.sol";
import {SingleRanking} from "src/lib/SingleRanking.sol";
import {RebornPortalStorage} from "src/RebornPortalStorage.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract RankUpgradeable is RebornPortalStorage {
    using SingleRanking for SingleRanking.Data;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    /**
     * @dev set tokenId to rank, only top 100 into rank
     * @param tokenId incarnation tokenId
     * @param value incarnation life score
     */
    function _enterScoreRank(uint256 tokenId, uint256 value) internal {
        if (value == 0) {
            return;
        }
        // only when length is larger than 100, remove
        if (SingleRanking.length(_scoreRank) >= 100) {
            uint256 minValue = _scoreRank.getNthValue(99);
            // get the 100th value and compare, if new value is smaller, nothing happen
            if (value <= minValue) {
                return;
            }
            // remove the smallest in the score rank
            uint256 tokenIdWithMinmalScore = _scoreRank.get(99, 0)[0];
            _scoreRank.remove(tokenIdWithMinmalScore, minValue);

            // also remove it from tvl rank
            _isTopHundredScore.unset(tokenIdWithMinmalScore);
            _exitTvlRank(tokenIdWithMinmalScore);
        }

        // add to score rank
        _scoreRank.add(tokenId, value);
        // can enter the tvl rank
        _isTopHundredScore.set(tokenId);

        // Enter as a very small value, just ensure it's not zero and pass check
        // it doesn't matter too much as really stake has decimal with 18.
        // General value woule be much larger than 1
        _enterTvlRank(tokenId, 1);
    }

    /**
     * @dev set a new value in tree, only save top x largest value
     * @param value new value enters in the tree
     */
    function _enterTvlRank(uint256 tokenId, uint256 value) internal {
        // if it's not one hundred score, nothing happens
        if (!_isTopHundredScore.get(tokenId)) {
            return;
        }

        // remove old value from the rank, keep one token Id only one value
        if (_oldStakeAmounts[tokenId] != 0) {
            _tributeRank.remove(tokenId, _oldStakeAmounts[tokenId]);
        }
        _tributeRank.add(tokenId, value);
        _oldStakeAmounts[tokenId] = value;
    }

    /**
     * @dev if the tokenId's value is zero, it exits the ranking
     * @param tokenId pool tokenId
     */
    function _exitTvlRank(uint256 tokenId) internal {
        if (_oldStakeAmounts[tokenId] != 0) {
            _tributeRank.remove(tokenId, _oldStakeAmounts[tokenId]);
            delete _oldStakeAmounts[tokenId];
        }
    }

    /**
     * TODO: old data should have higher priority when value is the same
     */
    function _getTopNTokenId(
        uint256 n
    ) internal view returns (uint256[] memory values) {
        return _tributeRank.get(0, n);
    }
}
