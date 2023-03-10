// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/deprecated/DeprecatedRBT.sol";
import "src/RBT.sol";
import "src/RebornPortal.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

/**
 * @notice this file can be edited freely if the whole test can not pass
 */
contract RebornPortalReg is Test {
    uint256 bnbTest;
    RebornPortal portal;

    function setUp() public {
        string memory bnbTestRpcUrl = vm.envString("BNB_CHAIN_TEST_URL");
        bnbTest = vm.createFork(bnbTestRpcUrl);
        vm.selectFork(bnbTest);
        portal = RebornPortal(0xF6D95a75464B0C2C717407867eEF377ab1fe7046);
    }

    function mockUpgradeToDevVersion() public {
        RebornPortal newImpl = new RebornPortal();
        // mock upgrade to new one
        vm.prank(portal.owner());
        portal.upgradeTo(address(newImpl));
    }

    function testPerformUpkeep() public {
        vm.rollFork(27692275);
        bytes memory b = abi.encode(1);
        portal.performUpkeep(b);
    }

    function testSimulatePendingDrop() public {
        vm.rollFork(27717594);
        mockUpgradeToDevVersion();
        uint256[] memory arr = new uint256[](1);
        (arr[0]) = (97000000000000000036);

        vm.startPrank(0x8A1f5030dBdcC7A630af068Cc0440Bb05bDD8220);
        portal.flattenRewardDebt(97000000000000000036);
        (uint256 n, uint256 t) = portal.pendingDrop(arr);
        assertEq(n, 0);
        assertEq(t, 0);
        vm.stopPrank();
    }

    function testClaimRebornDrop() public {
        vm.rollFork(27708623);

        mockUpgradeToDevVersion();

        uint256[] memory arr = new uint256[](4);
        (arr[0], arr[1], arr[2], arr[3]) = (
            97000000000000000015,
            97000000000000000011,
            97000000000000000013,
            97000000000000000010
        );

        vm.expectEmit(false, false, false, false);
        emit PortalLib.ClaimRebornDrop(97000000000000000015, 0);
        emit PortalLib.ClaimRebornDrop(97000000000000000011, 0);
        emit PortalLib.ClaimRebornDrop(97000000000000000013, 0);
        emit PortalLib.ClaimRebornDrop(97000000000000000010, 0);

        vm.prank(0x679658Be03475D0A5393c70ea0E9A1158Dfae1Ff);
        portal.claimRebornDrops(arr);
    }

    function testSimulatePerformUpKeep() public {
        vm.rollFork(27913896);
        mockUpgradeToDevVersion();

        // portal.performUpkeep(abi.encode(1, 0));
    }
}
