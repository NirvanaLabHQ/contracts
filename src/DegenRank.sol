// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import {SingleRanking} from "src/lib/SingleRanking.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

library DegenRank {
    using SingleRanking for SingleRanking.Data;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    function _enterScoreRank(
        SingleRanking.Data storage _scoreRank,
        SingleRanking.Data storage _tributeRank,
        BitMapsUpgradeable.BitMap storage _isTopHundredScore,
        mapping(uint256 => uint256) storage _oldStakeAmounts,
        uint256 tokenId,
        uint256 value
    ) external {
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
            uint256 tokenIdWithMinmalScore = _scoreRank.get(99, 1)[0];
            _scoreRank.remove(tokenIdWithMinmalScore, minValue);

            // also remove it from tvl rank
            _isTopHundredScore.unset(tokenIdWithMinmalScore);
            _exitTvlRank(
                _tributeRank,
                _oldStakeAmounts,
                tokenIdWithMinmalScore
            );
        }

        // add to score rank
        _scoreRank.add(tokenId, value);
        // can enter the tvl rank
        _isTopHundredScore.set(tokenId);

        // Enter as a very small value, just ensure it's not zero and pass check
        // it doesn't matter too much as really stake has decimal with 18.
        // General value woule be much larger than 1
        _enterTvlRank(
            _tributeRank,
            _isTopHundredScore,
            _oldStakeAmounts,
            tokenId,
            1
        );
    }

    /**
     * @dev set a new value in tree, only save top x largest value
     * @param value new value enters in the tree
     */
    function _enterTvlRank(
        SingleRanking.Data storage _tributeRank,
        BitMapsUpgradeable.BitMap storage _isTopHundredScore,
        mapping(uint256 => uint256) storage _oldStakeAmounts,
        uint256 tokenId,
        uint256 value
    ) public {
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
    function _exitTvlRank(
        SingleRanking.Data storage _tributeRank,
        mapping(uint256 => uint256) storage _oldStakeAmounts,
        uint256 tokenId
    ) internal {
        if (_oldStakeAmounts[tokenId] != 0) {
            _tributeRank.remove(tokenId, _oldStakeAmounts[tokenId]);
            delete _oldStakeAmounts[tokenId];
        }
    }
}
