// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "src/deprecated/DeprecatedRBT.sol";
import "src/RBT.sol";
import "src/RebornPortal.sol";

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract RebornPortalReg is Test {
    uint256 bnbTest;
    RebornPortal portal;

    function setUp() public {
        string memory bnbTestRpcUrl = vm.envString("BNB_CHAIN_TEST_URL");
        bnbTest = vm.createFork(bnbTestRpcUrl);
        vm.selectFork(bnbTest);
        portal = RebornPortal(0xF6D95a75464B0C2C717407867eEF377ab1fe7046);

        RebornPortal newImpl = new RebornPortal();

        // mock upgrade to new one
        vm.prank(portal.owner());
        portal.upgradeTo(address(newImpl));
    }

    function testPerformUpkeep() public {
        bytes memory b = abi.encode(1);
        portal.performUpkeep(b);
    }

    function testPendingDrop() public {
        uint256[] memory arr = new uint256[](4);
        (arr[0], arr[1], arr[2], arr[3]) = (
            97000000000000000015,
            97000000000000000011,
            97000000000000000013,
            97000000000000000010
        );
        vm.prank(0x679658Be03475D0A5393c70ea0E9A1158Dfae1Ff);
        portal.pendingDrop(arr);
    }
}
