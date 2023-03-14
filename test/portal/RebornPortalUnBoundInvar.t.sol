// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortal.t.sol";

contract RebornPortalUnBoundInvar is RebornPortalBaseTest {
    function invariant_testToNextSeason() public {
        vm.prank(portal.owner());
        portal.toNextSeason();

        assertEq(portal.paused(), true);
    }

    function invariant_testBetaRestrict() public {
        vm.prank(portal.owner());
        portal.setBeta(true);

        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.infuse(0, 0);

        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.infuse(0, 0, 0, 0, bytes32(0), bytes32(0), 0x1b);

        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.switchPool(0, 1, 0);

        uint256[] memory arr = new uint256[](1);
        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.claimDrops(arr);

        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.claimNativeDrops(arr);

        vm.expectRevert(IRebornDefination.InBeta.selector);
        portal.claimRebornDrops(arr);
    }
}
