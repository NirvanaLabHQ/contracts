// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "test/portal/RebornPortal.t.sol";

contract RebornPortalInvar is RebornPortalBaseTest {
    function invariant_testToNextSeason() public {
        vm.prank(portal.owner());
        portal.toNextSeason();

        assertEq(portal.paused(), true);
    }
}
