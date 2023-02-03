// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract RankUpgradeable is Initializable {
    mapping(uint256 => uint256) scores;
    bytes public ranks;

    uint24 idx;
    uint256 public minScoreInRank;

    uint256[46] private _gap;

    uint256 constant RANK_LENGTH = 100;

    function __Rank_init() internal onlyInitializing {
        uint24[RANK_LENGTH] memory rank;
        ranks = abi.encode(rank);
    }

    // rank from small to larger locate start from 1
    function _enter(uint256 value, uint256 locate)
        internal
        virtual
        returns (uint256)
    {
        scores[++idx] = value;
        // 0 means no rank and check it is smaller than min in rank
        if (locate == 0 && value <= minScoreInRank) {
            return idx;
        }

        // decode rank
        uint24[RANK_LENGTH] memory rank = abi.decode(ranks, (uint24[100]));

        if (locate <= RANK_LENGTH) {
            require(
                value > scores[rank[locate - 1]],
                "Large than current not match"
            );
        }

        if (locate > 1) {
            require(
                value <= scores[rank[locate - 2]],
                "Smaller than last not match"
            );
        }

        for (uint256 i = RANK_LENGTH; i > locate; i--) {
            rank[i - 1] = rank[i - 2];
        }

        rank[locate - 1] = idx;
        minScoreInRank = scores[rank[RANK_LENGTH - 1]];

        _setRank(abi.encode(rank));

        return idx;
    }

    function _setRank(bytes memory b) internal {
        ranks = b;
    }

    /**
     * @dev find the location in rank given a value
     * @dev usually executed off-chain
     */
    function findLocation(uint256 value) public view returns (uint256) {
        uint24[RANK_LENGTH] memory rank = abi.decode(ranks, (uint24[100]));
        for (uint256 i = 0; i < RANK_LENGTH; i++) {
            if (scores[rank[i]] < value) {
                return i + 1;
            }
        }
        // 0 means can not be in rank
        return 0;
    }

    function readRank() public view returns (uint24[RANK_LENGTH] memory rank) {
        rank = abi.decode(ranks, (uint24[100]));
    }
}
