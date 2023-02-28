// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {RankingRedBlackTree} from "src/lib/RankingRedBlackTree.sol";
import {SingleRanking} from "src/lib/SingleRanking.sol";

contract RankUpgradeable {
    error RequireLengthExceedCurrentData();
    error InsufficientData();

    using SingleRanking for SingleRanking.Data;

    SingleRanking.Data private _rank;
    uint256 private _treeLength;
    mapping(uint256 => uint256) _tokenIdOldValue;

    uint256[47] _gap;

    /**
     * @dev set a new value in tree, only save top x largest value
     * @param value new value enters in the tree
     */
    function enter(uint256 tokenId, uint256 value) public {
        if (value == 0) {
            exit(tokenId);
        }

        uint256 oldValue = _tokenIdOldValue[tokenId];
        // remove old value from the rank, keep one token Id only one value
        if (_tokenIdOldValue[tokenId] != 0) {
            _rank.remove(tokenId, _tokenIdOldValue[tokenId]);
        }
        _rank.add(tokenId, value);
        _tokenIdOldValue[tokenId] = value;
    }

    /**
     * @dev if the tokenId's value is zero, it exits the ranking
     * @param tokenId pool tokenId
     */
    function exit(uint256 tokenId) public {
        if (_tokenIdOldValue[tokenId] != 0) {
            uint256 oldValue = _tokenIdOldValue[tokenId];
            _rank.remove(tokenId, _tokenIdOldValue[tokenId]);
            delete _tokenIdOldValue[tokenId];
        }
    }

    function getTopNTokenId(
        uint256 n
    ) public view returns (uint256[] memory values) {
        return _rank.get(0, n);
    }
}
