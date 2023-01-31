// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/Rank.sol";

contract TokenTest is Test {
    Rank rank;
    address owner = address(2);
    address user = address(20);

    function setUp() public {
        rank = new Rank();
    }

    function enterBase(uint256 n) public {
        for (uint256 i = 0; i < n; i++) {
            rank.enter(1, 1 + i);
        }
    }

    function testEnterOne() public {
        rank.enter(1, 1);
    }

    function testFindLocation() public {
        rank.enter(4, 1);

        uint256 l = rank.findLocation(10);

        assertEq(l, 1);
        rank.enter(10, 1);

        address[100] memory ranks = rank.readRankInAddr();

        uint256 l2 = rank.findLocation(1);
        assertEq(l2, 3);
    }

    function testEnterMany(uint256 n) public {
        vm.assume(n <= 100);
        vm.startPrank(user);
        for (uint256 i = 0; i < n; i++) {
            rank.enter(1, i + 1);
        }
        vm.stopPrank();
        address[100] memory ranks = rank.readRankInAddr();

        address[100] memory constRank;
        for (uint256 i = 0; i < n; i++) {
            constRank[i] = user;
        }

        assertEq(abi.encode(ranks), abi.encode(constRank));
    }

    function testRandomRank(uint256 value) public {
        enterBase(10);

        uint256 l = rank.findLocation(value);

        rank.enter(value, l);
    }

    function testRandomRankMany(uint256[] memory values) public {
        for (uint256 i = 0; i < values.length; i++) {
            uint256 value = values[i];
            uint256 l = rank.findLocation(value);
            rank.enter(value, l);
        }
    }
}
