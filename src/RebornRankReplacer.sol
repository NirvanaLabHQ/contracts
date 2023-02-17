// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {BitMapsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract RebornRankReplacer is Initializable {
    mapping(uint256 => uint256) public scores;
    BitMapsUpgradeable.BitMap baptism;

    uint256 public idx;
    uint256 public minScoreInRank;

    uint256[46] private _gap;

    // rank from small to larger locate start from 1
    function _enter(uint256 value) internal virtual returns (uint256) {
        scores[++idx] = value;

        return idx;
    }
}
