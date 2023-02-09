// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {CompactArray} from "src/lib/CompactArray.sol";

contract RankUpgradeable is Initializable {
    mapping(uint256 => uint256) scores;
    CompactArray.Array public ranks;
    using CompactArray for CompactArray.Array;

    uint24 public idx;
    uint256 public minScoreInRank;

    uint256[46] private _gap;

    uint256 constant RANK_LENGTH = 100;

    function __Rank_init() internal onlyInitializing {
        ranks.initialize(RANK_LENGTH);
    }

    // rank from small to larger locate start from 1
    function _enter(uint256 value, uint256 locate)
        internal
        virtual
        returns (uint256)
    {
        scores[++idx] = value;
        // 0 means no rank and check it is smaller than min in rank
        // if (locate == 0 && value <= minScoreInRank) {
        //     return idx;
        // }

        // // decode rank
        // // uint24[] memory rank = ranks.readAll();

        // if (locate <= RANK_LENGTH) {
        //     require(
        //         value > scores[ranks.read(locate - 1)],
        //         "Large than current not match"
        //     );
        // }

        // if (locate > 1) {
        //     require(
        //         value <= scores[ranks.read(locate - 2)],
        //         "Smaller than last not match"
        //     );
        // }

        // for (uint256 i = RANK_LENGTH; i > locate; i--) {
        //     ranks.set(i - 1, ranks.read(i - 2));
        //     // rank[i - 1] = rank[i - 2];
        // }

        // ranks.set(locate - 1, idx);
        // // rank[locate - 1] = idx;
        // minScoreInRank = scores[ranks.read(RANK_LENGTH - 1)];

        // // console.log("log rank before send rank");
        // // _setRank(rank);

        return idx;
    }

    function _setRank(uint24[] memory b) internal {
        ranks.write(b);
    }

    /**
     * @dev find the location in rank given a value
     * @dev usually executed off-chain
     */
    function findLocation(uint256 value) public returns (uint256) {
        uint24[] memory rank = ranks.readAll();
        for (uint256 i = 0; i < RANK_LENGTH; i++) {
            // console.log(value);
            // console.log(scores[rank[i]]);
            if (scores[rank[i]] < value) {
                return i + 1;
            }
        }
        // 0 means can not be in rank
        return 0;
    }

    function readRank() public returns (uint24[] memory rank) {
        rank = ranks.readAll();
    }
}
