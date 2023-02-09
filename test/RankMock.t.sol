// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "src/mock/RankMock.sol";

contract RankMockTest is Test {
    RankMock rank;
    address owner = address(2);
    address user = address(20);

    function setUp() public {
        rank = new RankMock();
        rank.initialize();
    }

    function enterBase(uint256 n) public {
        for (uint256 i = 0; i < n; i++) {
            rank.enter(1, 1 + i);
        }
    }

    function testEnterOne() public {
        rank.enter(1, 1);
        rank.enter(2, 1);
        for (uint256 i = 0; i < 10; i++) {
            rank.enter(i + 3, 0);
        }
        // assertEq(rank.minScoreInRank(), 0);
        rank.readRank(0, 13);
        // console.logBytes(abi.encodePacked(0x1));
        // console.log(abi.encodePacked(rank.readRank()).length);
        // console.logBytes(abi.encodePacked(rank.readRank()));
    }

    function testFindLocation() public {
        rank.enter(4, 1);

        uint256 l = rank.findLocation(10);

        // assertEq(l, 1);
        rank.enter(10, 1);

        uint256 l2 = rank.findLocation(1);
        // assertEq(l2, 3);
    }

    function testEnterMany(uint256 n) public {
        vm.assume(n <= 40);
        vm.assume(n >= 10);
        vm.startPrank(user);
        for (uint256 i = 0; i < n; i++) {
            rank.enter(i + 2, 0);
        }
        vm.stopPrank();

        // uint256[40] memory constRank;
        // for (uint256 i = 0; i < n; i++) {
        //     constRank[i] = i + 1;
        // }
        rank.readRank(0, 2);
        // console.logBytes(abi.encodePacked());
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
        // rank.readRank(0, 2);
    }
}
