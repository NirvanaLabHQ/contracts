// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {RankingRedBlackTree} from "src/lib/RankingRedBlackTree.sol";
import {SingleRanking} from "src/lib/SingleRanking.sol";
import {RebornPortalStorage} from "src/RebornPortalStorage.sol";

import {DegenRank} from "src/DegenRank.sol";

contract RankUpgradeable is RebornPortalStorage {
    using SingleRanking for SingleRanking.Data;

    /**
     * @dev set tokenId to rank, only top 100 into rank
     * @param tokenId incarnation tokenId
     * @param value incarnation life score
     */
    function _enterScoreRank(uint256 tokenId, uint256 value) internal {
        DegenRank._enterScoreRank(
            _scoreRank,
            _tributeRank,
            _isTopHundredScore,
            _oldStakeAmounts,
            tokenId,
            value
        );
    }

    /**
     * @dev set a new value in tree, only save top x largest value
     * @param value new value enters in the tree
     */
    function _enterTvlRank(uint256 tokenId, uint256 value) internal {
        DegenRank._enterTvlRank(
            _tributeRank,
            _isTopHundredScore,
            _oldStakeAmounts,
            tokenId,
            value
        );
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
