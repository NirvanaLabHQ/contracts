// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/RebornPortal.t.sol";

contract AirdropTest is RebornPortalTest {
    function testDropFuzz(address[] memory users) public {
        vm.assume(users.length > 100);
        // mock infuse
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = bound(
                uint160(user),
                1,
                rbt.cap() - rbt.totalSupply()
            );
            uint256 tokenId = uint160(user);
            // only EOA and not precompile address
            vm.assume(user.code.length == 0 && tokenId > 20);

            mintRBT(rbt, owner, users[i], amount);
            vm.startPrank(users[i]);
            rbt.approve(address(portal), amount);
            portal.infuse(tokenId, amount);
            vm.stopPrank();
        }

        // set drop conf
        vm.prank(owner);
        portal.setDropConf(
            AirdropConf(
                1,
                1 hours,
                3 hours,
                uint40(block.timestamp),
                300,
                1 ether
            )
        );

        // set timestamp
        vm.warp(block.timestamp + 1 days);

        (bool up, ) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);

        // give native token to portal
        vm.deal(address(portal), 10 ** 18 * 1 ether);
        // manually set _jackpot
        vm.store(
            address(portal),
            bytes32(uint256(201)),
            bytes32(uint256(10 ether))
        );

        // drop token
        portal.performUpkeep(new bytes(0));

        // mint reward to reward vault
        mintRBT(rbt, owner, address(portal.vault()), 10000 ether);

        // infuse again to trigger claim
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = bound(
                uint160(user),
                1,
                rbt.cap() - rbt.totalSupply()
            );
            uint256 tokenId = uint160(user);
            // only EOA and not precompile address
            vm.assume(user.code.length == 0 && tokenId > 20);

            mintRBT(rbt, owner, users[i], amount);
            vm.startPrank(users[i]);
            portal.claimDrop(tokenId);
            rbt.approve(address(portal), amount);
            portal.infuse(tokenId, amount);
            vm.stopPrank();
        }
    }
}
