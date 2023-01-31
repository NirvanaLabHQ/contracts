// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "solmate/utils/SSTORE2.sol";

import "forge-std/console.sol";

contract Rank {
    mapping(uint256 => address) users;
    mapping(uint256 => uint256) values;

    bytes public ranks;
    uint24 idx;

    uint256 constant length = 100;

    constructor() {
        uint24[length] memory rank;
        ranks = abi.encode(rank);
    }

    // rank from small to larger locate start from 1
    function enter(uint256 value, uint256 locate) public {
        idx += 1;
        users[idx] = msg.sender;
        values[idx] = value;

        // 0 means no rank but need to check it is smaller than min in rank
        if (locate == 0) {
            return;
        }

        // update rank
        uint24[length] memory rank = abi.decode(ranks, (uint24[100]));

        if (locate <= length) {
            require(
                value > values[rank[locate - 1]],
                "Large than current not match"
            );
        }

        if (locate > 1) {
            require(
                value <= values[rank[locate - 2]],
                "Smaller than last not match"
            );
        }

        for (uint256 i = length; i > locate; i--) {
            rank[i - 1] = rank[i - 2];
        }

        rank[locate - 1] = idx;

        ranks = abi.encode(rank);
    }

    /**
     * @dev find the location in rank given a value
     * @dev usually executed off-chain
     */
    function findLocation(uint256 value) public view returns (uint256) {
        uint24[length] memory rank = abi.decode(ranks, (uint24[100]));
        for (uint256 i = 0; i < length; i++) {
            if (values[rank[i]] < value) {
                return i + 1;
            }
        }
    }

    function readRankInAddr() public view returns (address[length] memory) {
        uint24[length] memory rank = abi.decode(ranks, (uint24[100]));

        address[length] memory rankInAddr;

        for (uint256 i = 0; i < length; i++) {
            rankInAddr[i] = users[rank[i]];
        }

        return rankInAddr;
    }
}
