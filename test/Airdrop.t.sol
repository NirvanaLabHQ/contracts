// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/RebornPortal.t.sol";

contract AirdropTest is RebornPortalTest {
    function testDrop(address[] memory users) public {
        // mock infuse
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = i;
            uint256 tokenId = uint160(user);
            vm.assume(amount < rbt.cap() - rbt.totalSupply());
            vm.assume(users[i] != address(0));

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
                1,
                1 ether,
                1 ether
            )
        );

        // set timestamp
        vm.warp(block.timestamp + 1 days);

        (bool up, ) = portal.checkUpkeep(new bytes(0));
        assertEq(up, true);

        // drop token
        portal.performUpkeep(new bytes(0));

        // mint reward to reward vault
        mintRBT(rbt, owner, address(portal.vault()), 10000 ether);
        // infuse again to trigger claim
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            uint256 amount = i;
            uint256 tokenId = uint160(user);
            vm.assume(amount < rbt.cap() - rbt.totalSupply());
            vm.assume(users[i] != address(0));

            mintRBT(rbt, owner, users[i], amount);
            vm.startPrank(users[i]);
            rbt.approve(address(portal), amount);
            portal.infuse(tokenId, amount);
            vm.stopPrank();
        }
    }
}
