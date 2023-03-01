// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import "src/mock/RankMock.sol";

contract RankUpgradeableTest is Test {
    RankMock rank;

    function setUp() public {
        rank = new RankMock();
    }

    function testEnterOne() public {
        uint256[] memory tokenIds = new uint256[](6);
        (
            tokenIds[0],
            tokenIds[1],
            tokenIds[2],
            tokenIds[3],
            tokenIds[4],
            tokenIds[5]
        ) = (1, 2, 3, 4, 5, 6);

        // mock engrave this tokenId
        rank.setTokenIdsToTvlRank(tokenIds);

        // mock stake amount changes
        rank.enterTvlRank(1, 3);
        rank.enterTvlRank(2, 3);
        rank.enterTvlRank(3, 3);
        rank.enterTvlRank(4, 2);

        uint256[] memory r = new uint256[](4);
        (r[0], r[1], r[2], r[3]) = (3, 2, 1, 4);
        assertEq(abi.encode(rank.getTopNTokenId(4)), abi.encode(r));

        r = new uint256[](6);
        (r[0], r[1], r[2], r[3], r[4], r[5]) = (3, 2, 1, 4, 5, 6);
        assertEq(abi.encode(rank.getTopNTokenId(6)), abi.encode(r));
        r = new uint256[](10);
        (r[0], r[1], r[2], r[3], r[4], r[5]) = (3, 2, 1, 4, 5, 6);
        assertEq(abi.encode(rank.getTopNTokenId(10)), abi.encode(r));
    }

    function testEnterMany(uint256[] memory values) public {
        vm.assume(values.length > 100);

        for (uint256 j = 0; j < 10; j++) {
            for (uint256 i = 0; i < values.length; i++) {
                rank.enterTvlRank(i + 1, values[i]);
            }
        }

        rank.getTopNTokenId(100);
    }
}
