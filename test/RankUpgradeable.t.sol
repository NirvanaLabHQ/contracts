// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import "src/RankUpgradeable.sol";

contract RankUpgradeableTest is Test {
    RankUpgradeable rank;

    function setUp() public {
        rank = new RankUpgradeable();
    }

    function testEnterOne() public {
        rank.enter(1, 3);
        rank.enter(2, 3);
        rank.enter(3, 3);
        rank.enter(4, 1);
        rank.enter(4, 2);
        rank.enter(4, 3);

        rank.getTopNTokenId(4);
        rank.getTopNTokenId(6);
        rank.getTopNTokenId(10);
    }

    function testEnterMany(uint256[] memory values) public {
        vm.assume(values.length > 100);

        for (uint256 j = 0; j < 10; j++) {
            for (uint256 i = 0; i < values.length; i++) {
                rank.enter(i + 1, values[i]);
            }
        }

        rank.getTopNTokenId(100);
    }
}
