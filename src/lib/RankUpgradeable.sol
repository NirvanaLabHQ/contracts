// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {CompactArray} from "src/lib/CompactArray.sol";
import {SingleRanking} from "./SingleRanking.sol";

import "forge-std/console.sol";

contract RankUpgradeable is Initializable {
    mapping(uint256 => uint256) scores;
    SingleRanking.Data private _ranks;
    using SingleRanking for SingleRanking.Data;

    uint24 idx;
    uint256 public minScoreInRank;

    uint256[46] private _gap;

    uint256 constant RANK_LENGTH = 100;

    function __Rank_init() internal onlyInitializing {
        // ranks.initialize(RANK_LENGTH);
    }

    // rank from small to larger locate start from 1
    function _enter(uint256 value, uint256 locate)
        internal
        virtual
        returns (uint256)
    {
        scores[++idx] = value;

        _ranks.add(idx, value);

        return idx;
    }

    // function _setRank(uint24[] memory b) internal {
    //     ranks.write(b);
    // }

    /**
     * @dev find the location in rank given a value
     * @dev usually executed off-chain
     */
    function findLocation(uint256 value) public returns (uint256) {
        // uint24[] memory rank = ranks.readAll();
        // for (uint256 i = 0; i < RANK_LENGTH; i++) {
        //     // console.log(value);
        //     // console.log(scores[rank[i]]);
        //     if (scores[rank[i]] < value) {
        //         return i + 1;
        //     }
        // }
        // 0 means can not be in rank
        return 0;
    }

    function readRank(uint256 _offset, uint256 _count)
        public
        returns (uint256[] memory)
    {
        return _ranks.get(_offset, _count);
    }
}
