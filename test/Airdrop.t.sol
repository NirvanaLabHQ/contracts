// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortalBase.t.sol";

import {PortalLib} from "src/PortalLib.sol";

import "forge-std/console.sol";

contract AirdropTest is RebornPortalBaseTest {
    function setDropConf() public {
        // set drop conf
        vm.prank(owner);
        portal.setDropConf(
            PortalLib.AirdropConf(
                1,
                1 hours,
                3 hours,
                uint40(block.timestamp),
                uint40(block.timestamp),
                300,
                1000
            )
        );
    }

    function testUpKeepProgressSmoothly() public {
        mockEngravesAndInfuses(120);

        setDropConf();
        // set timestamp
        vm.warp(block.timestamp + 1 days);

        bool up;
        bytes memory perfromData;

        // request reborn token
        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        portal.performUpkeep(perfromData);

        // request drop native
        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        portal.performUpkeep(perfromData);

        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, false);

        uint256[] memory words;
        // fulfill random number of the reborn request;
        words = new uint256[](10);
        vm.prank(_vrfCoordinator);
        portal.rawFulfillRandomWords(1, words);

        // fulfill random number of the native request;
        words = new uint256[](10);
        vm.prank(_vrfCoordinator);
        portal.rawFulfillRandomWords(2, words);

        // perform the random number with reborn drop
        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        vm.expectEmit(false, false, false, false);
        emit PortalLib.DropNative(1);
        emit PortalLib.DropReborn(1);
        portal.performUpkeep(perfromData);

        // perform the random number with native drop
        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);
        portal.performUpkeep(perfromData);

        // after all perform, upKeep should be false
        (up, perfromData) = portal.checkUpkeep(new bytes(0));
        assertEq(up, false);
    }

    function testDropFuzz(address[] memory users) public {
        setDropConf();
        vm.assume(users.length > 100);

        // mock infuse
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = bound(
                uint160(user),
                0,
                (rbt.cap() - rbt.totalSupply()) / 1000
            );
            uint256 tokenId = uint160(user);
            // only EOA and not precompile address
            vm.assume(user.code.length == 0 && tokenId > 20);

            mockInfuse(user, tokenId, amount);
        }

        // give native token to portal
        deal(address(portal), UINT256_MAX);

        testUpKeepProgressSmoothly();

        // deal some reborn token to reward vault
        deal(address(rbt), address(portal.vault()), UINT256_MAX);

        // infuse again to trigger claim
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = bound(
                uint160(user),
                1,
                (rbt.cap() - rbt.totalSupply()) / 1000
            );
            uint256 tokenId = uint160(user);
            // only EOA and not precompile address
            vm.assume(user.code.length == 0 && tokenId > 20);

            uint256[] memory ds = new uint256[](1);
            ds[0] = tokenId;
            vm.prank(users[i]);
            portal.claimDrops(ds);
            mockInfuse(user, tokenId, amount);

            vm.stopPrank();
        }
    }
}
